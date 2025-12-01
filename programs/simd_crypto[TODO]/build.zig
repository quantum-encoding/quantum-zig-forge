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
        .name = "quantum_crypto",
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
    // Zig Module (for Zig projects)
    // =============================================================================

    const crypto_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // =============================================================================
    // Tests
    // =============================================================================

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

    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&b.addRunArtifact(ffi_tests).step);

    // Test the Zig module
    const module_test_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const module_tests = b.addTest(.{
        .root_module = module_test_module,
    });

    const module_test_step = b.step("test-module", "Run Zig module tests");
    module_test_step.dependOn(&b.addRunArtifact(module_tests).step);

    _ = crypto_module;
}
