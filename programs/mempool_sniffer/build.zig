const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Bitcoin protocol module
    const bitcoin_module = b.addModule("bitcoin_protocol", .{
        .root_source_file = b.path("src/bitcoin_protocol.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Core module
    const core_module = b.addModule("mempool_sniffer_core", .{
        .root_source_file = b.path("src/mempool_sniffer_core.zig"),
        .target = target,
        .optimize = optimize,
    });

    core_module.addImport("bitcoin_protocol", bitcoin_module);

    // Core library (static, C FFI)
    const core_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "mempool_sniffer_core",
        .root_module = core_module,
    });

    core_lib.linkLibC();

    b.installArtifact(core_lib);

    const core_step = b.step("core", "Build mempool_sniffer_core static library");
    core_step.dependOn(&b.addInstallArtifact(core_lib, .{}).step);

    // Default build
    b.default_step.dependOn(core_step);
}
