// Copyright (c) 2025 QUANTUM ENCODING LTD
// Multi-Threaded HTTP Echo Server for Benchmarking
//
// This server uses a thread pool to handle high concurrency loads,
// measuring quantum-curl's true throughput without server bottlenecks.

const std = @import("std");
const posix = std.posix;

const WORKER_COUNT = 256; // Thread pool size for high concurrency

// Pre-built HTTP response - minimal overhead
const RESPONSE =
    "HTTP/1.1 200 OK\r\n" ++
    "Content-Type: application/json\r\n" ++
    "Content-Length: 23\r\n" ++
    "Connection: close\r\n" ++
    "\r\n" ++
    "{\"status\":\"ok\",\"id\":1}";

var request_count: std.atomic.Value(u64) = std.atomic.Value(u64).init(0);
var start_instant: std.time.Instant = undefined;

fn handleClient(client_fd: posix.socket_t) void {
    defer posix.close(client_fd);

    // Read request (drain it)
    var buf: [4096]u8 = undefined;
    _ = posix.read(client_fd, &buf) catch return;

    // Send response
    _ = posix.write(client_fd, RESPONSE) catch return;

    // Increment counter atomically
    const count = request_count.fetchAdd(1, .monotonic) + 1;

    // Print stats every 1000 requests
    if (count % 1000 == 0) {
        const now = std.time.Instant.now() catch return;
        const elapsed_ns = now.since(start_instant);
        const elapsed_ms = elapsed_ns / std.time.ns_per_ms;
        const rps = if (elapsed_ms > 0)
            @as(f64, @floatFromInt(count)) / (@as(f64, @floatFromInt(elapsed_ms)) / 1000.0)
        else
            0;
        std.debug.print("Requests: {d} | Elapsed: {d}ms | RPS: {d:.0}\n", .{
            count,
            elapsed_ms,
            rps,
        });
    }
}

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

    // Listen with large backlog for high concurrency
    try posix.listen(sockfd, 4096);

    std.debug.print("Echo server listening on http://127.0.0.1:{d}\n", .{port});
    std.debug.print("Thread pool: {d} workers\n", .{WORKER_COUNT});
    std.debug.print("Press Ctrl+C to stop\n\n", .{});

    start_instant = std.time.Instant.now() catch unreachable;

    // Create thread pool
    var pool: std.Thread.Pool = undefined;
    try pool.init(.{
        .allocator = allocator,
        .n_jobs = WORKER_COUNT,
    });
    defer pool.deinit();

    while (true) {
        const client_fd = posix.accept(sockfd, null, null, 0) catch |err| {
            std.debug.print("Accept error: {}\n", .{err});
            continue;
        };

        // Spawn worker thread to handle client
        pool.spawn(handleClient, .{client_fd}) catch {
            // If pool is full, handle synchronously
            handleClient(client_fd);
        };
    }
}
