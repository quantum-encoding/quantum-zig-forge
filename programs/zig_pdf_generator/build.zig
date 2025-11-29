//! Zig PDF Generator Build Configuration
//!
//! Builds a high-performance PDF generation library with C FFI for cross-platform use.
//! Target platforms: Linux, Android (aarch64, armv7), iOS (aarch64), macOS, Windows
//!
//! Usage:
//!   zig build              - Build native library and CLI
//!   zig build test         - Run all tests
//!   zig build -Dtarget=aarch64-linux-android  - Cross-compile for Android ARM64

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ==========================================================================
    // Core Library (Static)
    // ==========================================================================
    const lib = b.addLibrary(.{
        .name = "zigpdf",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .linkage = .static,
    });

    // Link libc for Android/iOS FFI compatibility
    lib.linkLibC();

    b.installArtifact(lib);

    // ==========================================================================
    // Shared Library (for JNI/FFI)
    // ==========================================================================
    const shared_lib = b.addLibrary(.{
        .name = "zigpdf_shared",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .linkage = .dynamic,
    });

    shared_lib.linkLibC();

    const install_shared = b.addInstallArtifact(shared_lib, .{});
    const shared_step = b.step("shared", "Build shared library for FFI");
    shared_step.dependOn(&install_shared.step);

    // ==========================================================================
    // CLI Tool
    // ==========================================================================
    const exe = b.addExecutable(.{
        .name = "pdf-gen",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the PDF generator CLI");
    run_step.dependOn(&run_cmd.step);

    // ==========================================================================
    // Tests
    // ==========================================================================
    const lib_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/lib.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    lib_unit_tests.linkLibC();

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
