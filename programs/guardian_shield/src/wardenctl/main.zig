//! wardenctl - Guardian Shield V8.0 Control CLI
//!
//! Runtime configuration management for libwarden.so
//!
//! Commands:
//!   wardenctl add -p . --template dev       # Protect current directory with template
//!   wardenctl add --path /some/path [--no-delete] [--no-move] [--read-only]
//!   wardenctl remove --path /some/path      # Requires sudo
//!   wardenctl list                          # Show all protected paths
//!   wardenctl reload                        # Signal running processes to reload config
//!   wardenctl status                        # Show shield status
//!   wardenctl test /some/path <operation>   # Test if operation would be blocked
//!
//! Templates:
//!   --template safe       = --no-delete --no-move
//!   --template dev        = --no-delete --no-move --no-truncate
//!   --template readonly   = --read-only
//!   --template production = --read-only (full immutability)
//!
//! Operations:
//!   delete, move, truncate, symlink, link, mkdir, write

const std = @import("std");
const fs = std.fs;
const json = std.json;

const VERSION = "8.0.0";
const CONFIG_PATH = "/etc/warden/warden-config.json";
const DEV_CONFIG_PATH = "/home/founder/zig_forge/config/warden-config.json";

// ============================================================
// Protection Templates
// ============================================================

const Template = enum {
    safe, // --no-delete --no-move
    dev, // --no-delete --no-move --no-truncate
    readonly, // --read-only
    production, // --read-only (maximum security)

    fn toFlags(self: Template) PermissionFlags {
        return switch (self) {
            .safe => PermissionFlags{
                .no_delete = true,
                .no_move = true,
            },
            .dev => PermissionFlags{
                .no_delete = true,
                .no_move = true,
                .no_truncate = true,
            },
            .readonly, .production => PermissionFlags{
                .read_only = true,
            },
        };
    }

    fn description(self: Template) []const u8 {
        return switch (self) {
            .safe => "Safe template: no-delete, no-move",
            .dev => "Development template: no-delete, no-move, no-truncate",
            .readonly => "Read-only template: full immutability",
            .production => "Production template: full immutability",
        };
    }
};

// ============================================================
// Command Line Parsing
// ============================================================

const Command = enum {
    add,
    remove,
    list,
    reload,
    status,
    @"test",
    help,
    version,
};

const PermissionFlags = struct {
    no_delete: bool = false,
    no_move: bool = false,
    no_truncate: bool = false,
    no_write: bool = false, // Blocks open_write only
    no_symlink: bool = false,
    no_link: bool = false,
    no_mkdir: bool = false,
    read_only: bool = false, // Implies all of the above
};

const Args = struct {
    command: Command,
    path: ?[]const u8 = null,
    resolved_path: ?[]const u8 = null, // Absolute path after resolving "."
    operation: ?[]const u8 = null,
    flags: PermissionFlags = .{},
    template: ?Template = null,
    description: ?[]const u8 = null,
    config_file: []const u8 = DEV_CONFIG_PATH,
    verbose: bool = false,
};

fn parseArgs(allocator: std.mem.Allocator) !Args {
    var args = std.process.args();
    _ = args.skip(); // Skip program name

    var result = Args{ .command = .help };

    // Parse command
    if (args.next()) |cmd| {
        result.command = std.meta.stringToEnum(Command, cmd) orelse .help;
    } else {
        return result;
    }

    // Parse remaining arguments
    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--path") or std.mem.eql(u8, arg, "-p")) {
            result.path = args.next();
        } else if (std.mem.eql(u8, arg, "--template") or std.mem.eql(u8, arg, "-t")) {
            if (args.next()) |tmpl| {
                result.template = std.meta.stringToEnum(Template, tmpl);
            }
        } else if (std.mem.eql(u8, arg, "--no-delete")) {
            result.flags.no_delete = true;
        } else if (std.mem.eql(u8, arg, "--no-move")) {
            result.flags.no_move = true;
        } else if (std.mem.eql(u8, arg, "--no-truncate")) {
            result.flags.no_truncate = true;
        } else if (std.mem.eql(u8, arg, "--no-symlink")) {
            result.flags.no_symlink = true;
        } else if (std.mem.eql(u8, arg, "--no-link")) {
            result.flags.no_link = true;
        } else if (std.mem.eql(u8, arg, "--no-mkdir")) {
            result.flags.no_mkdir = true;
        } else if (std.mem.eql(u8, arg, "--no-write")) {
            result.flags.no_write = true;
        } else if (std.mem.eql(u8, arg, "--read-only") or std.mem.eql(u8, arg, "-r")) {
            result.flags.read_only = true;
        } else if (std.mem.eql(u8, arg, "--description") or std.mem.eql(u8, arg, "-d")) {
            result.description = args.next();
        } else if (std.mem.eql(u8, arg, "--config") or std.mem.eql(u8, arg, "-c")) {
            result.config_file = args.next() orelse DEV_CONFIG_PATH;
        } else if (std.mem.eql(u8, arg, "--verbose") or std.mem.eql(u8, arg, "-v")) {
            result.verbose = true;
        } else if (result.path == null and !std.mem.startsWith(u8, arg, "-")) {
            // Positional argument - path or operation
            if (result.command == .@"test") {
                if (result.path == null) {
                    result.path = arg;
                } else {
                    result.operation = arg;
                }
            } else {
                result.path = arg;
            }
        }
    }

    // Resolve "." to absolute path
    if (result.path) |path| {
        if (std.mem.eql(u8, path, ".")) {
            // Get current working directory
            var cwd_buf: [std.fs.max_path_bytes]u8 = undefined;
            const cwd = std.fs.cwd().realpath(".", &cwd_buf) catch {
                std.debug.print("Error: Could not resolve current directory\n", .{});
                return result;
            };
            // Allocate and copy the resolved path
            const resolved = try allocator.dupe(u8, cwd);
            result.resolved_path = resolved;
        } else if (std.mem.startsWith(u8, path, "./")) {
            // Relative path - resolve to absolute
            var cwd_buf: [std.fs.max_path_bytes]u8 = undefined;
            const cwd = std.fs.cwd().realpath(path, &cwd_buf) catch {
                // If can't resolve, use as-is
                result.resolved_path = path;
                return result;
            };
            const resolved = try allocator.dupe(u8, cwd);
            result.resolved_path = resolved;
        } else {
            result.resolved_path = path;
        }
    }

    // Apply template flags if specified
    if (result.template) |tmpl| {
        result.flags = tmpl.toFlags();
    }

    return result;
}

// ============================================================
// Configuration Management
// ============================================================

fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !json.Parsed(json.Value) {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    const file_size = try file.getEndPos();
    const content = try allocator.alloc(u8, file_size);
    defer allocator.free(content);

    // Read file using low-level read
    var bytes_read: usize = 0;
    while (bytes_read < file_size) {
        const n = try file.read(content[bytes_read..]);
        if (n == 0) break;
        bytes_read += n;
    }

    return json.parseFromSlice(json.Value, allocator, content, .{});
}

fn saveConfig(allocator: std.mem.Allocator, path: []const u8, config: json.Value) !void {
    _ = allocator;

    const file = try fs.cwd().createFile(path, .{});
    defer file.close();

    // Use the fmt API for stringification - write directly to file
    const formatted = json.fmt(config, .{ .whitespace = .indent_2 });

    // Use a fixed buffer for output
    var buffer: [65536]u8 = undefined;
    const output = std.fmt.bufPrint(&buffer, "{any}", .{formatted}) catch {
        std.debug.print("Error: Config too large for buffer\n", .{});
        return error.BufferTooSmall;
    };

    try file.writeAll(output);
}

fn flagsToOperations(flags: PermissionFlags) []const []const u8 {
    // Use a static buffer since we're returning a slice of compile-time strings
    const S = struct {
        var ops: [20][]const u8 = undefined;
    };
    var count: usize = 0;

    if (flags.read_only) {
        // Read-only implies all write operations blocked
        S.ops[count] = "unlink";
        count += 1;
        S.ops[count] = "unlinkat";
        count += 1;
        S.ops[count] = "rmdir";
        count += 1;
        S.ops[count] = "open_write";
        count += 1;
        S.ops[count] = "rename";
        count += 1;
        S.ops[count] = "truncate";
        count += 1;
        S.ops[count] = "symlink";
        count += 1;
        S.ops[count] = "symlink_target";
        count += 1;
        S.ops[count] = "link";
        count += 1;
        S.ops[count] = "mkdir";
        count += 1;
        return S.ops[0..count];
    }

    if (flags.no_delete) {
        S.ops[count] = "unlink";
        count += 1;
        S.ops[count] = "unlinkat";
        count += 1;
        S.ops[count] = "rmdir";
        count += 1;
    }

    if (flags.no_move) {
        S.ops[count] = "rename";
        count += 1;
    }

    if (flags.no_truncate) {
        S.ops[count] = "truncate";
        count += 1;
    }

    if (flags.no_write) {
        S.ops[count] = "open_write";
        count += 1;
    }

    if (flags.no_symlink) {
        S.ops[count] = "symlink";
        count += 1;
        S.ops[count] = "symlink_target";
        count += 1;
    }

    if (flags.no_link) {
        S.ops[count] = "link";
        count += 1;
    }

    if (flags.no_mkdir) {
        S.ops[count] = "mkdir";
        count += 1;
    }

    return S.ops[0..count];
}

// ============================================================
// Commands
// ============================================================

fn cmdAdd(allocator: std.mem.Allocator, args: Args) !void {
    // Use resolved path (handles "." → absolute path)
    const path = args.resolved_path orelse args.path orelse {
        std.debug.print("Error: --path required\n", .{});
        std.debug.print("Usage: wardenctl add -p /path/to/protect [--template dev]\n", .{});
        std.debug.print("       wardenctl add -p . --template safe\n", .{});
        return;
    };

    // Ensure path ends with / for directory protection
    var path_with_slash: [std.fs.max_path_bytes + 1]u8 = undefined;
    const final_path = if (!std.mem.endsWith(u8, path, "/")) blk: {
        const len = @min(path.len, std.fs.max_path_bytes);
        @memcpy(path_with_slash[0..len], path[0..len]);
        path_with_slash[len] = '/';
        break :blk path_with_slash[0 .. len + 1];
    } else path;

    // Show what we're doing
    if (args.template) |tmpl| {
        std.debug.print("Adding protected path: {s}\n", .{final_path});
        std.debug.print("Template: {s}\n", .{tmpl.description()});
    } else {
        std.debug.print("Adding protected path: {s}\n", .{final_path});
    }

    var parsed = loadConfig(allocator, args.config_file) catch |err| {
        std.debug.print("Error loading config: {any}\n", .{err});
        return;
    };
    defer parsed.deinit();

    // Navigate to protection.protected_paths array
    const root = parsed.value.object;
    const protection = root.get("protection") orelse {
        std.debug.print("Error: Invalid config - missing 'protection' section\n", .{});
        return;
    };

    var protected_paths = protection.object.get("protected_paths") orelse {
        std.debug.print("Error: Invalid config - missing 'protected_paths' array\n", .{});
        return;
    };

    // Check if path already exists
    for (protected_paths.array.items) |item| {
        const existing_path = item.object.get("path") orelse continue;
        if (std.mem.eql(u8, existing_path.string, final_path)) {
            std.debug.print("Path already protected: {s}\n", .{final_path});
            return;
        }
    }

    // Build operations list
    const ops = flagsToOperations(args.flags);
    if (ops.len == 0) {
        std.debug.print("Warning: No operations specified. Use --template, --no-delete, --no-move, --read-only, etc.\n", .{});
        std.debug.print("Defaulting to --template safe (--no-delete --no-move)\n", .{});
    }

    // Generate description
    const desc = if (args.description) |d|
        d
    else if (args.template) |tmpl|
        tmpl.description()
    else
        "Added via wardenctl";

    // Create new entry
    var new_entry = json.ObjectMap.init(allocator);
    try new_entry.put("path", json.Value{ .string = final_path });
    try new_entry.put("description", json.Value{ .string = desc });

    var ops_array = json.Array.init(allocator);
    for (ops) |op| {
        try ops_array.append(json.Value{ .string = op });
    }
    // If no ops specified, use read-only defaults
    if (ops.len == 0) {
        const default_ops = [_][]const u8{ "unlink", "unlinkat", "rmdir", "open_write", "rename", "truncate", "symlink", "link", "mkdir" };
        for (default_ops) |op| {
            try ops_array.append(json.Value{ .string = op });
        }
    }
    try new_entry.put("block_operations", json.Value{ .array = ops_array });

    try protected_paths.array.append(json.Value{ .object = new_entry });

    // Save config
    try saveConfig(allocator, args.config_file, parsed.value);

    std.debug.print("✓ Added: {s}\n", .{path});
    std.debug.print("  Config: {s}\n", .{args.config_file});
    std.debug.print("  Note: Run 'wardenctl reload' to apply changes to running processes\n", .{});
}

fn cmdRemove(allocator: std.mem.Allocator, args: Args) !void {
    const path = args.path orelse {
        std.debug.print("Error: --path required\n", .{});
        return;
    };

    std.debug.print("Removing protected path: {s}\n", .{path});

    var parsed = loadConfig(allocator, args.config_file) catch |err| {
        std.debug.print("Error loading config: {any}\n", .{err});
        return;
    };
    defer parsed.deinit();

    const root = parsed.value.object;
    const protection = root.get("protection") orelse return;
    var protected_paths = protection.object.get("protected_paths") orelse return;

    // Find and remove path
    var found = false;
    var i: usize = 0;
    while (i < protected_paths.array.items.len) {
        const item = protected_paths.array.items[i];
        const existing_path = item.object.get("path") orelse {
            i += 1;
            continue;
        };
        if (std.mem.eql(u8, existing_path.string, path)) {
            _ = protected_paths.array.orderedRemove(i);
            found = true;
            break;
        }
        i += 1;
    }

    if (!found) {
        std.debug.print("Path not found in config: {s}\n", .{path});
        return;
    }

    try saveConfig(allocator, args.config_file, parsed.value);
    std.debug.print("✓ Removed: {s}\n", .{path});
    std.debug.print("  Note: Run 'wardenctl reload' to apply changes to running processes\n", .{});
}

fn cmdList(allocator: std.mem.Allocator, args: Args) !void {
    var parsed = loadConfig(allocator, args.config_file) catch |err| {
        std.debug.print("Error loading config: {any}\n", .{err});
        return;
    };
    defer parsed.deinit();

    const root = parsed.value.object;
    const global = root.get("global") orelse return;
    const enabled = global.object.get("enabled") orelse return;

    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Guardian Shield V8.0 - Protected Paths                  ║\n", .{});
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});

    std.debug.print("Status: {s}\n", .{if (enabled.bool) "🛡️  ACTIVE" else "⚠️  DISABLED"});
    std.debug.print("Config: {s}\n\n", .{args.config_file});

    const protection = root.get("protection") orelse return;
    const protected_paths = protection.object.get("protected_paths") orelse return;

    std.debug.print("Protected Paths ({d}):\n", .{protected_paths.array.items.len});
    std.debug.print("─────────────────────────────────────────────────────────────\n", .{});

    for (protected_paths.array.items) |item| {
        const path = item.object.get("path") orelse continue;
        const desc = item.object.get("description") orelse json.Value{ .string = "" };
        const ops = item.object.get("block_operations") orelse continue;

        std.debug.print("\n  📁 {s}\n", .{path.string});
        std.debug.print("     {s}\n", .{desc.string});
        std.debug.print("     Blocked: ", .{});
        for (ops.array.items, 0..) |op, i| {
            if (i > 0) std.debug.print(", ", .{});
            std.debug.print("{s}", .{op.string});
        }
        std.debug.print("\n", .{});
    }

    const whitelisted_paths = protection.object.get("whitelisted_paths") orelse return;
    std.debug.print("\nWhitelisted Paths ({d}):\n", .{whitelisted_paths.array.items.len});
    std.debug.print("─────────────────────────────────────────────────────────────\n", .{});

    for (whitelisted_paths.array.items) |item| {
        const path = item.object.get("path") orelse continue;
        const desc = item.object.get("description") orelse json.Value{ .string = "" };
        std.debug.print("  ✓ {s} - {s}\n", .{ path.string, desc.string });
    }

    std.debug.print("\n", .{});
}

fn cmdReload(_: std.mem.Allocator, _: Args) !void {
    std.debug.print("Sending SIGHUP to processes with libwarden.so loaded...\n", .{});

    // Find all processes using libwarden.so
    var dir = fs.openDirAbsolute("/proc", .{ .iterate = true }) catch {
        std.debug.print("Error: Cannot access /proc\n", .{});
        return;
    };
    defer dir.close();

    var reload_count: u32 = 0;
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        // Skip non-numeric entries (not PIDs)
        const pid = std.fmt.parseInt(i32, entry.name, 10) catch continue;

        // Check if process has libwarden.so loaded
        var path_buf: [256]u8 = undefined;
        const maps_path = std.fmt.bufPrint(&path_buf, "/proc/{d}/maps", .{pid}) catch continue;

        const maps_file = fs.openFileAbsolute(maps_path, .{}) catch continue;
        defer maps_file.close();

        var buf: [4096]u8 = undefined;
        const bytes_read = maps_file.read(&buf) catch continue;
        const content = buf[0..bytes_read];

        if (std.mem.indexOf(u8, content, "libwarden.so") != null) {
            // Send SIGHUP
            std.posix.kill(pid, std.posix.SIG.HUP) catch continue;
            std.debug.print("  Signaled PID {d}\n", .{pid});
            reload_count += 1;
        }
    }

    if (reload_count == 0) {
        std.debug.print("No processes found with libwarden.so loaded.\n", .{});
        std.debug.print("Note: New processes will load the updated config automatically.\n", .{});
    } else {
        std.debug.print("✓ Sent SIGHUP to {d} process(es)\n", .{reload_count});
    }
}

fn cmdStatus(allocator: std.mem.Allocator, args: Args) !void {
    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Guardian Shield V8.0 - Status                           ║\n", .{});
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});

    // Check if libwarden.so exists
    const lib_paths = [_][]const u8{
        "/usr/lib/libwarden.so",
        "/home/founder/zig_forge/zig-out/lib/libwarden.so",
    };

    std.debug.print("Library Status:\n", .{});
    for (lib_paths) |lib_path| {
        const stat = fs.cwd().statFile(lib_path) catch {
            std.debug.print("  ❌ {s} (not found)\n", .{lib_path});
            continue;
        };
        std.debug.print("  ✓ {s} ({d} bytes)\n", .{ lib_path, stat.size });
    }

    // Check config files
    std.debug.print("\nConfiguration Status:\n", .{});
    const config_paths = [_][]const u8{
        CONFIG_PATH,
        DEV_CONFIG_PATH,
    };

    for (config_paths) |config_path| {
        const stat = fs.cwd().statFile(config_path) catch {
            std.debug.print("  ❌ {s} (not found)\n", .{config_path});
            continue;
        };
        std.debug.print("  ✓ {s} ({d} bytes)\n", .{ config_path, stat.size });
    }

    // Count processes using libwarden
    std.debug.print("\nActive Processes:\n", .{});
    var process_count: u32 = 0;

    var dir = fs.openDirAbsolute("/proc", .{ .iterate = true }) catch {
        std.debug.print("  ❌ Cannot access /proc\n", .{});
        return;
    };
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        const pid = std.fmt.parseInt(i32, entry.name, 10) catch continue;

        var path_buf: [256]u8 = undefined;
        const maps_path = std.fmt.bufPrint(&path_buf, "/proc/{d}/maps", .{pid}) catch continue;

        const maps_file = fs.openFileAbsolute(maps_path, .{}) catch continue;
        defer maps_file.close();

        var buf: [8192]u8 = undefined;
        const bytes_read = maps_file.read(&buf) catch continue;
        const content = buf[0..bytes_read];

        if (std.mem.indexOf(u8, content, "libwarden.so") != null) {
            process_count += 1;
            if (args.verbose) {
                // Get process name
                var comm_path_buf: [256]u8 = undefined;
                const comm_path = std.fmt.bufPrint(&comm_path_buf, "/proc/{d}/comm", .{pid}) catch continue;
                const comm_file = fs.openFileAbsolute(comm_path, .{}) catch continue;
                defer comm_file.close();

                var comm_buf: [256]u8 = undefined;
                const comm_len = comm_file.read(&comm_buf) catch continue;
                const comm = std.mem.trimRight(u8, comm_buf[0..comm_len], "\n");
                std.debug.print("  PID {d}: {s}\n", .{ pid, comm });
            }
        }
    }

    std.debug.print("  🛡️  {d} process(es) protected by Guardian Shield\n", .{process_count});

    // Show config summary
    var parsed = loadConfig(allocator, args.config_file) catch {
        return;
    };
    defer parsed.deinit();

    const root = parsed.value.object;
    const protection = root.get("protection") orelse return;
    const protected_paths = protection.object.get("protected_paths") orelse return;
    const whitelisted_paths = protection.object.get("whitelisted_paths") orelse return;

    std.debug.print("\nConfiguration Summary:\n", .{});
    std.debug.print("  Protected paths:   {d}\n", .{protected_paths.array.items.len});
    std.debug.print("  Whitelisted paths: {d}\n", .{whitelisted_paths.array.items.len});
    std.debug.print("\n", .{});
}

fn cmdTest(allocator: std.mem.Allocator, args: Args) !void {
    const path = args.path orelse {
        std.debug.print("Error: Path required\n", .{});
        std.debug.print("Usage: wardenctl test /some/path [operation]\n", .{});
        return;
    };

    const operation = args.operation orelse "all";

    std.debug.print("\nTesting path: {s}\n", .{path});
    std.debug.print("Operation: {s}\n\n", .{operation});

    var parsed = loadConfig(allocator, args.config_file) catch |err| {
        std.debug.print("Error loading config: {any}\n", .{err});
        return;
    };
    defer parsed.deinit();

    const root = parsed.value.object;
    const protection = root.get("protection") orelse return;
    const protected_paths = protection.object.get("protected_paths") orelse return;
    const whitelisted_paths = protection.object.get("whitelisted_paths") orelse return;

    // Check if whitelisted
    for (whitelisted_paths.array.items) |item| {
        const whitelist_path = item.object.get("path") orelse continue;
        if (std.mem.startsWith(u8, path, whitelist_path.string)) {
            std.debug.print("✓ Path is WHITELISTED (via {s})\n", .{whitelist_path.string});
            std.debug.print("  All operations ALLOWED\n", .{});
            return;
        }
    }

    // Check if protected
    for (protected_paths.array.items) |item| {
        const protected_path = item.object.get("path") orelse continue;
        if (std.mem.startsWith(u8, path, protected_path.string)) {
            const ops = item.object.get("block_operations") orelse continue;

            std.debug.print("🛡️  Path is PROTECTED (via {s})\n\n", .{protected_path.string});

            if (std.mem.eql(u8, operation, "all")) {
                std.debug.print("Blocked operations:\n", .{});
                for (ops.array.items) |op| {
                    std.debug.print("  ❌ {s}\n", .{op.string});
                }
            } else {
                // Check specific operation
                var blocked = false;
                for (ops.array.items) |op| {
                    if (std.mem.eql(u8, op.string, operation)) {
                        blocked = true;
                        break;
                    }
                }
                if (blocked) {
                    std.debug.print("❌ Operation '{s}' would be BLOCKED\n", .{operation});
                } else {
                    std.debug.print("✓ Operation '{s}' would be ALLOWED\n", .{operation});
                }
            }
            return;
        }
    }

    std.debug.print("✓ Path is NOT PROTECTED\n", .{});
    std.debug.print("  All operations ALLOWED\n", .{});
}

fn printHelp() void {
    std.debug.print(
        \\
        \\wardenctl - Guardian Shield V8.0 Control CLI
        \\
        \\Usage: wardenctl <command> [options]
        \\
        \\Commands:
        \\  add       Add a protected path
        \\  remove    Remove a protected path (requires sudo)
        \\  list      List all protected paths
        \\  reload    Signal processes to reload config
        \\  status    Show shield status
        \\  test      Test if a path/operation would be blocked
        \\  help      Show this help
        \\  version   Show version
        \\
        \\Options for 'add':
        \\  -p, --path <path>   Path to protect (use "." for current directory)
        \\  -t, --template <t>  Protection template (safe, dev, readonly, production)
        \\  -d, --description   Description for the path
        \\  --no-delete         Block unlink, unlinkat, rmdir
        \\  --no-move           Block rename
        \\  --no-truncate       Block truncate
        \\  --no-write          Block open for writing
        \\  --no-symlink        Block symlink creation
        \\  --no-link           Block hardlink creation
        \\  --no-mkdir          Block directory creation
        \\  -r, --read-only     Block all write/modify operations
        \\
        \\Templates:
        \\  safe        --no-delete --no-move (prevent accidental damage)
        \\  dev         --no-delete --no-move --no-truncate (development)
        \\  readonly    --read-only (full immutability)
        \\  production  --read-only (maximum security)
        \\
        \\General Options:
        \\  -c, --config <file>  Config file path
        \\  -v, --verbose        Verbose output
        \\
        \\Examples:
        \\  wardenctl add -p . --template dev        # Protect current directory
        \\  wardenctl add -p . --template safe       # Basic protection
        \\  wardenctl add -p /home/user/project -r   # Full read-only
        \\  wardenctl add /opt/data --no-delete --no-move
        \\  wardenctl remove /home/user/project
        \\  wardenctl list
        \\  wardenctl test /etc/passwd delete
        \\  wardenctl reload
        \\
    , .{});
}

// ============================================================
// Main
// ============================================================

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try parseArgs(allocator);

    switch (args.command) {
        .add => try cmdAdd(allocator, args),
        .remove => try cmdRemove(allocator, args),
        .list => try cmdList(allocator, args),
        .reload => try cmdReload(allocator, args),
        .status => try cmdStatus(allocator, args),
        .@"test" => try cmdTest(allocator, args),
        .version => std.debug.print("wardenctl v{s}\n", .{VERSION}),
        .help => printHelp(),
    }
}
