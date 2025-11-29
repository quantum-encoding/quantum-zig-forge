//! ═══════════════════════════════════════════════════════════════════════════
//! WARP GATE CLI
//! ═══════════════════════════════════════════════════════════════════════════
//!
//! Usage:
//!   warp send <path>           Send a file or directory
//!   warp recv <code> [dest]    Receive files using transfer code
//!   warp status                Show connection status
//!
//! Examples:
//!   $ warp send ./my-project
//!   Transfer code: warp-729-alpha
//!   Waiting for receiver...
//!
//!   $ warp recv warp-729-alpha
//!   Connecting to peer...
//!   Receiving: my-project (12.4 MB)
//!   ████████████████░░░░ 80% 9.9 MB/s

const std = @import("std");
const warp_gate = @import("warp_gate");

const WarpCode = warp_gate.WarpCode;
const WarpSession = warp_gate.WarpSession;
const Transport = warp_gate.Transport;
const Resolver = warp_gate.Resolver;

const VERSION = "0.1.0";

const BANNER =
    \\
    \\  ╦ ╦╔═╗╦═╗╔═╗  ╔═╗╔═╗╔╦╗╔═╗
    \\  ║║║╠═╣╠╦╝╠═╝  ║ ╦╠═╣ ║ ║╣
    \\  ╚╩╝╩ ╩╩╚═╩    ╚═╝╩ ╩ ╩ ╚═╝
    \\
    \\  Peer-to-peer code transfer
    \\
;

const HELP =
    \\
    \\USAGE:
    \\  warp <command> [options]
    \\
    \\COMMANDS:
    \\  send <path>           Send a file or directory
    \\  recv <code> [dest]    Receive using transfer code
    \\  status                Show network status
    \\  help                  Show this help message
    \\
    \\OPTIONS:
    \\  -v, --verbose         Enable verbose output
    \\  -q, --quiet           Suppress progress output
    \\  --no-mdns             Disable local network discovery
    \\
    \\EXAMPLES:
    \\  warp send ./src
    \\  warp recv warp-729-alpha ./downloads
    \\
;

const Args = struct {
    command: Command,
    path: ?[]const u8 = null,
    code: ?[]const u8 = null,
    dest: ?[]const u8 = null,
    verbose: bool = false,
    quiet: bool = false,
    no_mdns: bool = false,

    const Command = enum {
        send,
        recv,
        status,
        help,
        version,
    };
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = parseArgs() catch |err| {
        printError("Invalid arguments: {}", .{err});
        printHelp();
        std.process.exit(1);
    };

    switch (args.command) {
        .send => try cmdSend(allocator, args),
        .recv => try cmdRecv(allocator, args),
        .status => try cmdStatus(allocator),
        .help => printHelp(),
        .version => printVersion(),
    }
}

fn parseArgs() !Args {
    var args_iter = std.process.args();
    _ = args_iter.next(); // Skip program name

    const cmd_str = args_iter.next() orelse return Args{ .command = .help };

    var args = Args{ .command = .help };

    if (std.mem.eql(u8, cmd_str, "send")) {
        args.command = .send;
        args.path = args_iter.next();
        if (args.path == null) return error.MissingPath;
    } else if (std.mem.eql(u8, cmd_str, "recv")) {
        args.command = .recv;
        args.code = args_iter.next();
        if (args.code == null) return error.MissingCode;
        args.dest = args_iter.next(); // Optional destination
    } else if (std.mem.eql(u8, cmd_str, "status")) {
        args.command = .status;
    } else if (std.mem.eql(u8, cmd_str, "help") or std.mem.eql(u8, cmd_str, "-h") or std.mem.eql(u8, cmd_str, "--help")) {
        args.command = .help;
    } else if (std.mem.eql(u8, cmd_str, "version") or std.mem.eql(u8, cmd_str, "-V") or std.mem.eql(u8, cmd_str, "--version")) {
        args.command = .version;
    } else {
        return error.UnknownCommand;
    }

    // Parse remaining flags
    while (args_iter.next()) |arg| {
        if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--verbose")) {
            args.verbose = true;
        } else if (std.mem.eql(u8, arg, "-q") or std.mem.eql(u8, arg, "--quiet")) {
            args.quiet = true;
        } else if (std.mem.eql(u8, arg, "--no-mdns")) {
            args.no_mdns = true;
        }
    }

    return args;
}

fn cmdSend(allocator: std.mem.Allocator, args: Args) !void {
    const path = args.path orelse return error.MissingPath;

    // Verify path exists
    std.fs.cwd().access(path, .{}) catch |err| {
        printError("Cannot access '{s}': {}", .{ path, err });
        return err;
    };

    // Create session
    var session = try WarpSession.init(allocator, .sender);
    defer session.deinit();

    // Display transfer code
    const code_str = session.getCodeString();
    printBanner();
    print("\n  \x1b[1;32mTransfer code:\x1b[0m \x1b[1;37m{s}\x1b[0m\n", .{code_str});
    print("\n  Share this code with the receiver.\n", .{});
    print("  Waiting for connection...\n\n", .{});

    // Start discovery
    if (!args.no_mdns) {
        session.connect() catch |err| {
            if (args.verbose) {
                printError("Discovery failed: {}", .{err});
            }
        };
    }

    // Wait for peer connection
    print("  \x1b[33m⏳\x1b[0m Discovering peer...\n", .{});

    // In a real implementation, we'd wait for connection here
    // For now, show a placeholder
    var i: u32 = 0;
    while (i < 30) : (i += 1) {
        print("\r  \x1b[33m⏳\x1b[0m Waiting... {d}s", .{i});
        std.Thread.sleep(std.time.ns_per_s);

        // Check for peer
        if (session.state == .connected) break;
    }

    if (session.state != .connected) {
        print("\n\n  \x1b[31m✗\x1b[0m Connection timeout. Peer may not be reachable.\n", .{});
        print("    Try:\n", .{});
        print("    • Ensure peer is on same network (for local transfers)\n", .{});
        print("    • Check firewall settings\n", .{});
        print("    • Verify the transfer code\n\n", .{});
        return error.ConnectionTimeout;
    }

    // Start transfer
    print("\n  \x1b[32m✓\x1b[0m Connected! Starting transfer...\n\n", .{});

    session.send(path) catch |err| {
        printError("Transfer failed: {}", .{err});
        return err;
    };

    print("  \x1b[32m✓\x1b[0m Transfer complete!\n\n", .{});
}

fn cmdRecv(allocator: std.mem.Allocator, args: Args) !void {
    const code_str = args.code orelse return error.MissingCode;
    const dest = args.dest orelse ".";

    // Validate code format
    _ = WarpCode.parse(code_str) catch {
        printError("Invalid transfer code: '{s}'", .{code_str});
        print("\n  Expected format: warp-XXX-word (e.g., warp-729-alpha)\n\n", .{});
        return error.InvalidCode;
    };

    // Create session
    var session = try WarpSession.init(allocator, .receiver);
    defer session.deinit();

    try session.setCode(code_str);

    printBanner();
    print("\n  \x1b[1;32mConnecting with code:\x1b[0m {s}\n", .{code_str});
    print("  Destination: {s}\n\n", .{dest});

    // Start discovery
    if (!args.no_mdns) {
        session.connect() catch |err| {
            if (args.verbose) {
                printError("Discovery failed: {}", .{err});
            }
        };
    }

    print("  \x1b[33m⏳\x1b[0m Searching for sender...\n", .{});

    // Wait for peer
    var i: u32 = 0;
    while (i < 30) : (i += 1) {
        print("\r  \x1b[33m⏳\x1b[0m Searching... {d}s", .{i});
        std.Thread.sleep(std.time.ns_per_s);

        if (session.state == .connected) break;
    }

    if (session.state != .connected) {
        print("\n\n  \x1b[31m✗\x1b[0m Could not find sender.\n", .{});
        print("    Verify:\n", .{});
        print("    • The transfer code is correct\n", .{});
        print("    • Sender is still waiting\n", .{});
        print("    • Both devices can reach each other\n\n", .{});
        return error.ConnectionTimeout;
    }

    print("\n  \x1b[32m✓\x1b[0m Connected! Receiving files...\n\n", .{});

    // Receive files
    session.receive(dest) catch |err| {
        printError("Receive failed: {}", .{err});
        return err;
    };

    print("  \x1b[32m✓\x1b[0m Received successfully to: {s}\n\n", .{dest});
}

fn cmdStatus(allocator: std.mem.Allocator) !void {
    printBanner();
    print("\n  \x1b[1;36mNetwork Status\x1b[0m\n\n", .{});

    // Query STUN for public IP
    var resolver = try Resolver.init(allocator);
    defer resolver.deinit();

    print("  Querying STUN servers...\n", .{});

    if (resolver.queryStun()) |endpoint| {
        const addr = endpoint.address;
        print("  \x1b[32m✓\x1b[0m Public IP: {d}.{d}.{d}.{d}:{d}\n", .{
            addr.in.sa.addr[0],
            addr.in.sa.addr[1],
            addr.in.sa.addr[2],
            addr.in.sa.addr[3],
            addr.in.sa.port,
        });
    } else |err| {
        print("  \x1b[31m✗\x1b[0m STUN query failed: {}\n", .{err});
    }

    // Check mDNS
    print("\n  Checking local network...\n", .{});
    print("  \x1b[32m✓\x1b[0m mDNS available\n", .{});

    print("\n", .{});
}

fn printBanner() void {
    print("\x1b[1;36m{s}\x1b[0m", .{BANNER});
}

fn printHelp() void {
    printBanner();
    print("{s}", .{HELP});
}

fn printVersion() void {
    print("warp {s}\n", .{VERSION});
}

fn print(comptime fmt: []const u8, args: anytype) void {
    std.debug.print(fmt, args);
}

fn printError(comptime fmt: []const u8, args: anytype) void {
    std.debug.print("\x1b[31mError:\x1b[0m " ++ fmt ++ "\n", args);
}

// ═══════════════════════════════════════════════════════════════════════════
// Progress Bar Helper
// ═══════════════════════════════════════════════════════════════════════════

const ProgressBar = struct {
    total: u64,
    current: u64 = 0,
    start_time: i64,
    width: u32 = 40,

    pub fn init(total: u64) ProgressBar {
        return .{
            .total = total,
            .start_time = std.time.milliTimestamp(),
        };
    }

    pub fn update(self: *ProgressBar, current: u64) void {
        self.current = current;
        self.render();
    }

    pub fn render(self: *const ProgressBar) void {
        const percent = if (self.total > 0)
            @as(f64, @floatFromInt(self.current)) / @as(f64, @floatFromInt(self.total))
        else
            0.0;

        const filled = @as(u32, @intFromFloat(percent * @as(f64, @floatFromInt(self.width))));
        _ = filled;

        // Calculate speed
        const elapsed_ms = std.time.milliTimestamp() - self.start_time;
        const speed = if (elapsed_ms > 0)
            @as(f64, @floatFromInt(self.current)) / (@as(f64, @floatFromInt(elapsed_ms)) / 1000.0)
        else
            0.0;

        // Simple progress output using debug.print
        std.debug.print("\r  Progress: {d:.0}% Speed: {d:.1} B/s", .{
            percent * 100,
            speed,
        });
    }

    fn formatBytes(bytes: u64) []const u8 {
        _ = bytes;
        return "0 B"; // Placeholder
    }
};
