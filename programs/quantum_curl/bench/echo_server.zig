// Copyright (c) 2025 QUANTUM ENCODING LTD
// Ultra-High-Performance HTTP Echo Server for Benchmarking
//
// Single-threaded non-blocking server using epoll for maximum throughput.
// Optimized for raw connection handling speed.

const std = @import("std");
const posix = std.posix;
const linux = std.os.linux;

// Pre-built HTTP response - minimal overhead
const RESPONSE =
    "HTTP/1.1 200 OK\r\n" ++
    "Content-Type: application/json\r\n" ++
    "Content-Length: 23\r\n" ++
    "Connection: close\r\n" ++
    "\r\n" ++
    "{\"status\":\"ok\",\"id\":1}";

var request_count: u64 = 0;
var start_instant: std.time.Instant = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const port: u16 = if (args.len > 1)
        try std.fmt.parseInt(u16, args[1], 10)
    else
        8888;

    // Create listening socket
    const listen_fd = try posix.socket(posix.AF.INET, posix.SOCK.STREAM | posix.SOCK.NONBLOCK, 0);
    defer posix.close(listen_fd);

    // Set SO_REUSEADDR and SO_REUSEPORT
    const optval: u32 = 1;
    try posix.setsockopt(listen_fd, posix.SOL.SOCKET, posix.SO.REUSEADDR, std.mem.asBytes(&optval));

    // Bind
    const addr = posix.sockaddr.in{
        .family = posix.AF.INET,
        .port = std.mem.nativeToBig(u16, port),
        .addr = 0, // INADDR_ANY
    };
    try posix.bind(listen_fd, @ptrCast(&addr), @sizeOf(@TypeOf(addr)));

    // Listen with maximum backlog
    try posix.listen(listen_fd, 65535);

    std.debug.print("Echo server listening on http://127.0.0.1:{d}\n", .{port});
    std.debug.print("Mode: Single-threaded epoll event loop\n", .{});
    std.debug.print("Press Ctrl+C to stop\n\n", .{});

    start_instant = std.time.Instant.now() catch unreachable;

    // Create epoll instance
    const epoll_fd = try posix.epoll_create1(0);
    defer posix.close(epoll_fd);

    // Add listener to epoll
    var listen_event = linux.epoll_event{
        .events = linux.EPOLL.IN,
        .data = .{ .fd = listen_fd },
    };
    try posix.epoll_ctl(epoll_fd, linux.EPOLL.CTL_ADD, listen_fd, &listen_event);

    var events: [1024]linux.epoll_event = undefined;

    // Event loop
    while (true) {
        const nfds = posix.epoll_wait(epoll_fd, &events, -1);

        for (events[0..@intCast(nfds)]) |event| {
            if (event.data.fd == listen_fd) {
                // Accept new connections
                while (true) {
                    const client_fd = posix.accept(listen_fd, null, null, posix.SOCK.NONBLOCK) catch break;

                    // Handle immediately - read request
                    var buf: [4096]u8 = undefined;
                    _ = posix.read(client_fd, &buf) catch {
                        posix.close(client_fd);
                        continue;
                    };

                    // Send response
                    _ = posix.write(client_fd, RESPONSE) catch {};
                    posix.close(client_fd);

                    request_count += 1;

                    // Print stats every 100000 requests
                    if (request_count % 100000 == 0) {
                        const now = std.time.Instant.now() catch continue;
                        const elapsed_ns = now.since(start_instant);
                        const elapsed_ms = elapsed_ns / std.time.ns_per_ms;
                        const rps = if (elapsed_ms > 0)
                            @as(f64, @floatFromInt(request_count)) / (@as(f64, @floatFromInt(elapsed_ms)) / 1000.0)
                        else
                            0;
                        std.debug.print("Requests: {d} | Elapsed: {d}ms | RPS: {d:.0}\n", .{
                            request_count,
                            elapsed_ms,
                            rps,
                        });
                    }
                }
            }
        }
    }
}
