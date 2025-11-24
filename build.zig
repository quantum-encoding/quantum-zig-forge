const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Build step to compile all programs and collect binaries to root zig-out/
    const build_all = b.step("all", "Build all programs in the monorepo");

    // Programs
    buildProgram(b, "zig_ai", target, optimize, build_all);
    buildProgram(b, "http_sentinel", target, optimize, build_all);
    buildProgram(b, "quantum_curl", target, optimize, build_all);
    buildProgram(b, "guardian_shield", target, optimize, build_all);
    buildProgram(b, "chronos_engine", target, optimize, build_all);
    buildProgram(b, "zig_jail", target, optimize, build_all);
    buildProgram(b, "zig_port_scanner", target, optimize, build_all);
    buildProgram(b, "duck_agent_scribe", target, optimize, build_all);
    buildProgram(b, "duck_cache_scribe", target, optimize, build_all);
    buildProgram(b, "cognitive_telemetry_kit", target, optimize, build_all);
    buildProgram(b, "stratum_engine_claude", target, optimize, build_all);
    buildProgram(b, "stratum_engine_grok", target, optimize, build_all);
    buildProgram(b, "timeseries_db", target, optimize, build_all);
    buildProgram(b, "market_data_parser", target, optimize, build_all);
    buildProgram(b, "financial_engine", target, optimize, build_all);
    buildProgram(b, "async_scheduler", target, optimize, build_all);
    buildProgram(b, "zero_copy_net", target, optimize, build_all);
    // Libraries (WIP/Stubbed)
    buildProgram(b, "simd_crypto", target, optimize, build_all);
    buildProgram(b, "memory_pool", target, optimize, build_all);
    buildProgram(b, "lockfree_queue", target, optimize, build_all);

    // Default install step builds everything
    b.getInstallStep().dependOn(build_all);

    // Test all programs
    const test_all = b.step("test", "Run all tests in the monorepo");
    testProgram(b, "zig_ai", test_all);
    testProgram(b, "http_sentinel", test_all);
    testProgram(b, "quantum_curl", test_all);
    testProgram(b, "guardian_shield", test_all);
    testProgram(b, "chronos_engine", test_all);
    testProgram(b, "zig_jail", test_all);
    testProgram(b, "zig_port_scanner", test_all);
    testProgram(b, "duck_agent_scribe", test_all);
    testProgram(b, "duck_cache_scribe", test_all);
    testProgram(b, "cognitive_telemetry_kit", test_all);
    testProgram(b, "stratum_engine_claude", test_all);
    testProgram(b, "stratum_engine_grok", test_all);
    testProgram(b, "timeseries_db", test_all);
    testProgram(b, "market_data_parser", test_all);
    testProgram(b, "financial_engine", test_all);
    testProgram(b, "async_scheduler", test_all);
    testProgram(b, "zero_copy_net", test_all);
    // Libraries (WIP/Stubbed)
    testProgram(b, "simd_crypto", test_all);
    testProgram(b, "memory_pool", test_all);
    testProgram(b, "lockfree_queue", test_all);

    // Clean step
    const clean_step = b.step("clean", "Remove all build artifacts");
    const clean_cmd = b.addSystemCommand(&[_][]const u8{
        "sh",
        "-c",
        "rm -rf zig-out .zig-cache programs/*/zig-out programs/*/.zig-cache",
    });
    clean_step.dependOn(&clean_cmd.step);
}

fn buildProgram(
    b: *std.Build,
    name: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    build_all: *std.Build.Step,
) void {
    _ = target;
    _ = optimize;

    const program_dir = b.fmt("programs/{s}", .{name});

    // Build the program in its directory
    const build_cmd = b.addSystemCommand(&[_][]const u8{
        "zig",
        "build",
        "--prefix",
        "../../zig-out",
    });
    build_cmd.setCwd(.{ .cwd_relative = program_dir });

    // Add to build_all
    build_all.dependOn(&build_cmd.step);

    // Create individual build step
    const build_step = b.step(name, b.fmt("Build {s} program", .{name}));
    build_step.dependOn(&build_cmd.step);
}

fn testProgram(
    b: *std.Build,
    name: []const u8,
    test_all: *std.Build.Step,
) void {
    const program_dir = b.fmt("programs/{s}", .{name});

    const test_cmd = b.addSystemCommand(&[_][]const u8{
        "zig",
        "build",
        "test",
    });
    test_cmd.setCwd(.{ .cwd_relative = program_dir });

    test_all.dependOn(&test_cmd.step);
}
