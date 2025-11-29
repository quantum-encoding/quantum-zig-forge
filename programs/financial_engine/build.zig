const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // WebSocket dependency commented out - implementing without external deps for now
    // const websocket_dep = b.dependency("websocket", .{
    //     .target = target,
    //     .optimize = optimize,
    // });
    
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
    
    // Real connection test command (commented out - file missing)
    // const real_test_run_cmd = b.addRunArtifact(real_test_exe);
    // const real_test_run_step = b.step("test-real-connections", "Test real Alpaca connections");
    // real_test_run_step.dependOn(&real_test_run_cmd.step);
}