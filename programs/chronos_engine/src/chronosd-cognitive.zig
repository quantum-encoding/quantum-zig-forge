//! Guardian Shield - eBPF-based System Security Framework
//!
//! Copyright (c) 2025 Richard Tune / Quantum Encoding Ltd
//! Author: Richard Tune
//! Contact: info@quantumencoding.io
//! Website: https://quantumencoding.io
//!
//! License: Dual License - MIT (Non-Commercial) / Commercial License

// chronosd-cognitive.zig - Chronos Daemon with Integrated Cognitive Monitoring
// Purpose: Unified daemon providing both Sovereign Clock and Cognitive State tracking
//
// The Apotheosis: All-Seeing Eye + Living Chronicle
// - Monitors all claude-code processes automatically
// - Captures cognitive states in real-time from terminal output
// - Exposes GetCognitiveState() via D-Bus
// - chronos-stamp queries live cognitive state automatically

const std = @import("std");
const chronos = @import("chronos.zig");
const phi = @import("phi_timestamp.zig");
const dbus_if = @import("dbus_interface.zig");
const dbus = @import("dbus_bindings.zig");
const cognitive = @import("cognitive_states.zig");

const VERSION = "3.0.0-cognitive";

/// Cognitive state tracking
const CognitiveState = struct {
    state: ?[]const u8,
    last_updated: i64, // Unix timestamp in nanoseconds
    process_pid: ?std.posix.pid_t,

    pub fn init() CognitiveState {
        return .{
            .state = null,
            .last_updated = 0,
            .process_pid = null,
        };
    }
};

/// Chronos Daemon with Cognitive Monitoring
pub const ChronosDaemon = struct {
    clock: chronos.ChronosClock,
    allocator: std.mem.Allocator,
    running: std.atomic.Value(bool),
    dbus_conn: dbus.DBusConnection,

    // Cognitive state tracking
    cognitive_state: CognitiveState,
    cognitive_mutex: std.Thread.Mutex,

    pub fn init(allocator: std.mem.Allocator) !ChronosDaemon {
        // Initialize Chronos Clock
        const clock = try chronos.ChronosClock.init(allocator, null);

        // Connect to D-Bus system bus
        var dbus_conn = try dbus.DBusConnection.init(dbus.BusType.SYSTEM);
        errdefer dbus_conn.deinit();

        // Request service name
        try dbus_conn.requestName(
            dbus_if.DBUS_SERVICE,
            dbus.NameFlags.ALLOW_REPLACEMENT | dbus.NameFlags.REPLACE_EXISTING,
        );

        std.debug.print("🕐 Chronos Daemon v{s} starting\n", .{VERSION});
        std.debug.print("   D-Bus Service: {s}\n", .{dbus_if.DBUS_SERVICE});
        std.debug.print("   Object Path: {s}\n", .{dbus_if.DBUS_PATH});
        std.debug.print("   Current tick: {d}\n", .{clock.getTick()});
        std.debug.print("   Cognitive Monitoring: ENABLED\n", .{});

        return ChronosDaemon{
            .clock = clock,
            .allocator = allocator,
            .running = std.atomic.Value(bool).init(true),
            .dbus_conn = dbus_conn,
            .cognitive_state = CognitiveState.init(),
            .cognitive_mutex = std.Thread.Mutex{},
        };
    }

    pub fn deinit(self: *ChronosDaemon) void {
        self.cognitive_mutex.lock();
        if (self.cognitive_state.state) |state| {
            self.allocator.free(state);
        }
        self.cognitive_mutex.unlock();

        self.clock.deinit();
        self.dbus_conn.deinit();
        std.debug.print("🕐 Chronos Daemon shutdown complete\n", .{});
    }

    /// Update cognitive state (thread-safe)
    fn updateCognitiveState(self: *ChronosDaemon, new_state: []const u8, pid: std.posix.pid_t) !void {
        self.cognitive_mutex.lock();
        defer self.cognitive_mutex.unlock();

        // Free old state
        if (self.cognitive_state.state) |old_state| {
            self.allocator.free(old_state);
        }

        // Store new state
        self.cognitive_state.state = try self.allocator.dupe(u8, new_state);
        // Zig 0.16: Use std.posix.clock_gettime for wall clock time
        const ts = try std.posix.clock_gettime(std.posix.CLOCK.REALTIME);
        self.cognitive_state.last_updated = @intCast(@as(i128, ts.sec) * std.time.ns_per_s + ts.nsec);
        self.cognitive_state.process_pid = pid;

        std.debug.print("🧠 Cognitive state: {s} (PID {d})\n", .{ new_state, pid });
    }

    /// Get current cognitive state (thread-safe)
    fn getCognitiveState(self: *ChronosDaemon) !?[]const u8 {
        self.cognitive_mutex.lock();
        defer self.cognitive_mutex.unlock();

        if (self.cognitive_state.state) |state| {
            return try self.allocator.dupe(u8, state);
        }
        return null;
    }

    /// Monitor Claude Code processes for cognitive states
    fn monitorCognitiveStates(self: *ChronosDaemon) !void {
        std.debug.print("👁️  Starting cognitive monitor thread\n", .{});

        while (self.running.load(.acquire)) {
            // Scan /proc for claude-code processes
            var proc_dir = std.fs.openDirAbsolute("/proc", .{ .iterate = true }) catch {
                std.posix.nanosleep(0, 1 * std.time.ns_per_s);
                continue;
            };
            defer proc_dir.close();

            var iter = proc_dir.iterate();
            while (try iter.next()) |entry| {
                // Check if directory name is a PID (numeric)
                if (entry.kind != .directory) continue;

                const pid = std.fmt.parseInt(std.posix.pid_t, entry.name, 10) catch continue;

                // Read cmdline to check if it's claude
                var cmdline_buf: [4096]u8 = undefined;
                const cmdline_path = try std.fmt.bufPrint(&cmdline_buf, "/proc/{d}/cmdline", .{pid});

                const cmdline_file = std.fs.openFileAbsolute(cmdline_path, .{}) catch continue;
                defer cmdline_file.close();

                var cmdline_content: [4096]u8 = undefined;
                const bytes_read = cmdline_file.read(&cmdline_content) catch continue;

                // Check if cmdline contains "claude"
                const cmdline_str = cmdline_content[0..bytes_read];
                if (std.mem.indexOf(u8, cmdline_str, "claude") == null) continue;

                std.debug.print("👁️  Found Claude process: PID {d}\n", .{pid});

                // Note: Reading from /proc/PID/fd/1 requires special permissions
                // In production, we'd use ptrace() or create a pty wrapper
                // For now, we check cached cognitive state from monitor

                // Check for cached cognitive state
                const home = std.posix.getenv("HOME") orelse "/home/founder";
                var state_path_buf: [512]u8 = undefined;
                const state_path = try std.fmt.bufPrint(
                    &state_path_buf,
                    "{s}/.cache/claude-code-cognitive-monitor/current-state.json",
                    .{home},
                );

                const state_file = std.fs.openFileAbsolute(state_path, .{}) catch continue;
                defer state_file.close();

                var state_content: [4096]u8 = undefined;
                const state_bytes = state_file.read(&state_content) catch continue;

                // Parse JSON for state
                const json_str = state_content[0..state_bytes];
                var parsed = std.json.parseFromSlice(
                    struct { state: ?[]const u8 = null },
                    self.allocator,
                    json_str,
                    .{ .ignore_unknown_fields = true },
                ) catch continue;
                defer parsed.deinit();

                if (parsed.value.state) |state| {
                    try self.updateCognitiveState(state, pid);
                }

                break; // Only monitor first claude process found
            }

            // Sleep before next scan
            std.posix.nanosleep(0, 2 * std.time.ns_per_s);
        }
    }

    /// Run D-Bus message loop (cognitive states received via UpdateCognitiveState D-Bus calls)
    pub fn run(self: *ChronosDaemon) !void {
        std.debug.print("🕐 Chronos Daemon running (D-Bus mode)\n", .{});
        std.debug.print("   Cognitive states: Listening via D-Bus UpdateCognitiveState()\n", .{});
        std.debug.print("   Ready for method calls\n\n", .{});

        while (self.running.load(.acquire)) {
            // Read and dispatch D-Bus messages (1 second timeout)
            if (!self.dbus_conn.readWriteDispatch(1000)) {
                std.debug.print("⚠️  D-Bus connection lost\n", .{});
                break;
            }

            // Check for incoming messages
            while (self.dbus_conn.popMessage()) |raw_msg| {
                var msg = dbus.DBusMessage{ .msg = raw_msg };
                defer msg.unref();

                try self.handleMessage(&msg);
            }
        }
    }

    /// Handle D-Bus method call
    fn handleMessage(self: *ChronosDaemon, msg: *dbus.DBusMessage) !void {
        const interface = dbus_if.DBUS_INTERFACE;

        // GetTick method
        if (msg.isMethodCall(interface, "GetTick")) {
            const tick = self.clock.getTick();

            var reply = msg.newMethodReturn() orelse return error.DBusReplyFailed;
            defer reply.unref();

            try reply.appendU64(tick);
            try self.dbus_conn.send(reply.msg.?);
            return;
        }

        // NextTick method
        if (msg.isMethodCall(interface, "NextTick")) {
            const tick = try self.clock.nextTick();

            var reply = msg.newMethodReturn() orelse return error.DBusReplyFailed;
            defer reply.unref();

            try reply.appendU64(tick);
            try self.dbus_conn.send(reply.msg.?);
            return;
        }

        // GetPhiTimestamp method
        if (msg.isMethodCall(interface, "GetPhiTimestamp")) {
            const agent_id = msg.getString(0) orelse {
                var err_reply = msg.newErrorReturn(dbus.ErrorName.INVALID_ARGS, "Missing agent_id") orelse return;
                defer err_reply.unref();
                try self.dbus_conn.send(err_reply.msg.?);
                return;
            };

            var gen = phi.PhiGenerator.init(self.allocator, &self.clock, agent_id);
            const timestamp = try gen.next();
            const formatted = try timestamp.format(self.allocator);
            defer self.allocator.free(formatted);

            var reply = msg.newMethodReturn() orelse return error.DBusReplyFailed;
            defer reply.unref();

            const formatted_z = try self.allocator.dupeZ(u8, formatted);
            defer self.allocator.free(formatted_z);

            try reply.appendString(formatted_z);
            try self.dbus_conn.send(reply.msg.?);
            return;
        }

        // GetCognitiveState method (NEW!)
        if (msg.isMethodCall(interface, "GetCognitiveState")) {
            const state = try self.getCognitiveState();

            var reply = msg.newMethodReturn() orelse return error.DBusReplyFailed;
            defer reply.unref();

            if (state) |s| {
                defer self.allocator.free(s);
                const s_z = try self.allocator.dupeZ(u8, s);
                defer self.allocator.free(s_z);
                try reply.appendString(s_z);
            } else {
                // Return empty string if no state available
                try reply.appendString("");
            }

            try self.dbus_conn.send(reply.msg.?);
            return;
        }

        // UpdateCognitiveState method (called by cognitive-watcher)
        if (msg.isMethodCall(interface, "UpdateCognitiveState")) {
            const state_str = msg.getString(0) orelse {
                var err_reply = msg.newErrorReturn(dbus.ErrorName.INVALID_ARGS, "Missing state string") orelse return;
                defer err_reply.unref();
                try self.dbus_conn.send(err_reply.msg.?);
                return;
            };

            const pid_val = msg.getU32(1) orelse {
                var err_reply = msg.newErrorReturn(dbus.ErrorName.INVALID_ARGS, "Missing PID") orelse return;
                defer err_reply.unref();
                try self.dbus_conn.send(err_reply.msg.?);
                return;
            };

            // Update cognitive state
            try self.updateCognitiveState(state_str, @intCast(pid_val));

            var reply = msg.newMethodReturn() orelse return error.DBusReplyFailed;
            defer reply.unref();

            try self.dbus_conn.send(reply.msg.?);
            return;
        }

        // Shutdown method
        if (msg.isMethodCall(interface, "Shutdown")) {
            var reply = msg.newMethodReturn() orelse return error.DBusReplyFailed;
            defer reply.unref();

            try self.dbus_conn.send(reply.msg.?);
            self.shutdown();
            return;
        }
    }

    /// Shutdown daemon gracefully
    pub fn shutdown(self: *ChronosDaemon) void {
        std.debug.print("🕐 Chronos Daemon shutting down...\n", .{});
        self.running.store(false, .release);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var daemon = try ChronosDaemon.init(allocator);
    defer daemon.deinit();

    try daemon.run();
}
