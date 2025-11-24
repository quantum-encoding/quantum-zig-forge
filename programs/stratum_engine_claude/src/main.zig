//! Zig Stratum Engine
//! High-performance Bitcoin Stratum mining client showcasing Zig 0.16 capabilities
//!
//! Architecture:
//! - Zero-copy networking (io_uring on Linux)
//! - SIMD-optimized SHA256d (AVX2/AVX-512)
//! - Cache-aware thread pinning
//! - Lock-free work distribution

const std = @import("std");
const types = @import("stratum/types.zig");
const dispatch = @import("crypto/dispatch.zig");
const MiningEngine = @import("engine.zig").MiningEngine;
const EngineConfig = @import("engine.zig").EngineConfig;

const VERSION = "0.1.0";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout_file = std.fs.File.stdout();
    var stdout_buf: [4096]u8 = undefined;
    var stdout_writer = stdout_file.writer(&stdout_buf);
    const stdout = &stdout_writer.interface;

    try stdout.print(
        \\
        \\╔═══════════════════════════════════════════════════╗
        \\║   ZIG STRATUM ENGINE v{s}                    ║
        \\║   High-Performance Bitcoin Mining Client         ║
        \\║   Built with Zig 0.16 - Bleeding Edge            ║
        \\╚═══════════════════════════════════════════════════╝
        \\
        \\
    , .{VERSION});

    // Parse command line args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 4) {
        try printUsage(stdout);
        return;
    }

    const pool_url = args[1];
    const username = args[2];
    const password = args[3];

    try stdout.print("📡 Pool: {s}\n", .{pool_url});
    try stdout.print("👤 Worker: {s}\n\n", .{username});

    // Detect CPU capabilities
    try detectCPUCapabilities(stdout);
    try stdout.print("\n", .{});

    // Flush initial output
    try std.Io.Writer.flush(&stdout_writer.interface);

    // Check for benchmark mode
    if (std.mem.eql(u8, pool_url, "--benchmark")) {
        try runBenchmark(stdout, allocator);
        try std.Io.Writer.flush(&stdout_writer.interface);
        return;
    }

    // Create and run mining engine
    const cpu_count = try std.Thread.getCpuCount();

    const config = EngineConfig{
        .pool_url = pool_url,
        .username = username,
        .password = password,
        .num_threads = @intCast(cpu_count),
    };

    var engine = try MiningEngine.init(allocator, config);
    defer engine.deinit();

    try engine.run();
}

fn printUsage(writer: anytype) !void {
    try writer.writeAll(
        \\Usage: stratum-engine <pool_url> <username> <password>
        \\
        \\Arguments:
        \\  pool_url   Mining pool (e.g., stratum+tcp://solo.ckpool.org:3333)
        \\  username   Worker name (usually wallet.workername)
        \\  password   Worker password (often just "x")
        \\
        \\Example:
        \\  stratum-engine stratum+tcp://solo.ckpool.org:3333 bc1qminer.worker1 x
        \\
        \\Options:
        \\  --threads N     Number of mining threads (default: CPU cores)
        \\  --cpu-affinity  Pin threads to physical cores
        \\  --benchmark     Run SHA256d benchmark and exit
        \\
    );
}

fn detectCPUCapabilities(writer: anytype) !void {
    const cpu_count = try std.Thread.getCpuCount();
    try writer.print("🖥️  CPU Cores: {}\n", .{cpu_count});

    // Initialize dispatcher and detect SIMD level
    dispatch.init();
    const simd_level = dispatch.getLevel();

    try writer.writeAll("📊 CPU Features:\n");
    try writer.print("   ✅ SIMD: {s}\n", .{simd_level.toString()});

    // Zig 0.16 - using compile-time CPU features
    const features = @import("builtin").cpu.features;

    if (features.isEnabled(@intFromEnum(std.Target.x86.Feature.sse4_2))) {
        try writer.writeAll("   ✅ SSE4.2\n");
    }
}

fn runBenchmark(writer: anytype, allocator: std.mem.Allocator) !void {
    _ = allocator;

    try writer.writeAll("🔥 Running SHA256d SIMD benchmark...\n\n");

    const hasher = dispatch.Hasher.init();
    const simd_level = dispatch.getLevel();

    try writer.print("Active SIMD Level: {s}\n", .{simd_level.toString()});
    try writer.print("Batch Size: {}\n\n", .{hasher.getBatchSize()});

    const iterations: u64 = 1_000_000;

    // Benchmark based on detected SIMD level
    switch (simd_level) {
        .avx512 => {
            try writer.writeAll("🚀 Benchmarking AVX-512 (16-way parallel)...\n");
            var headers: [16][80]u8 = undefined;
            var hashes: [16][32]u8 = undefined;

            for (0..16) |i| {
                @memset(&headers[i], 0);
            }

            var timer = try std.time.Timer.start();
            const start = timer.read();

            var i: u64 = 0;
            while (i < iterations / 16) : (i += 1) {
                hasher.hash16(&headers, &hashes);
            }

            const elapsed = timer.read() - start;
            const total_hashes = iterations;
            const hashes_per_sec = @as(f64, @floatFromInt(total_hashes)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0);

            try writer.print("   ✅ {d:.2} MH/s ({} hashes in {d:.2}s)\n", .{
                hashes_per_sec / 1_000_000.0,
                total_hashes,
                @as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0,
            });

            try writer.print("\n🎯 Hash sample: ", .{});
            for (hashes[0][0..8]) |byte| {
                try writer.print("{x:0>2}", .{byte});
            }
            try writer.writeAll("...\n\n");
        },
        .avx2 => {
            try writer.writeAll("🚀 Benchmarking AVX2 (8-way parallel)...\n");
            var headers: [8][80]u8 = undefined;
            var hashes: [8][32]u8 = undefined;

            for (0..8) |i| {
                @memset(&headers[i], 0);
            }

            var timer = try std.time.Timer.start();
            const start = timer.read();

            var i: u64 = 0;
            while (i < iterations / 8) : (i += 1) {
                hasher.hash8(&headers, &hashes);
            }

            const elapsed = timer.read() - start;
            const total_hashes = iterations;
            const hashes_per_sec = @as(f64, @floatFromInt(total_hashes)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0);

            try writer.print("   ✅ {d:.2} MH/s ({} hashes in {d:.2}s)\n", .{
                hashes_per_sec / 1_000_000.0,
                total_hashes,
                @as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0,
            });

            try writer.print("\n🎯 Hash sample: ", .{});
            for (hashes[0][0..8]) |byte| {
                try writer.print("{x:0>2}", .{byte});
            }
            try writer.writeAll("...\n\n");
        },
        .scalar => {
            try writer.writeAll("⚠️  Benchmarking scalar (no SIMD)...\n");
            var header = [_]u8{0} ** 80;
            var hash: [32]u8 = undefined;

            var timer = try std.time.Timer.start();
            const start = timer.read();

            var i: u64 = 0;
            while (i < iterations) : (i += 1) {
                hasher.hashOne(&header, &hash);
            }

            const elapsed = timer.read() - start;
            const hashes_per_sec = @as(f64, @floatFromInt(iterations)) / (@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0);

            try writer.print("   ✅ {d:.2} MH/s ({} hashes in {d:.2}s)\n", .{
                hashes_per_sec / 1_000_000.0,
                iterations,
                @as(f64, @floatFromInt(elapsed)) / 1_000_000_000.0,
            });

            try writer.print("\n🎯 Hash sample: ", .{});
            for (hash[0..8]) |byte| {
                try writer.print("{x:0>2}", .{byte});
            }
            try writer.writeAll("...\n\n");
        },
    }
}

test "basic functionality" {
    const testing = std.testing;

    // Test target calculation
    const target = types.Target.fromNBits(0x1d00ffff);
    try testing.expect(target.bits.len == 32);

    // Test method parsing
    const method = types.Method.fromString("mining.subscribe");
    try testing.expectEqual(types.Method.mining_subscribe, method);
}
