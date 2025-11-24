const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const net_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Tests
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

    // TCP echo example
    const tcp_echo_module = b.createModule(.{
        .root_source_file = b.path("examples/tcp_echo.zig"),
        .target = target,
        .optimize = optimize,
    });
    tcp_echo_module.addImport("net", net_module);

    const tcp_echo = b.addExecutable(.{
        .name = "tcp-echo",
        .root_module = tcp_echo_module,
    });
    b.installArtifact(tcp_echo);

    const run_tcp_echo = b.addRunArtifact(tcp_echo);
    const tcp_echo_step = b.step("tcp-echo", "Run TCP echo server example");
    tcp_echo_step.dependOn(&run_tcp_echo.step);
}
