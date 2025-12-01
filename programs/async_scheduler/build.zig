const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ========================================================================
    // Core FFI Static Library (ZERO DEPENDENCIES)
    // ========================================================================

    const core_module = b.createModule(.{
        .root_source_file = b.path("src/async_core.zig"),
        .target = target,
        .optimize = optimize,
    });

    const core_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "async_core",
        .root_module = core_module,
    });

    core_lib.linkLibC();
    // NO EXTERNAL DEPS

    b.installArtifact(core_lib);

    const core_step = b.step("core", "Build core FFI static library (zero deps)");
    core_step.dependOn(&b.addInstallArtifact(core_lib, .{}).step);

    // ========================================================================
    // Scheduler library module (used by tests, benchmarks)
    // ========================================================================

    const scheduler_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const tests = b.addTest(.{
        .root_module = test_module,
    });

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);

    // Benchmark executable
    const bench_module = b.createModule(.{
        .root_source_file = b.path("src/bench.zig"),
        .target = target,
        .optimize = optimize,
    });

    const bench = b.addExecutable(.{
        .name = "bench-scheduler",
        .root_module = bench_module,
    });
    b.installArtifact(bench);

    const bench_step = b.step("bench", "Run benchmarks");
    bench_step.dependOn(&b.addRunArtifact(bench).step);

    _ = scheduler_module;
}
