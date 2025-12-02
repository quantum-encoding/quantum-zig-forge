const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Import lockfree_queue from sibling project
    const lockfree_queue_path = b.path("../lockfree_queue/src/main.zig");

    const lockfree_module = b.addModule("lockfree_queue", .{
        .root_source_file = lockfree_queue_path,
        .target = target,
        .optimize = optimize,
    });

    // Protocol module (shared between Queen and Worker)
    const protocol_module = b.addModule("protocol", .{
        .root_source_file = b.path("src/protocol.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Variable tester module (for imports)
    const vt_module = b.addModule("variable_tester", .{
        .root_source_file = b.path("src/variable_tester.zig"),
        .target = target,
        .optimize = optimize,
    });
    vt_module.addImport("lockfree_queue", lockfree_module);

    // Test functions module
    const tf_module = b.addModule("test_functions", .{
        .root_source_file = b.path("src/test_functions.zig"),
        .target = target,
        .optimize = optimize,
    });
    tf_module.addImport("variable_tester", vt_module);

    // Queen module
    const queen_module = b.addModule("queen", .{
        .root_source_file = b.path("src/queen.zig"),
        .target = target,
        .optimize = optimize,
    });
    queen_module.addImport("protocol", protocol_module);
    queen_module.addImport("variable_tester", vt_module);

    // Worker module
    const worker_module = b.addModule("worker", .{
        .root_source_file = b.path("src/worker.zig"),
        .target = target,
        .optimize = optimize,
    });
    worker_module.addImport("protocol", protocol_module);
    worker_module.addImport("variable_tester", vt_module);
    worker_module.addImport("test_functions", tf_module);

    // ==================== Main executable ====================
    const main_module = b.addModule("main", .{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    main_module.addImport("lockfree_queue", lockfree_module);
    main_module.addImport("variable_tester", vt_module);
    main_module.addImport("test_functions", tf_module);

    const exe = b.addExecutable(.{
        .name = "variable-tester",
        .root_module = main_module,
    });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the variable tester");
    run_step.dependOn(&run_cmd.step);

    // ==================== Queen executable ====================
    const queen_main_module = b.addModule("queen_main", .{
        .root_source_file = b.path("src/queen_main.zig"),
        .target = target,
        .optimize = optimize,
    });
    queen_main_module.addImport("queen", queen_module);
    queen_main_module.addImport("protocol", protocol_module);

    const queen_exe = b.addExecutable(.{
        .name = "queen",
        .root_module = queen_main_module,
    });
    b.installArtifact(queen_exe);

    const queen_cmd = b.addRunArtifact(queen_exe);
    queen_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        queen_cmd.addArgs(args);
    }

    const queen_step = b.step("queen", "Run the Queen coordinator");
    queen_step.dependOn(&queen_cmd.step);

    // ==================== Worker executable ====================
    const worker_main_module = b.addModule("worker_main", .{
        .root_source_file = b.path("src/worker_main.zig"),
        .target = target,
        .optimize = optimize,
    });
    worker_main_module.addImport("worker", worker_module);
    worker_main_module.addImport("protocol", protocol_module);
    worker_main_module.addImport("variable_tester", vt_module);
    worker_main_module.addImport("test_functions", tf_module);

    const worker_exe = b.addExecutable(.{
        .name = "worker",
        .root_module = worker_main_module,
    });
    b.installArtifact(worker_exe);

    const worker_cmd = b.addRunArtifact(worker_exe);
    worker_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        worker_cmd.addArgs(args);
    }

    const worker_step = b.step("worker", "Run a Worker drone");
    worker_step.dependOn(&worker_cmd.step);

    // ==================== Benchmark executable ====================
    const bench_module = b.addModule("bench", .{
        .root_source_file = b.path("benchmarks/bench.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });
    bench_module.addImport("lockfree_queue", lockfree_module);
    bench_module.addImport("variable_tester", vt_module);
    bench_module.addImport("test_functions", tf_module);

    const bench = b.addExecutable(.{
        .name = "variable-tester-bench",
        .root_module = bench_module,
    });
    b.installArtifact(bench);

    const bench_cmd = b.addRunArtifact(bench);
    bench_cmd.step.dependOn(b.getInstallStep());

    const bench_step = b.step("bench", "Run benchmarks");
    bench_step.dependOn(&bench_cmd.step);

    // ==================== Saturation Benchmark executable ====================
    const sat_module = b.addModule("saturation_bench", .{
        .root_source_file = b.path("src/saturation_bench.zig"),
        .target = target,
        .optimize = .ReleaseFast,
    });

    const sat_exe = b.addExecutable(.{
        .name = "saturation-bench",
        .root_module = sat_module,
    });
    b.installArtifact(sat_exe);

    const sat_cmd = b.addRunArtifact(sat_exe);
    sat_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        sat_cmd.addArgs(args);
    }

    const sat_step = b.step("saturation", "Run saturation benchmark");
    sat_step.dependOn(&sat_cmd.step);
}
