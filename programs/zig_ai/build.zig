const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // HTTP Sentinel dependency (provides AI client implementations)
    const http_sentinel_dep = b.dependency("http_sentinel", .{
        .target = target,
        .optimize = optimize,
    });
    const http_sentinel_module = http_sentinel_dep.module("http-sentinel");

    // zig-ai CLI module
    const zig_ai_module = b.addModule("zig-ai", .{
        .root_source_file = b.path("src/cli.zig"),
        .target = target,
        .optimize = optimize,
    });
    zig_ai_module.addImport("http-sentinel", http_sentinel_module);

    // zig-ai CLI executable
    const exe_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_module.addImport("http-sentinel", http_sentinel_module);

    const exe = b.addExecutable(.{
        .name = "zig-ai",
        .root_module = exe_module,
    });
    b.installArtifact(exe);

    // Run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run zig-ai CLI");
    run_step.dependOn(&run_cmd.step);

    // Tests - use root_module pattern for Zig 0.16
    const test_root_module = b.createModule(.{
        .root_source_file = b.path("src/cli.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_root_module.addImport("http-sentinel", http_sentinel_module);

    const test_compile = b.addTest(.{
        .root_module = test_root_module,
    });

    const run_tests = b.addRunArtifact(test_compile);
    const test_step = b.step("test", "Run zig-ai tests");
    test_step.dependOn(&run_tests.step);
}
