const std = @import("std");
const sha256d = @import("crypto/sha256d.zig");

pub fn main() !void {
    const stdout_file = std.fs.File.stdout();
    var stdout_buf: [4096]u8 = undefined;
    var stdout_writer = stdout_file.writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.writeAll(
        \\
        \\═══════════════════════════════════════
        \\  SHA256d Benchmark Suite
        \\═══════════════════════════════════════
        \\
        \\
    );

    // Benchmark parameters
    const test_sizes = [_]u64{ 100_000, 1_000_000, 10_000_000 };

    for (test_sizes) |iterations| {
        try benchmarkScalar(stdout, iterations);
    }

    try stdout.writeAll("\n✨ Benchmark complete!\n");

    // Flush before exit
    try std.Io.Writer.flush(&stdout_writer.interface);
}

fn benchmarkScalar(writer: anytype, iterations: u64) !void {
    var input = [_]u8{0} ** 80;
    var output: [32]u8 = undefined;

    // Warmup
    var i: u64 = 0;
    while (i < 1000) : (i += 1) {
        sha256d.sha256d(&input, &output);
    }

    // Actual benchmark
    var timer = try std.time.Timer.start();
    const start = timer.read();

    i = 0;
    while (i < iterations) : (i += 1) {
        sha256d.sha256d(&input, &output);
    }

    const elapsed_ns = timer.read() - start;
    const elapsed_s = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0;
    const hashes_per_sec = @as(f64, @floatFromInt(iterations)) / elapsed_s;
    const mhashes_per_sec = hashes_per_sec / 1_000_000.0;

    try writer.print(
        \\📊 Scalar Implementation
        \\   Iterations: {d}
        \\   Time:       {d:.3}s
        \\   Hashrate:   {d:.2} MH/s
        \\   ns/hash:    {d:.2}
        \\
        \\
    , .{
        iterations,
        elapsed_s,
        mhashes_per_sec,
        @as(f64, @floatFromInt(elapsed_ns)) / @as(f64, @floatFromInt(iterations)),
    });
}
