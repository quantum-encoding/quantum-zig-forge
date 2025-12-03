const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // WebSocket dependency commented out - implementing without external deps for now
    // const websocket_dep = b.dependency("websocket", .{
    //     .target = target,
    //     .optimize = optimize,
    // });

    // ========================================================================
    // Core FFI Static Library (ZERO DEPENDENCIES)
    // ========================================================================

    const core_module = b.createModule(.{
        .root_source_file = b.path("src/financial_core.zig"),
        .target = target,
        .optimize = optimize,
    });

    const core_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "financial_core",
        .root_module = core_module,
    });

    core_lib.linkLibC();
    // NO ZMQ, NO EXTERNAL DEPS

    // Install the core library
    b.installArtifact(core_lib);

    const core_step = b.step("core", "Build core FFI static library (zero deps)");
    core_step.dependOn(&b.addInstallArtifact(core_lib, .{}).step);

    // ========================================================================
    // Full FFI Static Library (with ZMQ dependencies)
    // ========================================================================

    const ffi_module = b.createModule(.{
        .root_source_file = b.path("src/ffi.zig"),
        .target = target,
        .optimize = optimize,
    });

    const ffi_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "financial_engine",
        .root_module = ffi_module,
    });

    ffi_lib.linkLibC();
    ffi_lib.linkSystemLibrary("zmq");
    ffi_lib.installHeader(b.path("include/financial_engine.h"), "financial_engine.h");

    // Install the static library
    b.installArtifact(ffi_lib);

    const ffi_step = b.step("ffi", "Build full FFI static library (with ZMQ)");
    ffi_step.dependOn(&b.addInstallArtifact(ffi_lib, .{}).step);

    // Main executable
    const exe = b.addExecutable(.{
        .name = "zig-financial-engine",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    
    // WebSocket module commented out for now
    // exe.root_module.addImport("websocket", websocket_dep.module("websocket"));
    
    // Install the executable
    b.installArtifact(exe);
    
    // HFT System executable
    const hft_exe = b.addExecutable(.{
        .name = "hft-system",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/hft_system.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Link with ZMQ library
    hft_exe.linkSystemLibrary("zmq");
    hft_exe.linkLibC();

    b.installArtifact(hft_exe);
    
    // Alpaca test executable (file missing - commented out)
    // const alpaca_exe = b.addExecutable(.{
    //     .name = "alpaca-test",
    //     .root_module = b.createModule(.{
    //         .root_source_file = b.path("src/alpaca_test.zig"),
    //         .target = target,
    //         .optimize = optimize,
    //     }),
    // });
    //
    // // WebSocket modules commented out for now
    // // alpaca_exe.root_module.addImport("websocket", websocket_dep.module("websocket"));
    //
    // b.installArtifact(alpaca_exe);
    
    // Live trading executable
    const live_exe = b.addExecutable(.{
        .name = "live-trading",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/live_trading.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // Link with ZMQ library
    live_exe.linkSystemLibrary("zmq");
    live_exe.linkLibC();

    // live_exe.root_module.addImport("websocket", websocket_dep.module("websocket"));

    b.installArtifact(live_exe);

    // Real HFT System executable
    // NOTE: Force ReleaseFast due to Zig 0.16 dev DWARF bug with libwebsockets/libsystemd in Debug mode
    const real_hft_optimize = if (optimize == .Debug) .ReleaseFast else optimize;
    const real_hft_exe = b.addExecutable(.{
        .name = "real-hft-system",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/hft_alpaca_real.zig"),
            .target = target,
            .optimize = real_hft_optimize,
        }),
    });

    // Link with libwebsockets for real WebSocket connectivity
    real_hft_exe.linkSystemLibrary("websockets");
    real_hft_exe.linkSystemLibrary("zmq");
    real_hft_exe.linkLibC();

    b.installArtifact(real_hft_exe);
    
    // Trading API test executable
    const trading_api_exe = b.addExecutable(.{
        .name = "trading-api-test",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/alpaca_trading_api.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    
    b.installArtifact(trading_api_exe);
    
    // Real connection test executable (file missing - commented out)
    // const real_test_exe = b.addExecutable(.{
    //     .name = "real-connection-test",
    //     .root_module = b.createModule(.{
    //         .root_source_file = b.path("src/real_connection_test.zig"),
    //         .target = target,
    //         .optimize = optimize,
    //     }),
    // });
    //
    // // real_test_exe.root_module.addImport("websocket", websocket_dep.module("websocket"));
    //
    // b.installArtifact(real_test_exe);
    
    // Run commands
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    
    const run_step = b.step("run", "Run the main application");
    run_step.dependOn(&run_cmd.step);
    
    // Test command (commented out - file missing)
    // const alpaca_run_cmd = b.addRunArtifact(alpaca_exe);
    // const alpaca_run_step = b.step("test-alpaca", "Test Alpaca connection");
    // alpaca_run_step.dependOn(&alpaca_run_cmd.step);
    
    // Live trading command
    const live_run_cmd = b.addRunArtifact(live_exe);
    const live_run_step = b.step("live", "Run live trading system");
    live_run_step.dependOn(&live_run_cmd.step);
    
    // Real HFT system command
    const real_hft_run_cmd = b.addRunArtifact(real_hft_exe);
    const real_hft_run_step = b.step("real-hft", "Run real HFT system with Alpaca");
    real_hft_run_step.dependOn(&real_hft_run_cmd.step);
    
    // Trading API test command
    const trading_api_run_cmd = b.addRunArtifact(trading_api_exe);
    const trading_api_run_step = b.step("test-trading-api", "Test Alpaca trading API");
    trading_api_run_step.dependOn(&trading_api_run_cmd.step);

    // ========================================================================
    // Sentient Network Signal Broadcast
    // ========================================================================

    // Signal Broadcast static library (for Rust FFI)
    const signal_module = b.createModule(.{
        .root_source_file = b.path("src/signal_broadcast.zig"),
        .target = target,
        .optimize = optimize,
    });

    const signal_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "signal_broadcast",
        .root_module = signal_module,
    });

    signal_lib.linkLibC();
    signal_lib.linkSystemLibrary("zmq");
    signal_lib.installHeader(b.path("include/signal_broadcast.h"), "signal_broadcast.h");

    b.installArtifact(signal_lib);

    const signal_lib_step = b.step("signal-lib", "Build signal broadcast static library");
    signal_lib_step.dependOn(&b.addInstallArtifact(signal_lib, .{}).step);

    // Signal Broadcast executable (test server/client)
    const signal_exe = b.addExecutable(.{
        .name = "signal-broadcast",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/signal_broadcast.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    signal_exe.linkLibC();
    signal_exe.linkSystemLibrary("zmq");

    b.installArtifact(signal_exe);

    // Signal server command
    const signal_server_cmd = b.addRunArtifact(signal_exe);
    signal_server_cmd.addArg("server");
    const signal_server_step = b.step("signal-server", "Run signal broadcast server");
    signal_server_step.dependOn(&signal_server_cmd.step);

    // Signal client command
    const signal_client_cmd = b.addRunArtifact(signal_exe);
    signal_client_cmd.addArg("client");
    const signal_client_step = b.step("signal-client", "Run signal broadcast client");
    signal_client_step.dependOn(&signal_client_cmd.step);

    // ========================================================================
    // Tests
    // ========================================================================

    const signal_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/signal_broadcast.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    signal_tests.linkLibC();

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&b.addRunArtifact(signal_tests).step);
}