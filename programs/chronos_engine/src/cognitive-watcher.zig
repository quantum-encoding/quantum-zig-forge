// SPDX-License-Identifier: Dual License - MIT (Non-Commercial) / Commercial License
//
// cognitive-watcher.zig - The Cognitive Oracle Consumer
//
// Purpose: Consume cognitive_events from eBPF ring buffer and forward to chronosd-cognitive
// Architecture: Ring buffer consumer → D-Bus publisher
//
// THE SACRED TRINITY:
//   Guardian (conductor-daemon) → Cognitive Watcher → chronosd-cognitive
//
// Philosophy: "The Watcher sits between the kernel and the daemon, translating divine whispers"

const std = @import("std");
const chronos = @import("chronos.zig");
const dbus_if = @import("dbus_interface.zig");
const dbus = @import("dbus_bindings.zig");
const cognitive_states = @import("cognitive_states.zig");

const c = @cImport({
    @cInclude("bpf/libbpf.h");
    @cInclude("bpf/bpf.h");
    @cInclude("linux/bpf.h");
});

const VERSION = "1.0.0";
const MAX_COMM_LEN = 16;
const MAX_BUF_SIZE = 256;

/// Cognitive Event (must match eBPF side - optimized structure)
const CognitiveEvent = extern struct {
    pid: u32,
    timestamp_ns: u32,  // Reduced to 32-bit
    fd: u32,
    buf_size: u32,      // Reduced to 32-bit
    comm: [MAX_COMM_LEN]u8,
    buffer: [MAX_BUF_SIZE]u8,  // Raw write buffer
};

/// The Cognitive Watcher - Bridge between eBPF and D-Bus
pub const CognitiveWatcher = struct {
    allocator: std.mem.Allocator,
    running: std.atomic.Value(bool),
    dbus_conn: ?dbus.DBusConnection,
    events_processed: u64,

    pub fn init(allocator: std.mem.Allocator) !CognitiveWatcher {
        std.debug.print("🔮 THE COGNITIVE WATCHER v{s} - Awakening\n", .{VERSION});
        std.debug.print("   Purpose: Bridge eBPF cognitive events to D-Bus\n", .{});
        std.debug.print("   Target: {s}\n", .{dbus_if.DBUS_SERVICE});

        // Try to connect to D-Bus (chronosd-cognitive)
        var dbus_conn: ?dbus.DBusConnection = null;
        if (dbus.DBusConnection.init(dbus.BusType.SYSTEM)) |conn| {
            dbus_conn = conn;
        } else |err| {
            std.debug.print("⚠️  Failed to connect to D-Bus: {any}\n", .{err});
            std.debug.print("   Continuing without D-Bus (chronosd-cognitive not running?)\n", .{});
        }

        return CognitiveWatcher{
            .allocator = allocator,
            .running = std.atomic.Value(bool).init(true),
            .dbus_conn = dbus_conn,
            .events_processed = 0,
        };
    }

    pub fn deinit(self: *CognitiveWatcher) void {
        if (self.dbus_conn) |*conn| {
            conn.deinit();
        }
        std.debug.print("🔮 Cognitive Watcher shutdown complete\n", .{});
    }

    /// Ring buffer callback (called by libbpf for each event)
    fn handleCognitiveEvent(ctx: ?*anyopaque, data: ?*anyopaque, size: c_ulong) callconv(.c) c_int {
        _ = size;
        if (data == null or ctx == null) return 0;

        const self: *CognitiveWatcher = @ptrCast(@alignCast(ctx));
        const event: *CognitiveEvent = @ptrCast(@alignCast(data));

        self.processCognitiveEvent(event) catch |err| {
            std.debug.print("⚠️  Event processing error: {any}\n", .{err});
        };

        return 0;
    }

    /// Strip ANSI escape sequences and control characters from buffer
    /// This makes cognitive state strings visible when they contain terminal formatting
    fn stripAnsi(allocator: std.mem.Allocator, buffer: []const u8) ![]u8 {
        var result = std.ArrayList(u8).empty;
        errdefer result.deinit(allocator);

        var i: usize = 0;
        while (i < buffer.len) {
            // Detect ANSI CSI sequence: ESC [ ... letter
            if (i + 1 < buffer.len and buffer[i] == 0x1b and buffer[i + 1] == '[') {
                i += 2;
                // Skip until we hit a letter (a-zA-Z) which terminates the sequence
                while (i < buffer.len) : (i += 1) {
                    const ch = buffer[i];
                    if ((ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z')) {
                        i += 1;
                        break;
                    }
                }
                continue;
            }

            // Detect ANSI OSC sequence: ESC ] ... BEL or ESC ] ... ESC \
            if (i + 1 < buffer.len and buffer[i] == 0x1b and buffer[i + 1] == ']') {
                i += 2;
                // Skip until BEL (0x07) or ST (ESC \)
                while (i < buffer.len) : (i += 1) {
                    if (buffer[i] == 0x07) {
                        i += 1;
                        break;
                    }
                    if (i + 1 < buffer.len and buffer[i] == 0x1b and buffer[i + 1] == '\\') {
                        i += 2;
                        break;
                    }
                }
                continue;
            }

            // Keep printable characters, newlines, and tabs
            const ch = buffer[i];
            if (ch >= 32 or ch == '\n' or ch == '\t') {
                try result.append(allocator, ch);
            }
            // Skip other control characters (0x00-0x1F except \n and \t)

            i += 1;
        }

        return result.toOwnedSlice(allocator);
    }

    /// Check if PID is Claude Code CLI by reading /proc/PID/cmdline
    fn isClaudeCLI(self: *CognitiveWatcher, pid: u32) bool {
        _ = self;
        var cmdline_buf: [4096]u8 = undefined;
        const cmdline_path = std.fmt.bufPrint(&cmdline_buf, "/proc/{d}/cmdline", .{pid}) catch return false;

        const file = std.fs.openFileAbsolute(cmdline_path, .{}) catch return false;
        defer file.close();

        var content: [4096]u8 = undefined;
        const bytes_read = file.read(&content) catch return false;

        // Check for claude binary (the cmdline will be just "claude" for Claude Code CLI)
        // Also check environment for npm.global/bin/claude
        const cmdline = content[0..bytes_read];

        // For now, accept ANY process named "claude" - we'll filter more precisely later
        return std.mem.indexOf(u8, cmdline, "claude") != null;
    }

    /// Process individual cognitive event
    fn processCognitiveEvent(self: *CognitiveWatcher, event: *CognitiveEvent) !void {
        self.events_processed += 1;

        // Filter: Only process if this is actually Claude Code CLI
        if (!self.isClaudeCLI(event.pid)) {
            return; // Not Claude Code, ignore
        }

        // Extract buffer and parse cognitive state in userspace
        const buffer = event.buffer[0..event.buf_size];
        const comm = std.mem.sliceTo(&event.comm, 0);

        // PHASE 1: Detect tool execution via DEBUG hooks
        // Pattern: "[DEBUG] executePreToolHooks called for tool: ToolName"
        if (std.mem.indexOf(u8, buffer, "executePreToolHooks called for tool:")) |pos| {
            const after_marker = buffer[pos + 41..]; // Skip "[DEBUG] executePreToolHooks called for tool: "

            // Skip leading whitespace/newlines to find actual tool name
            var start: usize = 0;
            while (start < after_marker.len) : (start += 1) {
                const ch = after_marker[start];
                if (ch != ' ' and ch != '\n' and ch != '\r' and ch != '\t') break;
            }

            // Extract tool name (until whitespace or buffer end)
            var tool_name_end: usize = start;
            while (tool_name_end < after_marker.len) : (tool_name_end += 1) {
                const ch = after_marker[tool_name_end];
                if (ch == '\n' or ch == '\r' or ch == 0 or ch == ' ' or ch == '\t') break;
            }

            const tool_name = after_marker[start..tool_name_end];

            // Map tool name to activity
            const activity = cognitive_states.ToolActivity.fromToolName(tool_name);
            const activity_str = activity.toString();

            std.debug.print("🧠 COGNITIVE EVENT #{d}:\n", .{self.events_processed});
            std.debug.print("   PID: {d}\n", .{event.pid});
            std.debug.print("   Process: {s}\n", .{comm});
            std.debug.print("   Tool: {s}\n", .{tool_name});
            std.debug.print("   Activity: {s}\n", .{activity_str});
            std.debug.print("   Timestamp: {d}ns\n\n", .{event.timestamp_ns});

            // Forward to chronosd-cognitive via D-Bus
            if (self.dbus_conn) |*conn| {
                self.updateChronosdCognitive(conn, activity_str, event.pid) catch |err| {
                    std.debug.print("⚠️  Failed to update chronosd-cognitive: {any}\n", .{err});
                };
            }

            return; // Successfully processed tool hook
        }

        // DEBUG: Log remaining output for pattern discovery
        // (Comment out this section once Phase 1 is stable to reduce noise)
        // Monitor FD 1, 2 (stdout/stderr - cognitive states), 24, 26 (sockets - JSON/debug)
        if (event.fd == 1 or event.fd == 2 or event.fd == 24 or event.fd == 26) {
            std.debug.print("🔍 CAPTURE #{d} [PID={d}] [FD={d}] [SIZE={d}]:\n", .{self.events_processed, event.pid, event.fd, event.buf_size});

            // Strip ANSI escape sequences to reveal cognitive state strings
            if (stripAnsi(self.allocator, buffer[0..@min(256, buffer.len)])) |clean_buffer| {
                defer self.allocator.free(clean_buffer);
                std.debug.print("   RAW: {s}\n", .{clean_buffer[0..@min(256, clean_buffer.len)]});
            } else |_| {
                // ANSI stripping failed, write hex dump to separate file (journald sanitizes binary data)
                const hex_file = std.fs.createFileAbsolute("/tmp/cognitive-watcher-hex.log", .{ .truncate = false }) catch |err| {
                    std.debug.print("   BINARY: {d} bytes (hex log failed: {any})\n", .{buffer.len, err});
                    return;
                };
                defer hex_file.close();
                hex_file.seekFromEnd(0) catch {}; // Append to end

                // Write capture header
                var header_buf: [256]u8 = undefined;
                const header = std.fmt.bufPrint(&header_buf, "CAPTURE #{d} [PID={d}] [FD={d}] [SIZE={d}]\nHEX: ", .{self.events_processed, event.pid, event.fd, event.buf_size}) catch "";
                _ = hex_file.write(header) catch {};

                // Write hex bytes
                const hex_len = @min(256, buffer.len);
                var hex_buf: [512]u8 = undefined;
                var hex_idx: usize = 0;
                for (buffer[0..hex_len]) |byte| {
                    const hex = std.fmt.bufPrint(hex_buf[hex_idx..], "{x:0>2}", .{byte}) catch break;
                    hex_idx += hex.len;
                    if (hex_idx + 3 > hex_buf.len) break;
                }
                _ = hex_file.write(hex_buf[0..hex_idx]) catch {};
                _ = hex_file.write("\nASCII: ") catch {};

                // Write ASCII representation
                for (buffer[0..hex_len]) |byte| {
                    if (byte >= 32 and byte < 127) {
                        _ = hex_file.write(&[_]u8{byte}) catch {};
                    } else {
                        _ = hex_file.write(".") catch {};
                    }
                }
                _ = hex_file.write("\n\n") catch {};

                std.debug.print("   BINARY: {d} bytes (see /tmp/cognitive-watcher-hex.log)\n", .{buffer.len});
            }
        }

        // Look for "::claude-code::" pattern and extract state
        if (std.mem.indexOf(u8, buffer, "::claude-code::")) |pos| {
            // Find the next "::" after claude-code
            if (std.mem.indexOf(u8, buffer[pos + 15..], "::")) |state_start_offset| {
                const state_start = pos + 15 + state_start_offset + 2;

                // Find the end of the state (next "::")
                if (std.mem.indexOf(u8, buffer[state_start..], "::")) |state_end_offset| {
                    const state = buffer[state_start..][0..state_end_offset];

                    std.debug.print("🧠 Cognitive Event #{d}:\n", .{self.events_processed});
                    std.debug.print("   PID: {d}\n", .{event.pid});
                    std.debug.print("   Process: {s}\n", .{comm});
                    std.debug.print("   FD: {d}\n", .{event.fd});
                    std.debug.print("   State: {s}\n", .{state});
                    std.debug.print("   Timestamp: {d}ns\n\n", .{event.timestamp_ns});

                    // Forward to chronosd-cognitive via D-Bus
                    if (self.dbus_conn) |*conn| {
                        self.updateChronosdCognitive(conn, state, event.pid) catch |err| {
                            std.debug.print("⚠️  Failed to update chronosd-cognitive: {any}\n", .{err});
                        };
                    }
                }
            }
        }
    }

    /// Update chronosd-cognitive via D-Bus method call
    fn updateChronosdCognitive(self: *CognitiveWatcher, conn: *dbus.DBusConnection, state: []const u8, pid: u32) !void {
        _ = self;

        // Call UpdateCognitiveState(state string, pid uint32) on chronosd-cognitive
        // For now, just log that we would call it
        // TODO: Implement actual D-Bus method call once chronosd-cognitive exposes UpdateCognitiveState
        std.debug.print("📡 Would call D-Bus: UpdateCognitiveState(\"{s}\", {d})\n", .{ state, pid });

        _ = conn;
    }

    /// Try to load cognitive-oracle eBPF program
    pub fn loadCognitiveOracle(self: *CognitiveWatcher) !void {
        std.debug.print("🔮 Loading cognitive-oracle eBPF program...\n", .{});

        // Check if cognitive-oracle.bpf.o exists (try installed location first, then local)
        const bpf_obj_path = "/usr/local/lib/bpf/cognitive-oracle.bpf.o";

        std.fs.cwd().access(bpf_obj_path, .{}) catch {
            std.debug.print("⚠️  eBPF object not found at {s}\n", .{bpf_obj_path});
            return error.BpfObjectNotFound;
        };

        // Open BPF object
        const obj = c.bpf_object__open(@ptrCast(bpf_obj_path));
        if (obj == null) {
            std.debug.print("❌ Failed to open BPF object: {s}\n", .{bpf_obj_path});
            return error.BpfOpenFailed;
        }
        defer _ = c.bpf_object__close(obj);

        // Load BPF program into kernel
        if (c.bpf_object__load(obj) != 0) {
            std.debug.print("❌ Failed to load BPF object into kernel\n", .{});
            return error.BpfLoadFailed;
        }

        std.debug.print("✓ Cognitive oracle loaded into kernel\n", .{});

        // CRITICAL: Find and attach the program to the tracepoint
        const prog = c.bpf_object__find_program_by_name(obj, "trace_write_enter");
        if (prog == null) {
            std.debug.print("❌ Failed to find program 'trace_write_enter'\n", .{});
            return error.ProgramNotFound;
        }

        const link = c.bpf_program__attach(prog);
        if (link == null) {
            std.debug.print("❌ Failed to attach program to tracepoint\n", .{});
            return error.AttachFailed;
        }

        std.debug.print("✓ Program attached to sys_enter_write tracepoint\n", .{});

        // Enable the cognitive oracle
        const config_map = c.bpf_object__find_map_by_name(obj, "cognitive_config");
        if (config_map == null) {
            return error.MapNotFound;
        }

        const config_fd = c.bpf_map__fd(config_map);
        var key: u32 = 0;
        var value: u32 = 1; // Enable

        if (c.bpf_map_update_elem(config_fd, &key, &value, c.BPF_ANY) != 0) {
            return error.MapUpdateFailed;
        }

        std.debug.print("✓ Cognitive oracle enabled\n", .{});

        // Get ring buffer map
        const rb_map = c.bpf_object__find_map_by_name(obj, "cognitive_events");
        if (rb_map == null) {
            return error.RingBufferNotFound;
        }

        const rb_fd = c.bpf_map__fd(rb_map);

        std.debug.print("✓ Ring buffer FD: {d}\n", .{rb_fd});
        std.debug.print("🔮 Beginning eternal vigil over Claude's cognitive whispers...\n\n", .{});

        // Create ring buffer consumer
        const ring_buffer = c.ring_buffer__new(
            rb_fd,
            handleCognitiveEvent,
            @ptrCast(self),
            null,
        );

        if (ring_buffer == null) {
            return error.RingBufferCreateFailed;
        }
        defer c.ring_buffer__free(ring_buffer);

        // Poll ring buffer forever
        while (self.running.load(.acquire)) {
            const poll_result = c.ring_buffer__poll(ring_buffer, 100); // 100ms timeout
            if (poll_result < 0) {
                std.debug.print("❌ Ring buffer poll error: {d}\n", .{poll_result});
                std.posix.nanosleep(0, 1 * std.time.ns_per_s);
                continue;
            }
        }
    }

    /// Run the watcher
    pub fn run(self: *CognitiveWatcher) !void {
        // Try to load and consume cognitive oracle events
        self.loadCognitiveOracle() catch |err| {
            std.debug.print("⚠️  Failed to load cognitive oracle: {any}\n", .{err});
            std.debug.print("   Possible causes:\n", .{});
            std.debug.print("   - cognitive-oracle.bpf.o not compiled\n", .{});
            std.debug.print("   - Insufficient permissions (need CAP_BPF or root)\n", .{});
            std.debug.print("   - Kernel doesn't support eBPF\n", .{});
            return err;
        };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var watcher = try CognitiveWatcher.init(allocator);
    defer watcher.deinit();

    // Handle SIGINT/SIGTERM for graceful shutdown
    // (simplified for now)

    try watcher.run();
}
