// Copyright (c) 2025 QUANTUM ENCODING LTD
// Minimal HTTP Echo Server for Benchmarking
//
// This server responds instantly with minimal processing to measure
// quantum-curl's true throughput without network/server bottlenecks.

const std = @import("std");
const net = std.net;
const http = std.http;

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

    const address = net.Address.initIp4(.{ 127, 0, 0, 1 }, port);

    var server = try address.listen(.{
        .reuse_address = true,
    });
    defer server.deinit();

    std.debug.print("Echo server listening on http://127.0.0.1:{d}\n", .{port});
    std.debug.print("Press Ctrl+C to stop\n\n", .{});

    var request_count: u64 = 0;
    const start_time = std.time.milliTimestamp();

    while (true) {
        var conn = server.accept() catch |err| {
            std.debug.print("Accept error: {}\n", .{err});
            continue;
        };

        request_count += 1;

        // Simple HTTP response - minimal processing
        const response =
            "HTTP/1.1 200 OK\r\n" ++
            "Content-Type: application/json\r\n" ++
            "Content-Length: 23\r\n" ++
            "Connection: close\r\n" ++
            "\r\n" ++
            "{\"status\":\"ok\",\"id\":1}";

        // Read request (drain it)
        var buf: [4096]u8 = undefined;
        _ = conn.stream.read(&buf) catch {};

        // Send response
        _ = conn.stream.writeAll(response) catch {};
        conn.stream.close();

        // Print stats every 1000 requests
        if (request_count % 1000 == 0) {
            const elapsed_ms = std.time.milliTimestamp() - start_time;
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
