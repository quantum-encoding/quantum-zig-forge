const std = @import("std");
const variable_tester = @import("variable_tester.zig");
const test_functions = @import("test_functions.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Variable Tester - Massively Parallel Computation       ║\n", .{});
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});

    const num_cpus = try std.Thread.getCpuCount();
    std.debug.print("Detected {} CPU cores\n", .{num_cpus});

    const num_workers = num_cpus;
    const queue_capacity = 10000;

    std.debug.print("Initializing {} worker threads...\n", .{num_workers});
    std.debug.print("Queue capacity: {} tasks\n", .{queue_capacity});
    std.debug.print("\n", .{});

    // Create the variable tester with lossless compression test function
    const tester = try variable_tester.VariableTester.init(
        allocator,
        num_workers,
        queue_capacity,
        test_functions.testLosslessCompression,
    );
    defer tester.deinit();

    // Start the workers
    try tester.start();
    std.debug.print("✓ Workers started\n", .{});
    std.debug.print("\n", .{});

    // Submit test tasks
    std.debug.print("Submitting test tasks...\n", .{});

    const num_tasks = 1000;
    var task_id: u64 = 0;

    while (task_id < num_tasks) : (task_id += 1) {
        const task_data = try std.fmt.allocPrint(allocator, "formula_{}", .{task_id});
        defer allocator.free(task_data);

        const task = variable_tester.Task.init(task_id, task_data);
        try tester.submitTask(task);
    }

    std.debug.print("✓ Submitted {} tasks\n", .{num_tasks});
    std.debug.print("\n", .{});

    // Collect results
    std.debug.print("Collecting results...\n", .{});
    std.debug.print("\n", .{});

    var results_collected: u64 = 0;
    var successful_results: u64 = 0;

    const start_time = std.time.nanoTimestamp();

    while (results_collected < num_tasks) {
        if (tester.collectResult()) |result| {
            results_collected += 1;

            if (result.success) {
                successful_results += 1;
                std.debug.print("✓ Task {} succeeded (score: {d:.4})\n", .{ result.task_id, result.score });
            }

            // Free result data
            allocator.free(result.data);
        } else {
            // No results available yet, yield
            std.time.sleep(1 * std.time.ns_per_ms);
        }
    }

    const end_time = std.time.nanoTimestamp();
    const elapsed_ns = @as(u64, @intCast(end_time - start_time));
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / @as(f64, @floatFromInt(std.time.ns_per_ms));

    std.debug.print("\n", .{});
    std.debug.print("Stopping workers...\n", .{});
    tester.stop();
    std.debug.print("✓ Workers stopped\n", .{});
    std.debug.print("\n", .{});

    // Get final statistics
    const stats = tester.getStats();

    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Performance Summary                                     ║\n", .{});
    std.debug.print("╠══════════════════════════════════════════════════════════╣\n", .{});
    std.debug.print("║  Workers: {d:<48}║\n", .{num_workers});
    std.debug.print("║  Tasks processed: {d:<40}║\n", .{stats.total_processed});
    std.debug.print("║  Tasks succeeded: {d:<40}║\n", .{stats.total_succeeded});
    std.debug.print("║  Tasks failed: {d:<43}║\n", .{stats.total_failed});
    std.debug.print("║  Elapsed time: {d:.2} ms{s: <36}║\n", .{ elapsed_ms, "" });

    const throughput = @as(f64, @floatFromInt(stats.total_processed)) / (elapsed_ms / 1000.0);
    std.debug.print("║  Throughput: {d:.0} tasks/sec{s: <31}║\n", .{ throughput, "" });

    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});
}
