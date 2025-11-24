// SPDX-License-Identifier: Dual License - MIT (Non-Commercial) / Commercial License
//
// cognitive-graph.zig - Cognitive Graph CLI Tool
//
// Purpose: Generate SVG graphs from cognitive telemetry data
// Usage: cognitive-graph --window 60 --output graph.svg
//
// THE VISUALIZER - Rendering Divine Thought as Art

const std = @import("std");
const cognitive_metrics = @import("cognitive_metrics.zig");
const cognitive_states = @import("cognitive_states.zig");
const svg_exporter = @import("svg_exporter.zig");
const dbus = @import("dbus_bindings.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("🔮 Cognitive Graph Generator v1.0\n", .{});
    std.debug.print("   Rendering cognitive telemetry as SVG\n\n", .{});

    // Parse command line arguments
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next(); // Skip program name

    var window_seconds: u64 = 60;
    var output_path: []const u8 = "cognitive-graph.svg";
    var use_dbus = true;

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--window")) {
            if (args.next()) |value| {
                window_seconds = try std.fmt.parseInt(u64, value, 10);
            }
        } else if (std.mem.eql(u8, arg, "--output")) {
            if (args.next()) |value| {
                output_path = value;
            }
        } else if (std.mem.eql(u8, arg, "--no-dbus")) {
            use_dbus = false;
        } else if (std.mem.eql(u8, arg, "--help")) {
            printHelp();
            return;
        }
    }

    std.debug.print("Configuration:\n", .{});
    std.debug.print("  Window: {d} seconds\n", .{window_seconds});
    std.debug.print("  Output: {s}\n", .{output_path});
    std.debug.print("  D-Bus: {}\n\n", .{use_dbus});

    if (use_dbus) {
        // Fetch data from chronosd-cognitive via D-Bus
        try generateFromDBus(allocator, window_seconds, output_path);
    } else {
        // Generate with mock data (for testing)
        try generateMockGraph(allocator, window_seconds, output_path);
    }

    std.debug.print("✅ Graph generated: {s}\n", .{output_path});
}

fn generateFromDBus(allocator: std.mem.Allocator, window_seconds: u64, output_path: []const u8) !void {
    std.debug.print("📡 Connecting to chronosd-cognitive via D-Bus...\n", .{});

    // Connect to D-Bus
    var conn = dbus.DBusConnection.init(dbus.BusType.SYSTEM) catch {
        std.debug.print("❌ Failed to connect to D-Bus\n", .{});
        std.debug.print("   Is chronosd-cognitive running?\n", .{});
        std.debug.print("   Try: sudo systemctl status chronosd-cognitive\n\n", .{});
        std.debug.print("Falling back to mock data...\n\n", .{});
        try generateMockGraph(allocator, window_seconds, output_path);
        return;
    };
    defer conn.deinit();

    std.debug.print("✓ Connected to D-Bus\n", .{});
    std.debug.print("📊 Fetching metrics...\n", .{});

    // TODO: Call GetMetrics() and GetStateHistory() D-Bus methods
    // For now, use mock data
    std.debug.print("⚠️  D-Bus API not yet implemented, using mock data\n\n", .{});
    try generateMockGraph(allocator, window_seconds, output_path);
}

fn generateMockGraph(allocator: std.mem.Allocator, window_seconds: u64, output_path: []const u8) !void {
    std.debug.print("🎨 Generating graph with mock data...\n", .{});

    var aggregator = try cognitive_metrics.MetricsAggregator.init(allocator, window_seconds);
    defer aggregator.deinit();

    // Generate mock state history
    // Zig 0.16: Use std.posix.clock_gettime for wall clock time
    const ts = try std.posix.clock_gettime(std.posix.CLOCK.REALTIME);
    const now_ns = @as(u64, @intCast(@as(i128, ts.sec) * std.time.ns_per_s + ts.nsec));
    const start_ns = now_ns - (window_seconds * std.time.ns_per_s);

    const states = [_][]const u8{
        "Channelling",
        "Synthesizing",
        "Thinking",
        "Finagling",
        "Channelling",
        "Pondering",
        "Channelling",
        "Crafting",
        "Channelling",
    };

    std.debug.print("  Generating {d} state events...\n", .{states.len});

    for (states, 0..) |state, i| {
        const timestamp_ns = start_ns + (i * window_seconds * std.time.ns_per_s) / states.len;
        const confidence = cognitive_metrics.calculateConfidence(state, &[_][]const u8{});

        try aggregator.addStateEvent(.{
            .timestamp_ns = timestamp_ns,
            .state = state,
            .confidence = confidence,
            .phi_timestamp = @as(f64, @floatFromInt(timestamp_ns)) * 1.618033988749895 / @as(f64, @floatFromInt(std.time.ns_per_s)),
        });
    }

    // Generate mock tool events
    const activities = [_]cognitive_metrics.ToolActivity{
        .writing_file,
        .editing_file,
        .writing_file,
        .executing_command,
        .writing_file,
        .editing_file,
    };

    std.debug.print("  Generating {d} tool events...\n", .{activities.len});

    for (activities, 0..) |activity, i| {
        const timestamp_ns = start_ns + (i * window_seconds * std.time.ns_per_s) / activities.len;

        try aggregator.addToolEvent(.{
            .timestamp_ns = timestamp_ns,
            .activity = activity,
            .success = true,
            .duration_ns = 50000000, // 50ms
            .phi_timestamp = @as(f64, @floatFromInt(timestamp_ns)) * 1.618033988749895 / @as(f64, @floatFromInt(std.time.ns_per_s)),
        });
    }

    // Compute metrics
    std.debug.print("  Computing metrics...\n", .{});
    const metrics = try aggregator.compute();

    std.debug.print("  Current state: {s}\n", .{metrics.current_state});
    std.debug.print("  Confidence: {d:.0}%\n", .{metrics.confidence * 100.0});
    std.debug.print("  Tool rate: {d:.1}/min\n", .{metrics.tool_rate});

    // Export to SVG
    std.debug.print("  Exporting SVG...\n", .{});
    var exporter = svg_exporter.SVGExporter.init(allocator);

    const state_history = aggregator.getStateHistory(start_ns, now_ns);
    const tool_history = aggregator.getToolHistory(start_ns, now_ns);

    try exporter.exportGraph(metrics, state_history, tool_history, output_path);
}

fn printHelp() void {
    std.debug.print(
        \\Usage: cognitive-graph [OPTIONS]
        \\
        \\Generate SVG graphs from cognitive telemetry data
        \\
        \\Options:
        \\  --window <seconds>    Time window for analysis (default: 60)
        \\  --output <path>       Output SVG file path (default: cognitive-graph.svg)
        \\  --no-dbus             Use mock data instead of D-Bus
        \\  --help                Show this help message
        \\
        \\Examples:
        \\  cognitive-graph --window 120 --output graph.svg
        \\  cognitive-graph --no-dbus
        \\
        \\D-Bus Integration:
        \\  This tool fetches data from chronosd-cognitive via D-Bus.
        \\  Make sure the daemon is running:
        \\    sudo systemctl start chronosd-cognitive
        \\
        \\Output:
        \\  Generates a beautiful SVG graph showing:
        \\  - Cognitive state timeline (color-coded bands)
        \\  - Confidence levels (white line overlay)
        \\  - Tool activity breakdown (horizontal bars)
        \\  - Health metrics panel
        \\
        \\🔮 Cognitive Graph Generator - Rendering Divine Thought as Art
        \\
    , .{});
}
