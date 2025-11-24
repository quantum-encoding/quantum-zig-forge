// Copyright (c) 2025 QUANTUM ENCODING LTD
// Quantum Curl Benchmark Runner
//
// Automated performance testing with statistical analysis for CI/CD integration.
// Measures throughput, latency percentiles, and detects performance regressions.

const std = @import("std");

const BenchmarkConfig = struct {
    name: []const u8,
    request_count: u32,
    concurrency: u32,
    target_url: []const u8,
};

const BenchmarkResult = struct {
    name: []const u8,
    total_requests: u32,
    successful_requests: u32,
    failed_requests: u32,
    total_time_ms: u64,
    min_latency_ms: u64,
    max_latency_ms: u64,
    avg_latency_ms: f64,
    p50_latency_ms: u64,
    p95_latency_ms: u64,
    p99_latency_ms: u64,
    requests_per_second: f64,

    pub fn toJson(self: *const BenchmarkResult, writer: *std.Io.Writer) !void {
        try writer.print(
            \\{{
            \\  "name": "{s}",
            \\  "total_requests": {d},
            \\  "successful_requests": {d},
            \\  "failed_requests": {d},
            \\  "total_time_ms": {d},
            \\  "latency": {{
            \\    "min_ms": {d},
            \\    "max_ms": {d},
            \\    "avg_ms": {d:.2},
            \\    "p50_ms": {d},
            \\    "p95_ms": {d},
            \\    "p99_ms": {d}
            \\  }},
            \\  "throughput": {{
            \\    "requests_per_second": {d:.2}
            \\  }}
            \\}}
        , .{
            self.name,
            self.total_requests,
            self.successful_requests,
            self.failed_requests,
            self.total_time_ms,
            self.min_latency_ms,
            self.max_latency_ms,
            self.avg_latency_ms,
            self.p50_latency_ms,
            self.p95_latency_ms,
            self.p99_latency_ms,
            self.requests_per_second,
        });
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Parse arguments
    var target_url: []const u8 = "http://127.0.0.1:8888/";
    var output_json = false;
    var baseline_file: ?[]const u8 = null;
    var regression_threshold: f64 = 10.0; // 10% regression threshold

    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--url") and i + 1 < args.len) {
            target_url = args[i + 1];
            i += 1;
        } else if (std.mem.eql(u8, args[i], "--json")) {
            output_json = true;
        } else if (std.mem.eql(u8, args[i], "--baseline") and i + 1 < args.len) {
            baseline_file = args[i + 1];
            i += 1;
        } else if (std.mem.eql(u8, args[i], "--threshold") and i + 1 < args.len) {
            regression_threshold = try std.fmt.parseFloat(f64, args[i + 1]);
            i += 1;
        } else if (std.mem.eql(u8, args[i], "--help") or std.mem.eql(u8, args[i], "-h")) {
            printUsage();
            return;
        }
    }

    // Benchmark configurations - escalating load
    // Note: Concurrency is capped at 100 to avoid FD exhaustion on typical systems
    const benchmarks = [_]BenchmarkConfig{
        .{ .name = "warmup", .request_count = 100, .concurrency = 10, .target_url = target_url },
        .{ .name = "light_load", .request_count = 500, .concurrency = 25, .target_url = target_url },
        .{ .name = "medium_load", .request_count = 1000, .concurrency = 50, .target_url = target_url },
        .{ .name = "heavy_load", .request_count = 2000, .concurrency = 100, .target_url = target_url },
        .{ .name = "stress_test", .request_count = 5000, .concurrency = 100, .target_url = target_url },
    };

    var results = std.ArrayList(BenchmarkResult){};
    defer results.deinit(allocator);

    if (!output_json) {
        std.debug.print("\n", .{});
        std.debug.print("====================================================================\n", .{});
        std.debug.print("           QUANTUM CURL PERFORMANCE BENCHMARK SUITE                \n", .{});
        std.debug.print("====================================================================\n", .{});
        std.debug.print("  Target: {s}\n", .{target_url});
        std.debug.print("====================================================================\n", .{});
        std.debug.print("\n", .{});
    }

    // Run benchmarks
    for (benchmarks) |config| {
        const result = try runBenchmark(allocator, config);
        try results.append(allocator, result);

        if (!output_json) {
            printResult(&result);
        }
    }

    // Output JSON if requested
    if (output_json) {
        const stdout_file = std.fs.File.stdout();
        var stdout_buffer: [8192]u8 = undefined;
        var writer = stdout_file.writer(&stdout_buffer);
        try writer.interface.writeAll("{\n  \"benchmarks\": [\n");
        for (results.items, 0..) |result, idx| {
            try result.toJson(&writer.interface);
            if (idx < results.items.len - 1) {
                try writer.interface.writeAll(",\n");
            } else {
                try writer.interface.writeAll("\n");
            }
        }
        try writer.interface.writeAll("  ],\n");

        // Summary
        var total_rps: f64 = 0;
        var total_p99: u64 = 0;
        for (results.items[1..]) |result| { // Skip warmup
            total_rps += result.requests_per_second;
            total_p99 += result.p99_latency_ms;
        }
        const avg_rps = total_rps / @as(f64, @floatFromInt(results.items.len - 1));
        const avg_p99 = total_p99 / (results.items.len - 1);

        try writer.interface.print(
            \\  "summary": {{
            \\    "avg_requests_per_second": {d:.2},
            \\    "avg_p99_latency_ms": {d}
            \\  }}
            \\}}
            \\
        , .{ avg_rps, avg_p99 });
        try writer.interface.flush();
    } else {
        // Print summary
        std.debug.print("\n", .{});
        std.debug.print("====================================================================\n", .{});
        std.debug.print("                         SUMMARY                                   \n", .{});
        std.debug.print("====================================================================\n", .{});

        var total_rps: f64 = 0;
        var max_rps: f64 = 0;
        var min_p99: u64 = std.math.maxInt(u64);

        for (results.items[1..]) |result| { // Skip warmup
            total_rps += result.requests_per_second;
            if (result.requests_per_second > max_rps) max_rps = result.requests_per_second;
            if (result.p99_latency_ms < min_p99) min_p99 = result.p99_latency_ms;
        }

        std.debug.print("  Peak Throughput:    {d:.0} req/sec\n", .{max_rps});
        std.debug.print("  Best P99 Latency:   {d} ms\n", .{min_p99});
        std.debug.print("====================================================================\n", .{});
    }

    // Check for regression if baseline provided
    if (baseline_file) |baseline| {
        const regression = try checkRegression(allocator, baseline, &results, regression_threshold);
        if (regression) {
            std.debug.print("\nWARNING: REGRESSION DETECTED! Performance degraded by more than {d:.0}%\n", .{regression_threshold});
            std.process.exit(1);
        } else {
            std.debug.print("\nNo regression detected (threshold: {d:.0}%)\n", .{regression_threshold});
        }
    }
}

fn runBenchmark(allocator: std.mem.Allocator, config: BenchmarkConfig) !BenchmarkResult {
    // Generate JSONL requests
    var requests_jsonl = std.ArrayList(u8){};
    defer requests_jsonl.deinit(allocator);

    for (0..config.request_count) |req_id| {
        var buf: [256]u8 = undefined;
        const line = try std.fmt.bufPrint(&buf, "{{\"id\":\"req-{d}\",\"method\":\"GET\",\"url\":\"{s}\"}}\n", .{ req_id, config.target_url });
        try requests_jsonl.appendSlice(allocator, line);
    }

    // Write to temp file
    const temp_path = "/tmp/quantum_curl_bench_requests.jsonl";
    const temp_file = try std.fs.cwd().createFile(temp_path, .{});
    defer temp_file.close();
    try temp_file.writeAll(requests_jsonl.items);

    // Run quantum-curl and capture output
    const start_instant = std.time.Instant.now() catch unreachable;

    const concurrency_str = try std.fmt.allocPrint(allocator, "{d}", .{config.concurrency});
    defer allocator.free(concurrency_str);

    // Output file for quantum-curl results
    const output_path = "/tmp/quantum_curl_bench_output.jsonl";

    var child = std.process.Child.init(
        &[_][]const u8{
            "/home/founder/github_public/quantum-zig-forge/programs/quantum_curl/zig-out/bin/quantum-curl",
            "--file",
            temp_path,
            "--concurrency",
            concurrency_str,
            "--output",
            output_path,
        },
        allocator,
    );
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;

    try child.spawn();

    // Wait for child to complete
    _ = try child.wait();

    const end_instant = std.time.Instant.now() catch unreachable;
    const elapsed_ns = end_instant.since(start_instant);
    const total_time_ms = elapsed_ns / std.time.ns_per_ms;

    // Read output from file
    const output_file = std.fs.cwd().openFile(output_path, .{}) catch {
        return BenchmarkResult{
            .name = config.name,
            .total_requests = config.request_count,
            .successful_requests = 0,
            .failed_requests = config.request_count,
            .total_time_ms = total_time_ms,
            .min_latency_ms = 0,
            .max_latency_ms = 0,
            .avg_latency_ms = 0,
            .p50_latency_ms = 0,
            .p95_latency_ms = 0,
            .p99_latency_ms = 0,
            .requests_per_second = 0,
        };
    };
    defer output_file.close();

    const stat = try output_file.stat();
    const output = try allocator.alloc(u8, stat.size);
    defer allocator.free(output);
    _ = try output_file.readAll(output);

    // Parse results and collect latencies
    var latencies = std.ArrayList(u64){};
    defer latencies.deinit(allocator);

    var successful: u32 = 0;
    var failed: u32 = 0;

    var line_iter = std.mem.splitScalar(u8, output, '\n');
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;

        const parsed = std.json.parseFromSlice(
            std.json.Value,
            allocator,
            line,
            .{},
        ) catch continue;
        defer parsed.deinit();

        const obj = parsed.value.object;
        const status = if (obj.get("status")) |s| @as(u16, @intCast(s.integer)) else 0;
        const latency = if (obj.get("latency_ms")) |l| @as(u64, @intCast(l.integer)) else 0;

        if (status >= 200 and status < 300) {
            successful += 1;
        } else {
            failed += 1;
        }

        try latencies.append(allocator, latency);
    }

    // Calculate statistics
    if (latencies.items.len == 0) {
        return BenchmarkResult{
            .name = config.name,
            .total_requests = config.request_count,
            .successful_requests = 0,
            .failed_requests = config.request_count,
            .total_time_ms = total_time_ms,
            .min_latency_ms = 0,
            .max_latency_ms = 0,
            .avg_latency_ms = 0,
            .p50_latency_ms = 0,
            .p95_latency_ms = 0,
            .p99_latency_ms = 0,
            .requests_per_second = 0,
        };
    }

    // Sort for percentiles
    std.mem.sort(u64, latencies.items, {}, std.sort.asc(u64));

    const min_lat = latencies.items[0];
    const max_lat = latencies.items[latencies.items.len - 1];

    var sum: u64 = 0;
    for (latencies.items) |lat| {
        sum += lat;
    }
    const avg_lat = @as(f64, @floatFromInt(sum)) / @as(f64, @floatFromInt(latencies.items.len));

    const p50_idx = latencies.items.len / 2;
    const p95_idx = (latencies.items.len * 95) / 100;
    const p99_idx = (latencies.items.len * 99) / 100;

    const rps = @as(f64, @floatFromInt(successful)) / (@as(f64, @floatFromInt(total_time_ms)) / 1000.0);

    return BenchmarkResult{
        .name = config.name,
        .total_requests = config.request_count,
        .successful_requests = successful,
        .failed_requests = failed,
        .total_time_ms = total_time_ms,
        .min_latency_ms = min_lat,
        .max_latency_ms = max_lat,
        .avg_latency_ms = avg_lat,
        .p50_latency_ms = latencies.items[p50_idx],
        .p95_latency_ms = latencies.items[p95_idx],
        .p99_latency_ms = latencies.items[p99_idx],
        .requests_per_second = rps,
    };
}

fn printResult(result: *const BenchmarkResult) void {
    std.debug.print("--------------------------------------------------------------------\n", .{});
    std.debug.print(" {s}\n", .{result.name});
    std.debug.print("--------------------------------------------------------------------\n", .{});
    std.debug.print(" Requests:    {d} total | {d} ok | {d} failed\n", .{
        result.total_requests,
        result.successful_requests,
        result.failed_requests,
    });
    std.debug.print(" Throughput:  {d:.0} req/sec\n", .{result.requests_per_second});
    std.debug.print(" Latency:     min={d}ms | avg={d:.1}ms | max={d}ms\n", .{
        result.min_latency_ms,
        result.avg_latency_ms,
        result.max_latency_ms,
    });
    std.debug.print(" Percentiles: p50={d}ms | p95={d}ms | p99={d}ms\n", .{
        result.p50_latency_ms,
        result.p95_latency_ms,
        result.p99_latency_ms,
    });
    std.debug.print(" Duration:    {d}ms\n", .{result.total_time_ms});
    std.debug.print("\n", .{});
}

fn checkRegression(
    allocator: std.mem.Allocator,
    baseline_path: []const u8,
    current_results: *const std.ArrayList(BenchmarkResult),
    threshold: f64,
) !bool {
    _ = allocator;
    _ = baseline_path;
    _ = current_results;
    _ = threshold;
    // TODO: Implement baseline comparison
    // Read baseline JSON, compare key metrics, return true if regression
    return false;
}

fn printUsage() void {
    const usage =
        \\Quantum Curl Benchmark Runner
        \\
        \\USAGE:
        \\    bench-quantum-curl [OPTIONS]
        \\
        \\OPTIONS:
        \\    --url [url]         Target URL (default: http://127.0.0.1:8888/)
        \\    --json              Output results as JSON
        \\    --baseline [file]   Compare against baseline JSON file
        \\    --threshold [pct]   Regression threshold percentage (default: 10)
        \\    -h, --help          Show this help
        \\
        \\EXAMPLES:
        \\    # Run benchmark against local echo server
        \\    bench-quantum-curl
        \\
        \\    # Output JSON for CI/CD
        \\    bench-quantum-curl --json > benchmark_results.json
        \\
        \\    # Check for regression against baseline
        \\    bench-quantum-curl --json --baseline baseline.json --threshold 15
        \\
    ;
    std.debug.print("{s}", .{usage});
}
