//! Compression Formula Benchmark
//!
//! Actually executes compression algorithms against benchmark data and measures:
//! - Compression ratio (compressed_size / original_size)
//! - Throughput (MB/s)
//! - Lossless verification (decompress and compare)
//! - Per-formula timing
//!
//! Input:
//!   --formulas <file>    File with one formula per line (e.g., "RLE", "BWT+MTF+RLE")
//!   --input <file>       Benchmark data file to compress
//!   --output <dir>       Directory for results
//!
//! Output:
//!   results.json         Per-formula metrics
//!   results.csv          Tabular results for analysis
//!   best_compressed.bin  Best compression result (optional)

const std = @import("std");
const posix = std.posix;

// ============================================================================
// Compression Algorithms (Implemented)
// ============================================================================

/// Run-Length Encoding
const RLE = struct {
    const max_buf_size = 1024 * 1024; // 1MB max

    threadlocal var encode_buf: [max_buf_size]u8 = undefined;
    threadlocal var decode_buf: [max_buf_size]u8 = undefined;

    pub fn encode(input: []const u8) ![]const u8 {
        if (input.len == 0) return input[0..0];
        if (input.len > max_buf_size / 2) return error.InputTooLarge;

        var out_len: usize = 0;
        var i: usize = 0;

        while (i < input.len) {
            const char = input[i];
            var count: u8 = 1;

            while (i + count < input.len and input[i + count] == char and count < 255) {
                count += 1;
            }

            if (out_len + 2 > encode_buf.len) return error.OutputTooLarge;
            encode_buf[out_len] = count;
            encode_buf[out_len + 1] = char;
            out_len += 2;
            i += count;
        }

        return encode_buf[0..out_len];
    }

    pub fn decode(input: []const u8) ![]const u8 {
        var out_len: usize = 0;
        var i: usize = 0;

        while (i + 1 < input.len) {
            const count = input[i];
            const char = input[i + 1];

            if (out_len + count > decode_buf.len) return error.OutputTooLarge;

            @memset(decode_buf[out_len..][0..count], char);
            out_len += count;
            i += 2;
        }

        return decode_buf[0..out_len];
    }
};

/// Delta Encoding (for sorted/sequential data)
const Delta = struct {
    const max_buf_size = 1024 * 1024;

    threadlocal var encode_buf: [max_buf_size]u8 = undefined;
    threadlocal var decode_buf: [max_buf_size]u8 = undefined;

    pub fn encode(input: []const u8) ![]const u8 {
        if (input.len == 0) return input[0..0];
        if (input.len > max_buf_size) return error.InputTooLarge;

        encode_buf[0] = input[0];
        for (1..input.len) |i| {
            // Store difference (wrapping)
            encode_buf[i] = input[i] -% input[i - 1];
        }

        return encode_buf[0..input.len];
    }

    pub fn decode(input: []const u8) ![]const u8 {
        if (input.len == 0) return input[0..0];
        if (input.len > max_buf_size) return error.InputTooLarge;

        decode_buf[0] = input[0];
        for (1..input.len) |i| {
            decode_buf[i] = decode_buf[i - 1] +% input[i];
        }

        return decode_buf[0..input.len];
    }
};

/// Move-to-Front Transform
const MTF = struct {
    const max_buf_size = 1024 * 1024;

    threadlocal var encode_buf: [max_buf_size]u8 = undefined;
    threadlocal var decode_buf: [max_buf_size]u8 = undefined;
    threadlocal var alphabet: [256]u8 = undefined;

    fn initAlphabet() void {
        for (0..256) |i| {
            alphabet[i] = @intCast(i);
        }
    }

    fn moveToFront(idx: u8) void {
        const char = alphabet[idx];
        var i: usize = idx;
        while (i > 0) : (i -= 1) {
            alphabet[i] = alphabet[i - 1];
        }
        alphabet[0] = char;
    }

    pub fn encode(input: []const u8) ![]const u8 {
        if (input.len > max_buf_size) return error.InputTooLarge;

        initAlphabet();

        for (input, 0..) |char, i| {
            // Find position in alphabet
            var pos: u8 = 0;
            for (alphabet, 0..) |a, j| {
                if (a == char) {
                    pos = @intCast(j);
                    break;
                }
            }
            encode_buf[i] = pos;
            moveToFront(pos);
        }

        return encode_buf[0..input.len];
    }

    pub fn decode(input: []const u8) ![]const u8 {
        if (input.len > max_buf_size) return error.InputTooLarge;

        initAlphabet();

        for (input, 0..) |pos, i| {
            const char = alphabet[pos];
            decode_buf[i] = char;
            moveToFront(pos);
        }

        return decode_buf[0..input.len];
    }
};

// ============================================================================
// Formula Parser and Executor
// ============================================================================

const CompressionStep = enum {
    rle,
    delta,
    mtf,
    // Add more as implemented
};

const CompressionResult = struct {
    compressed_data: []const u8,
    original_size: usize,
    compressed_size: usize,
    ratio: f64,
    is_lossless: bool,
    encode_time_ns: i128,
    decode_time_ns: i128,
    throughput_mbps: f64,
};

/// Parse a formula string like "RLE", "DELTA+RLE", "MTF+RLE"
fn parseFormula(formula: []const u8, steps: *[16]CompressionStep) !usize {
    var count: usize = 0;
    var iter = std.mem.splitScalar(u8, formula, '+');

    while (iter.next()) |step_name| {
        const trimmed = std.mem.trim(u8, step_name, &std.ascii.whitespace);

        if (std.ascii.eqlIgnoreCase(trimmed, "RLE")) {
            steps[count] = .rle;
        } else if (std.ascii.eqlIgnoreCase(trimmed, "DELTA")) {
            steps[count] = .delta;
        } else if (std.ascii.eqlIgnoreCase(trimmed, "MTF")) {
            steps[count] = .mtf;
        } else {
            // Unknown step - skip this formula
            return error.UnknownStep;
        }

        count += 1;
        if (count >= 16) break;
    }

    return count;
}

/// Execute a compression pipeline
fn executeCompression(
    input: []const u8,
    steps: []const CompressionStep,
) !CompressionResult {
    const start_time = posix.clock_gettime(.MONOTONIC) catch return error.TimerFailed;

    // Apply each compression step
    var current = input;
    for (steps) |step| {
        current = switch (step) {
            .rle => try RLE.encode(current),
            .delta => try Delta.encode(current),
            .mtf => try MTF.encode(current),
        };
    }

    const encode_end = posix.clock_gettime(.MONOTONIC) catch return error.TimerFailed;

    const compressed = current;
    const compressed_size = compressed.len;

    // Verify lossless by decompressing
    var decompressed = compressed;

    // Apply decompression in reverse order
    var i: usize = steps.len;
    while (i > 0) {
        i -= 1;
        decompressed = switch (steps[i]) {
            .rle => try RLE.decode(decompressed),
            .delta => try Delta.decode(decompressed),
            .mtf => try MTF.decode(decompressed),
        };
    }

    const decode_end = posix.clock_gettime(.MONOTONIC) catch return error.TimerFailed;

    // Verify lossless
    const is_lossless = std.mem.eql(u8, input, decompressed);

    // Calculate timing
    const encode_ns = (@as(i128, encode_end.sec) - @as(i128, start_time.sec)) * 1_000_000_000 +
        (@as(i128, encode_end.nsec) - @as(i128, start_time.nsec));
    const decode_ns = (@as(i128, decode_end.sec) - @as(i128, encode_end.sec)) * 1_000_000_000 +
        (@as(i128, decode_end.nsec) - @as(i128, encode_end.nsec));

    const total_ns = encode_ns + decode_ns;
    const throughput = if (total_ns > 0)
        @as(f64, @floatFromInt(input.len)) / @as(f64, @floatFromInt(total_ns)) * 1000.0 // MB/s
    else
        0.0;

    return CompressionResult{
        .compressed_data = compressed,
        .original_size = input.len,
        .compressed_size = compressed_size,
        .ratio = @as(f64, @floatFromInt(compressed_size)) / @as(f64, @floatFromInt(input.len)),
        .is_lossless = is_lossless,
        .encode_time_ns = encode_ns,
        .decode_time_ns = decode_ns,
        .throughput_mbps = throughput,
    };
}

// ============================================================================
// Result Tracking
// ============================================================================

const FormulaResult = struct {
    formula: []const u8,
    ratio: f64,
    is_lossless: bool,
    throughput_mbps: f64,
    original_size: usize,
    compressed_size: usize,
    encode_time_ns: i128,

    fn lessThan(_: void, a: FormulaResult, b: FormulaResult) bool {
        // Sort by ratio (lower is better), but only if lossless
        if (a.is_lossless and !b.is_lossless) return true;
        if (!a.is_lossless and b.is_lossless) return false;
        return a.ratio < b.ratio;
    }
};

// ============================================================================
// Main
// ============================================================================

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Parse arguments
    var formulas_path: ?[]const u8 = null;
    var input_path: ?[]const u8 = null;
    var output_dir: []const u8 = "./bench_results";
    var top_n: usize = 20;

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();
    _ = args.skip();

    while (args.next()) |arg| {
        if (std.mem.eql(u8, arg, "--formulas")) {
            if (args.next()) |v| formulas_path = v;
        } else if (std.mem.eql(u8, arg, "--input")) {
            if (args.next()) |v| input_path = v;
        } else if (std.mem.eql(u8, arg, "--output")) {
            if (args.next()) |v| output_dir = v;
        } else if (std.mem.eql(u8, arg, "--top")) {
            if (args.next()) |v| top_n = try std.fmt.parseInt(usize, v, 10);
        }
    }

    if (formulas_path == null or input_path == null) {
        std.debug.print("Usage: compression-bench --formulas <file> --input <data_file> [--output <dir>] [--top N]\n", .{});
        std.debug.print("\nThis benchmark:\n", .{});
        std.debug.print("  1. Loads benchmark data from --input\n", .{});
        std.debug.print("  2. Tries each formula from --formulas\n", .{});
        std.debug.print("  3. Measures compression ratio, speed, lossless verification\n", .{});
        std.debug.print("  4. Outputs results to --output directory\n", .{});
        return;
    }

    // Load input data
    const input_file = try std.fs.cwd().openFile(input_path.?, .{});
    defer input_file.close();
    const input_stat = try input_file.stat();
    const input_data = try allocator.alloc(u8, input_stat.size);
    defer allocator.free(input_data);
    _ = try input_file.preadAll(input_data, 0);

    // Load formulas
    const formulas_file = try std.fs.cwd().openFile(formulas_path.?, .{});
    defer formulas_file.close();
    const formulas_stat = try formulas_file.stat();
    const formulas_content = try allocator.alloc(u8, formulas_stat.size);
    defer allocator.free(formulas_content);
    _ = try formulas_file.preadAll(formulas_content, 0);

    // Count formulas
    var formula_count: usize = 0;
    var line_iter = std.mem.splitScalar(u8, formulas_content, '\n');
    while (line_iter.next()) |line| {
        if (std.mem.trim(u8, line, &std.ascii.whitespace).len > 0) {
            formula_count += 1;
        }
    }

    std.debug.print("\n", .{});
    std.debug.print("╔══════════════════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  COMPRESSION FORMULA BENCHMARK                                        ║\n", .{});
    std.debug.print("╠══════════════════════════════════════════════════════════════════════╣\n", .{});
    std.debug.print("║  Input Size: {} bytes                                                \n", .{input_data.len});
    std.debug.print("║  Formulas: {}                                                        \n", .{formula_count});
    std.debug.print("╚══════════════════════════════════════════════════════════════════════╝\n", .{});
    std.debug.print("\n", .{});

    // Process each formula
    var results = std.ArrayList(FormulaResult).init(allocator);
    defer results.deinit();

    var successful: usize = 0;
    var lossless_count: usize = 0;
    var best_ratio: f64 = 999.0;

    const start_time = try posix.clock_gettime(.MONOTONIC);

    line_iter = std.mem.splitScalar(u8, formulas_content, '\n');
    while (line_iter.next()) |line| {
        const formula = std.mem.trim(u8, line, &std.ascii.whitespace);
        if (formula.len == 0) continue;

        var steps: [16]CompressionStep = undefined;
        const step_count = parseFormula(formula, &steps) catch continue;
        if (step_count == 0) continue;

        const result = executeCompression(input_data, steps[0..step_count]) catch continue;

        successful += 1;
        if (result.is_lossless) {
            lossless_count += 1;
            if (result.ratio < best_ratio) {
                best_ratio = result.ratio;
            }
        }

        // Store result
        const formula_copy = try allocator.dupe(u8, formula);
        try results.append(.{
            .formula = formula_copy,
            .ratio = result.ratio,
            .is_lossless = result.is_lossless,
            .throughput_mbps = result.throughput_mbps,
            .original_size = result.original_size,
            .compressed_size = result.compressed_size,
            .encode_time_ns = result.encode_time_ns,
        });
    }

    const end_time = try posix.clock_gettime(.MONOTONIC);
    const elapsed_ns = (@as(i128, end_time.sec) - @as(i128, start_time.sec)) * 1_000_000_000 +
        (@as(i128, end_time.nsec) - @as(i128, start_time.nsec));
    const elapsed_secs = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0;

    // Sort by compression ratio (best first)
    std.mem.sort(FormulaResult, results.items, {}, FormulaResult.lessThan);

    // Print results
    std.debug.print("╔══════════════════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  RESULTS                                                             ║\n", .{});
    std.debug.print("╠══════════════════════════════════════════════════════════════════════╣\n", .{});
    std.debug.print("║  Formulas Tested: {} / {}                                            \n", .{ successful, formula_count });
    std.debug.print("║  Lossless: {}                                                        \n", .{lossless_count});
    std.debug.print("║  Best Ratio: {d:.4}                                                  \n", .{best_ratio});
    std.debug.print("║  Total Time: {d:.3}s                                                 \n", .{elapsed_secs});
    std.debug.print("╠══════════════════════════════════════════════════════════════════════╣\n", .{});
    std.debug.print("║  TOP {} RESULTS                                                      \n", .{top_n});
    std.debug.print("╠══════════════════════════════════════════════════════════════════════╣\n", .{});

    for (results.items[0..@min(top_n, results.items.len)], 0..) |r, i| {
        const lossless_str: []const u8 = if (r.is_lossless) "✓" else "✗";
        std.debug.print("║  {}: {s} ratio={d:.4} {s} {} → {} bytes\n", .{
            i + 1,
            lossless_str,
            r.ratio,
            r.formula,
            r.original_size,
            r.compressed_size,
        });
    }

    std.debug.print("╚══════════════════════════════════════════════════════════════════════╝\n", .{});

    // Create output directory and save results
    std.fs.cwd().makeDir(output_dir) catch {};

    // Save CSV results
    const csv_path = try std.fmt.allocPrint(allocator, "{s}/results.csv", .{output_dir});
    defer allocator.free(csv_path);

    const csv_file = try std.fs.cwd().createFile(csv_path, .{});
    defer csv_file.close();

    try csv_file.writeAll("rank,formula,ratio,lossless,original_bytes,compressed_bytes,throughput_mbps\n");

    for (results.items, 0..) |r, i| {
        var line_buf: [1024]u8 = undefined;
        const csv_line = try std.fmt.bufPrint(&line_buf, "{},{s},{d:.6},{},{},{},{d:.2}\n", .{
            i + 1,
            r.formula,
            r.ratio,
            @as(u8, if (r.is_lossless) 1 else 0),
            r.original_size,
            r.compressed_size,
            r.throughput_mbps,
        });
        try csv_file.writeAll(csv_line);
    }

    std.debug.print("\nResults saved to: {s}/results.csv\n", .{output_dir});

    // Free formula strings
    for (results.items) |r| {
        allocator.free(r.formula);
    }
}
