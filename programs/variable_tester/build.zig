const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Import lockfree_queue from sibling project
    const lockfree_queue_path = b.path("../lockfree_queue/src/lockfree_queue.zig");

    const lockfree_module = b.addModule("lockfree_queue", .{
        .root_source_file = lockfree_queue_path,
        .target = target,
        .optimize = optimize,
    });

    // Main executable
    const exe = b.addExecutable(.{
        .name = "variable-tester",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("lockfree_queue", lockfree_module);
    b.installArtifact(exe);

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the variable tester");
    run_step.dependOn(&run_cmd.step);

    // Benchmark executable
    const bench = b.addExecutable(.{
        .name = "variable-tester-bench",
        .root_source_file = b.path("benchmarks/bench.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });

    bench.root_module.addImport("lockfree_queue", lockfree_module);
    b.installArtifact(bench);

    const bench_cmd = b.addRunArtifact(bench);
    bench_cmd.step.dependOn(b.getInstallStep());

    const bench_step = b.step("bench", "Run benchmarks");
    bench_step.dependOn(&bench_cmd.step);
}
