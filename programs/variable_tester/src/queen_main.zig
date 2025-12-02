//! Queen - Brute-Force Swarm Coordinator
//!
//! Usage: queen [options]
//!   --port <port>     Listen port (default: 7777)
//!   --tasks <count>   Number of numeric tasks to generate
//!   --test <name>     Test function: compression, prime, hash

const std = @import("std");
const posix = std.posix;
const Queen = @import("queen.zig").Queen;
const QueenConfig = @import("queen.zig").QueenConfig;
const protocol = @import("protocol.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  👑 QUEEN - Brute-Force Swarm Coordinator               ║\n", .{});
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});

    // Parse args
    var config = QueenConfig{};
    var task_count: u64 = 10000;

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // Skip program name

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--port")) {
            if (args.next()) |port_str| {
                config.port = try std.fmt.parseInt(u16, port_str, 10);
            }
        } else if (std.mem.eql(u8, arg, "--tasks")) {
            if (args.next()) |tasks_str| {
                task_count = try std.fmt.parseInt(u64, tasks_str, 10);
            }
        } else if (std.mem.eql(u8, arg, "--test")) {
            if (args.next()) |test_name| {
                if (std.mem.eql(u8, test_name, "compression")) {
                    config.test_fn_id = .lossless_compression;
                } else if (std.mem.eql(u8, test_name, "prime")) {
                    config.test_fn_id = .prime_number;
                } else if (std.mem.eql(u8, test_name, "hash")) {
                    config.test_fn_id = .hash_collision;
                }
            }
        }
    }

    std.debug.print("Configuration:\n", .{});
    std.debug.print("  Port: {}\n", .{config.port});
    std.debug.print("  Tasks: {}\n", .{task_count});
    std.debug.print("  Test: {}\n", .{config.test_fn_id});
    std.debug.print("\n", .{});

    // Create Queen
    const queen = try Queen.init(allocator, config);
    defer queen.deinit();

    // Generate tasks
    std.debug.print("Generating {} tasks...\n", .{task_count});
    try queen.generateNumericTasks(0, task_count);
    std.debug.print("✓ Tasks generated\n", .{});
    std.debug.print("\n", .{});

    // Start Queen
    try queen.start();
    std.debug.print("✓ Queen started, waiting for workers...\n", .{});
    std.debug.print("\n", .{});
    std.debug.print("Press Ctrl+C to stop\n", .{});
    std.debug.print("\n", .{});

    // Stats display loop
    const start_time = (posix.clock_gettime(.MONOTONIC) catch unreachable);

    while (queen.running.load(.acquire)) {
        posix.nanosleep(2, 0); // Update every 2 seconds

        const stats = queen.getStats();
        const now = (posix.clock_gettime(.MONOTONIC) catch continue);
        const elapsed_secs = @as(f64, @floatFromInt(now.sec - start_time.sec));

        const progress = if (stats.total_tasks > 0)
            (@as(f64, @floatFromInt(stats.tasks_distributed)) / @as(f64, @floatFromInt(stats.total_tasks))) * 100.0
        else
            0.0;

        const throughput = if (elapsed_secs > 0)
            @as(f64, @floatFromInt(stats.tasks_completed)) / elapsed_secs
        else
            0.0;

        std.debug.print("\r📊 Workers: {} ({} cores) | Progress: {d:.1}% | Throughput: {d:.0}/sec | Solutions: {}   ", .{
            stats.active_workers,
            stats.total_cores,
            progress,
            throughput,
            stats.solutions_found,
        });

        // Check if all tasks distributed and completed
        if (stats.tasks_distributed >= stats.total_tasks and stats.tasks_completed >= stats.total_tasks) {
            std.debug.print("\n\n✓ All tasks completed!\n", .{});
            break;
        }
    }

    queen.stop();

    // Final stats
    const final_stats = queen.getStats();
    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Final Statistics                                        ║\n", .{});
    std.debug.print("╠══════════════════════════════════════════════════════════╣\n", .{});
    std.debug.print("║  Total tasks: {d:<43}║\n", .{final_stats.total_tasks});
    std.debug.print("║  Tasks distributed: {d:<37}║\n", .{final_stats.tasks_distributed});
    std.debug.print("║  Tasks completed: {d:<39}║\n", .{final_stats.tasks_completed});
    std.debug.print("║  Solutions found: {d:<39}║\n", .{final_stats.solutions_found});
    std.debug.print("║  Best score: {d:.4}{s: <40}║\n", .{ final_stats.best_score, "" });
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});
}
