//! Queen - Brute-Force Swarm Coordinator
//!
//! Usage: queen [options]
//!   --port <port>       Listen port (default: 7777)
//!   --start <number>    Starting number for task range (default: 0)
//!   --end <number>      Ending number for task range (default: 10000000)
//!   --chunk <size>      Tasks per chunk dispatched to workers (default: 1000)
//!   --test <name>       Test function: compression, prime, hash, numeric_match
//!   --lib <path>        Path to test library .so (default: ./zig-out/lib/libtest_compression.so)

const std = @import("std");
const posix = std.posix;
const Queen = @import("queen.zig").Queen;
const QueenConfig = @import("queen.zig").QueenConfig;
const protocol = @import("protocol.zig");
const test_functions = @import("test_functions.zig");

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
    var start_num: u64 = 0;
    var end_num: u64 = 10_000_000; // Default: 10 million
    var is_numeric_match = false;

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.skip(); // Skip program name

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--port")) {
            if (args.next()) |port_str| {
                config.port = try std.fmt.parseInt(u16, port_str, 10);
            }
        } else if (std.mem.eql(u8, arg, "--start")) {
            if (args.next()) |start_str| {
                start_num = try std.fmt.parseInt(u64, start_str, 10);
            }
        } else if (std.mem.eql(u8, arg, "--end")) {
            if (args.next()) |end_str| {
                end_num = try std.fmt.parseInt(u64, end_str, 10);
            }
        } else if (std.mem.eql(u8, arg, "--chunk")) {
            if (args.next()) |chunk_str| {
                config.chunk_size = try std.fmt.parseInt(u32, chunk_str, 10);
            }
        } else if (std.mem.eql(u8, arg, "--test")) {
            if (args.next()) |test_name| {
                if (std.mem.eql(u8, test_name, "compression")) {
                    config.test_fn_id = .lossless_compression;
                } else if (std.mem.eql(u8, test_name, "prime")) {
                    config.test_fn_id = .prime_number;
                } else if (std.mem.eql(u8, test_name, "hash")) {
                    config.test_fn_id = .hash_collision;
                } else if (std.mem.eql(u8, test_name, "numeric_match")) {
                    config.test_fn_id = .numeric_match;
                    is_numeric_match = true;
                } else if (std.mem.eql(u8, test_name, "math")) {
                    config.test_fn_id = .math_formula;
                }
            }
        } else if (std.mem.eql(u8, arg, "--lib")) {
            if (args.next()) |lib_path| {
                config.test_lib_path = lib_path;
            }
        }
    }

    const task_count = end_num - start_num;

    std.debug.print("Configuration:\n", .{});
    std.debug.print("  Port: {}\n", .{config.port});
    std.debug.print("  Range: {} to {} ({} tasks)\n", .{ start_num, end_num, task_count });
    std.debug.print("  Chunk Size: {} tasks/dispatch\n", .{config.chunk_size});
    std.debug.print("  Test: {}\n", .{config.test_fn_id});
    if (is_numeric_match) {
        std.debug.print("  Secret Number: {} (searching...)\n", .{test_functions.SECRET_NUMBER});
    }
    std.debug.print("\n", .{});

    // Create Queen
    const queen = try Queen.init(allocator, config);
    defer queen.deinit();

    // Generate tasks
    std.debug.print("Generating {} tasks...\n", .{task_count});
    try queen.generateNumericTasks(start_num, end_num);
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

    // Calculate elapsed time
    const end_time = (posix.clock_gettime(.MONOTONIC) catch unreachable);
    const elapsed_secs = @as(f64, @floatFromInt(end_time.sec - start_time.sec)) +
        @as(f64, @floatFromInt(end_time.nsec - start_time.nsec)) / 1_000_000_000.0;

    // Final stats
    const final_stats = queen.getStats();
    const final_throughput = if (elapsed_secs > 0)
        @as(f64, @floatFromInt(final_stats.tasks_completed)) / elapsed_secs
    else
        0.0;

    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Final Statistics                                        ║\n", .{});
    std.debug.print("╠══════════════════════════════════════════════════════════╣\n", .{});
    std.debug.print("║  Total tasks: {d:<43}║\n", .{final_stats.total_tasks});
    std.debug.print("║  Tasks distributed: {d:<37}║\n", .{final_stats.tasks_distributed});
    std.debug.print("║  Tasks completed: {d:<39}║\n", .{final_stats.tasks_completed});
    std.debug.print("║  Solutions found: {d:<39}║\n", .{final_stats.solutions_found});
    std.debug.print("║  Best score: {d:.4}{s: <40}║\n", .{ final_stats.best_score, "" });
    std.debug.print("║  Elapsed time: {d:.2} seconds{s: <30}║\n", .{ elapsed_secs, "" });
    std.debug.print("║  Throughput: {d:.0} tasks/sec{s: <28}║\n", .{ final_throughput, "" });
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});

    // Verification for numeric_match test
    if (is_numeric_match) {
        std.debug.print("\n", .{});
        std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});

        // Check if we found the secret number
        const secret = test_functions.SECRET_NUMBER;
        const secret_in_range = (secret >= start_num and secret < end_num);
        const expected_solutions: u64 = if (secret_in_range) 1 else 0;

        if (final_stats.solutions_found == expected_solutions and
            final_stats.tasks_completed == final_stats.total_tasks)
        {
            std.debug.print("║  ✅ VERIFICATION: SUCCESS                                ║\n", .{});
            std.debug.print("╠══════════════════════════════════════════════════════════╣\n", .{});
            if (secret_in_range) {
                std.debug.print("║  Found secret number {} in range [{}, {})   ║\n", .{ secret, start_num, end_num });
            } else {
                std.debug.print("║  Secret {} not in range [{}, {}) - correct 0 found  ║\n", .{ secret, start_num, end_num });
            }
            std.debug.print("║  All {} tasks processed successfully{s: <20}║\n", .{ final_stats.total_tasks, "" });
        } else {
            std.debug.print("║  ❌ VERIFICATION: FAILURE                                ║\n", .{});
            std.debug.print("╠══════════════════════════════════════════════════════════╣\n", .{});
            std.debug.print("║  Expected {} solution(s), found {}{s: <32}║\n", .{ expected_solutions, final_stats.solutions_found, "" });
            std.debug.print("║  Completed {}/{} tasks{s: <31}║\n", .{ final_stats.tasks_completed, final_stats.total_tasks, "" });
        }
        std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    }

    std.debug.print("\n", .{});
}
