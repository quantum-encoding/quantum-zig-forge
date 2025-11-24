// Copyright (c) 2025 QUANTUM ENCODING LTD
// Minimal HTTP Echo Server for Benchmarking
//
// This server responds instantly with minimal processing to measure
// quantum-curl's true throughput without network/server bottlenecks.

const std = @import("std");
const posix = std.posix;

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

    // Create socket
    const sockfd = try posix.socket(posix.AF.INET, posix.SOCK.STREAM, 0);
    defer posix.close(sockfd);

    // Set SO_REUSEADDR
    const optval: u32 = 1;
    try posix.setsockopt(sockfd, posix.SOL.SOCKET, posix.SO.REUSEADDR, std.mem.asBytes(&optval));

    // Bind
    const addr = posix.sockaddr.in{
        .family = posix.AF.INET,
        .port = std.mem.nativeToBig(u16, port),
        .addr = 0, // INADDR_ANY
    };
    try posix.bind(sockfd, @ptrCast(&addr), @sizeOf(@TypeOf(addr)));

    // Listen
    try posix.listen(sockfd, 128);

    std.debug.print("Echo server listening on http://127.0.0.1:{d}\n", .{port});
    std.debug.print("Press Ctrl+C to stop\n\n", .{});

    var request_count: u64 = 0;
    const start_instant = std.time.Instant.now() catch unreachable;

    // Pre-build response
    const response =
        "HTTP/1.1 200 OK\r\n" ++
        "Content-Type: application/json\r\n" ++
        "Content-Length: 23\r\n" ++
        "Connection: close\r\n" ++
        "\r\n" ++
        "{\"status\":\"ok\",\"id\":1}";

    while (true) {
        const client_fd = posix.accept(sockfd, null, null) catch |err| {
            std.debug.print("Accept error: {}\n", .{err});
            continue;
        };

        request_count += 1;

        // Read request (drain it)
        var buf: [4096]u8 = undefined;
        _ = posix.read(client_fd, &buf) catch {};

        // Send response
        _ = posix.write(client_fd, response) catch {};
        posix.close(client_fd);

        // Print stats every 1000 requests
        if (request_count % 1000 == 0) {
            const now = std.time.Instant.now() catch unreachable;
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
