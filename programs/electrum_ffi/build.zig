const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // =============================================================================
    // Static Library (for FFI integration with Rust/C/etc.)
    // =============================================================================

    const ffi_module = b.createModule(.{
        .root_source_file = b.path("src/ffi.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "electrum_ffi",
        .root_module = ffi_module,
        .linkage = .static,
    });

    // Link with libc for C compatibility
    lib.linkLibC();

    // Strip debug symbols for production (reduces binary size)
    lib.root_module.strip = optimize != .Debug;

    // Install to zig-out/lib/
    b.installArtifact(lib);

    // =============================================================================
    // Tests
    // =============================================================================

    // Test the core electrum module
    const electrum_test_module = b.createModule(.{
        .root_source_file = b.path("src/electrum.zig"),
        .target = target,
        .optimize = optimize,
    });

    const electrum_tests = b.addTest(.{
        .root_module = electrum_test_module,
    });

    const test_step = b.step("test", "Run Electrum unit tests");
    test_step.dependOn(&b.addRunArtifact(electrum_tests).step);

    // Test the FFI layer
    const ffi_test_module = b.createModule(.{
        .root_source_file = b.path("src/ffi.zig"),
        .target = target,
        .optimize = optimize,
    });

    const ffi_tests = b.addTest(.{
        .root_module = ffi_test_module,
    });
    ffi_tests.linkLibC();

    const ffi_test_step = b.step("test-ffi", "Run FFI unit tests");
    ffi_test_step.dependOn(&b.addRunArtifact(ffi_tests).step);
}
