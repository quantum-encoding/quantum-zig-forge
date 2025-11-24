//! Simple test for Bitcoin P2P mempool connection
const std = @import("std");
const MempoolMonitor = @import("bitcoin/mempool.zig").MempoolMonitor;
const formatHash = @import("bitcoin/mempool.zig").formatHash;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        std.debug.print("Usage: {s} <bitcoin_host> <bitcoin_port>\n", .{args[0]});
        std.debug.print("Example: {s} 167.224.189.201 8333\n", .{args[0]});
        return;
    }

    const btc_host = args[1];
    const btc_port = try std.fmt.parseInt(u16, args[2], 10);

    std.debug.print("╔═════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║   Bitcoin P2P Mempool Monitor Test             ║\n", .{});
    std.debug.print("╚═════════════════════════════════════════════════╝\n\n", .{});

    std.debug.print("🔗 Connecting to {s}:{}...\n", .{ btc_host, btc_port });

    var monitor = try MempoolMonitor.init(allocator, btc_host, btc_port);
    defer monitor.deinit();

    // Set callback to print transaction hashes
    monitor.setCallback(onTransactionSeen);

    std.debug.print("✅ Connected! Monitoring mempool for 60 seconds...\n\n", .{});

    // Run for 60 seconds
    const start = std.posix.clock_gettime(.MONOTONIC) catch |err| {
        std.debug.print("❌ Clock error: {}\n", .{err});
        return;
    };
    var thread_handle = try std.Thread.spawn(.{}, monitorThread, .{&monitor});
    defer {
        std.posix.nanosleep(60, 0);
        monitor.running.store(false, .release);
        thread_handle.join();
    }

    // Print status every 10 seconds
    var elapsed: u32 = 0;
    while (elapsed < 60) : (elapsed += 10) {
        std.posix.nanosleep(10, 0);
        if (!monitor.running.load(.acquire)) break;
        const tx = monitor.stats.tx_seen.load(.monotonic);
        const blocks = monitor.stats.blocks_seen.load(.monotonic);
        std.debug.print("⏱️  {}s: {} TX, {} blocks\n", .{ elapsed + 10, tx, blocks });
    }

    // Print stats
    const end = std.posix.clock_gettime(.MONOTONIC) catch return;
    const duration_ns = (@as(u64, @intCast(end.sec)) * 1_000_000_000 + @as(u64, @intCast(end.nsec))) -
        (@as(u64, @intCast(start.sec)) * 1_000_000_000 + @as(u64, @intCast(start.nsec)));
    const duration_s = @as(f64, @floatFromInt(duration_ns)) / 1_000_000_000.0;

    const tx_seen = monitor.stats.tx_seen.load(.monotonic);
    const blocks_seen = monitor.stats.blocks_seen.load(.monotonic);
    const bytes = monitor.stats.bytes_received.load(.monotonic);

    std.debug.print("\n╔═════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║   Test Results                                  ║\n", .{});
    std.debug.print("╚═════════════════════════════════════════════════╝\n\n", .{});
    std.debug.print("⏱️  Duration: {d:.1}s\n", .{duration_s});
    std.debug.print("📊 Transactions seen: {}\n", .{tx_seen});
    std.debug.print("📦 Blocks seen: {}\n", .{blocks_seen});
    std.debug.print("📡 Bytes received: {d:.2} KB\n", .{@as(f64, @floatFromInt(bytes)) / 1024.0});
    if (tx_seen > 0) {
        std.debug.print("🚀 TX rate: {d:.2} tx/s\n", .{@as(f64, @floatFromInt(tx_seen)) / duration_s});
    }
    std.debug.print("\n✅ Test complete!\n", .{});
}

fn monitorThread(monitor: *MempoolMonitor) void {
    monitor.run() catch |err| {
        std.debug.print("❌ Monitor error: {}\n", .{err});
    };
}

fn onTransactionSeen(tx_hash: [32]u8) void {
    var buf: [64]u8 = undefined;
    const hex = formatHash(tx_hash, &buf) catch return;
    std.debug.print("🔔 TX: {s}\n", .{hex});
}
