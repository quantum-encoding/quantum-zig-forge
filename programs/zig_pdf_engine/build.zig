const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Core PDF Engine library module
    const pdf_engine_module = b.addModule("pdf-engine", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link zlib for FlateDecode
    pdf_engine_module.link_libc = true;

    // Library tests
    const lib_unit_tests = b.addTest(.{
        .root_module = pdf_engine_module,
    });
    lib_unit_tests.linkSystemLibrary("z"); // zlib for FlateDecode tests
    lib_unit_tests.linkLibC();
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    // Helper to create executables with pdf-engine import
    const addTool = struct {
        fn call(
            builder: *std.Build,
            name: []const u8,
            src: []const u8,
            tgt: std.Build.ResolvedTarget,
            opt: std.builtin.OptimizeMode,
            module: *std.Build.Module,
        ) *std.Build.Step.Compile {
            const exe_module = builder.createModule(.{
                .root_source_file = builder.path(src),
                .target = tgt,
                .optimize = opt,
            });
            exe_module.addImport("pdf-engine", module);
            exe_module.link_libc = true;

            const exe = builder.addExecutable(.{
                .name = name,
                .root_module = exe_module,
            });
            exe.linkSystemLibrary("z"); // zlib
            builder.installArtifact(exe);
            return exe;
        }
    }.call;

    // CLI Tools
    const pdf_info = addTool(b, "pdf-info", "src/tools/pdf_info.zig", target, optimize, pdf_engine_module);
    const pdf_text = addTool(b, "pdf-text", "src/tools/pdf_text.zig", target, optimize, pdf_engine_module);

    // Run commands for pdf-info
    const run_info = b.addRunArtifact(pdf_info);
    if (b.args) |args| {
        run_info.addArgs(args);
    }
    const info_step = b.step("info", "Run pdf-info tool");
    info_step.dependOn(&run_info.step);

    // Run commands for pdf-text
    const run_text = b.addRunArtifact(pdf_text);
    if (b.args) |args| {
        run_text.addArgs(args);
    }
    const text_step = b.step("text", "Run pdf-text tool");
    text_step.dependOn(&run_text.step);
}
