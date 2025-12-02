const std = @import("std");
const variable_tester = @import("../src/variable_tester.zig");
const test_functions = @import("../src/test_functions.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Variable Tester - Performance Benchmark                ║\n", .{});
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});

    const num_cpus = try std.Thread.getCpuCount();
    std.debug.print("System: {} CPU cores\n", .{num_cpus});
    std.debug.print("\n", .{});

    const test_configs = [_]struct {
        name: []const u8,
        workers: usize,
        tasks: u64,
        test_fn: variable_tester.TestFn,
    }{
        .{ .name = "Compression (1 worker)", .workers = 1, .tasks = 10000, .test_fn = test_functions.testLosslessCompression },
        .{ .name = "Compression (4 workers)", .workers = 4, .tasks = 10000, .test_fn = test_functions.testLosslessCompression },
        .{ .name = "Compression (all cores)", .workers = num_cpus, .tasks = 10000, .test_fn = test_functions.testLosslessCompression },
        .{ .name = "Prime numbers (all cores)", .workers = num_cpus, .tasks = 10000, .test_fn = test_functions.testPrimeNumber },
        .{ .name = "Hash collision (all cores)", .workers = num_cpus, .tasks = 10000, .test_fn = test_functions.testHashCollision },
        .{ .name = "Math formula (all cores)", .workers = num_cpus, .tasks = 10000, .test_fn = test_functions.testMathFormula },
    };

    for (test_configs) |config| {
        try runBenchmark(allocator, config.name, config.workers, config.tasks, config.test_fn);
    }

    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  Benchmark Complete                                      ║\n", .{});
    std.debug.print("╚══════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});
}

fn runBenchmark(
    allocator: std.mem.Allocator,
    name: []const u8,
    num_workers: usize,
    num_tasks: u64,
    test_fn: variable_tester.TestFn,
) !void {
    std.debug.print("Running: {s}\n", .{name});
    std.debug.print("  Workers: {}, Tasks: {}\n", .{ num_workers, num_tasks });

    const queue_capacity = 10000;

    const tester = try variable_tester.VariableTester.init(
        allocator,
        num_workers,
        queue_capacity,
        test_fn,
    );
    defer tester.deinit();

    try tester.start();

    const start_time = std.time.nanoTimestamp();

    // Submit tasks
    var task_id: u64 = 0;
    while (task_id < num_tasks) : (task_id += 1) {
        const task_data = try std.fmt.allocPrint(allocator, "{}", .{task_id});
        const task = variable_tester.Task.init(task_id, task_data);
        try tester.submitTask(task);
    }

    // Collect results
    var results_collected: u64 = 0;
    while (results_collected < num_tasks) {
        if (tester.collectResult()) |result| {
            allocator.free(result.data);
            results_collected += 1;
        } else {
            std.time.sleep(100 * std.time.ns_per_us);
        }
    }

    const end_time = std.time.nanoTimestamp();
    const elapsed_ns = @as(u64, @intCast(end_time - start_time));
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / @as(f64, @floatFromInt(std.time.ns_per_ms));

    tester.stop();

    const stats = tester.getStats();
    const throughput = @as(f64, @floatFromInt(stats.total_processed)) / (elapsed_ms / 1000.0);

    std.debug.print("  ✓ Completed in {d:.2} ms\n", .{elapsed_ms});
    std.debug.print("  ✓ Throughput: {d:.0} tasks/sec\n", .{throughput});
    std.debug.print("  ✓ Success rate: {d:.1}%\n", .{
        (@as(f64, @floatFromInt(stats.total_succeeded)) / @as(f64, @floatFromInt(stats.total_processed))) * 100.0,
    });
    std.debug.print("\n", .{});
}
