//! Compression Formula Benchmark
//!
//! Actually executes compression algorithms against benchmark data and measures:
//! - Compression ratio (compressed_size / original_size)
//! - Throughput (MB/s)
//! - Lossless verification (decompress and compare)
//! - Per-formula timing
//!
//! Implements the "Core 8" algorithms for real compression testing.

const std = @import("std");
const posix = std.posix;
const Allocator = std.mem.Allocator;

// ============================================================================
// Compression Algorithms - Allocator-based (safe for chaining)
// ============================================================================

/// Run-Length Encoding
const RLE = struct {
    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        // Worst case: no runs, every byte gets count prefix = 2x size
        var output = try std.ArrayListUnmanaged(u8).initCapacity(allocator, input.len * 2);
        errdefer output.deinit(allocator);

        var i: usize = 0;
        while (i < input.len) {
            const char = input[i];
            var count: u8 = 1;

            while (i + count < input.len and input[i + count] == char and count < 255) {
                count += 1;
            }

            try output.append(allocator, count);
            try output.append(allocator, char);
            i += count;
        }

        return output.toOwnedSlice(allocator);
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        // Calculate output size first
        var out_size: usize = 0;
        var i: usize = 0;
        while (i + 1 < input.len) : (i += 2) {
            out_size += input[i];
        }

        var output = try allocator.alloc(u8, out_size);
        var out_idx: usize = 0;

        i = 0;
        while (i + 1 < input.len) : (i += 2) {
            const count = input[i];
            const char = input[i + 1];
            @memset(output[out_idx..][0..count], char);
            out_idx += count;
        }

        return output;
    }
};

/// Delta Encoding
const Delta = struct {
    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try allocator.alloc(u8, input.len);
        output[0] = input[0];
        for (1..input.len) |i| {
            output[i] = input[i] -% input[i - 1];
        }
        return output;
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try allocator.alloc(u8, input.len);
        output[0] = input[0];
        for (1..input.len) |i| {
            output[i] = output[i - 1] +% input[i];
        }
        return output;
    }
};

/// Move-to-Front Transform
const MTF = struct {
    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try allocator.alloc(u8, input.len);
        var alphabet: [256]u8 = undefined;
        for (0..256) |i| alphabet[i] = @intCast(i);

        for (input, 0..) |char, i| {
            // Find position
            var pos: u8 = 0;
            for (alphabet, 0..) |a, j| {
                if (a == char) {
                    pos = @intCast(j);
                    break;
                }
            }
            output[i] = pos;

            // Move to front
            const c = alphabet[pos];
            var k: usize = pos;
            while (k > 0) : (k -= 1) alphabet[k] = alphabet[k - 1];
            alphabet[0] = c;
        }
        return output;
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try allocator.alloc(u8, input.len);
        var alphabet: [256]u8 = undefined;
        for (0..256) |i| alphabet[i] = @intCast(i);

        for (input, 0..) |pos, i| {
            const char = alphabet[pos];
            output[i] = char;

            // Move to front
            var k: usize = pos;
            while (k > 0) : (k -= 1) alphabet[k] = alphabet[k - 1];
            alphabet[0] = char;
        }
        return output;
    }
};

/// Burrows-Wheeler Transform
const BWT = struct {
    const SENTINEL: u8 = 0; // End marker (assumes input doesn't contain 0)

    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        const n = input.len + 1; // Include sentinel

        // Create input with sentinel
        var text = try allocator.alloc(u8, n);
        defer allocator.free(text);
        @memcpy(text[0..input.len], input);
        text[input.len] = SENTINEL;

        // Create rotation indices
        var indices = try allocator.alloc(usize, n);
        defer allocator.free(indices);
        for (0..n) |i| indices[i] = i;

        // Sort rotations lexicographically
        const SortCtx = struct {
            text: []const u8,
            n: usize,

            pub fn lessThan(ctx: @This(), a: usize, b: usize) bool {
                for (0..ctx.n) |i| {
                    const ca = ctx.text[(a + i) % ctx.n];
                    const cb = ctx.text[(b + i) % ctx.n];
                    if (ca != cb) return ca < cb;
                }
                return false;
            }
        };
        std.mem.sort(usize, indices, SortCtx{ .text = text, .n = n }, SortCtx.lessThan);

        // Output: last column of sorted rotations + position of original
        var output = try allocator.alloc(u8, n + 4); // +4 for storing original position
        var orig_pos: u32 = 0;

        for (indices, 0..) |idx, i| {
            output[i] = text[(idx + n - 1) % n]; // Last char of this rotation
            if (idx == 0) orig_pos = @intCast(i);
        }

        // Store original position at end (little-endian)
        output[n] = @truncate(orig_pos);
        output[n + 1] = @truncate(orig_pos >> 8);
        output[n + 2] = @truncate(orig_pos >> 16);
        output[n + 3] = @truncate(orig_pos >> 24);

        return output;
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len < 5) return try allocator.alloc(u8, 0);

        const n = input.len - 4;
        const bwt = input[0..n];

        // Extract original position
        const orig_pos = @as(u32, input[n]) |
            (@as(u32, input[n + 1]) << 8) |
            (@as(u32, input[n + 2]) << 16) |
            (@as(u32, input[n + 3]) << 24);

        // Count occurrences of each character
        var counts: [256]usize = [_]usize{0} ** 256;
        for (bwt) |c| counts[c] += 1;

        // Cumulative counts (first occurrence of each char in sorted first column)
        var first: [256]usize = undefined;
        var sum: usize = 0;
        for (0..256) |i| {
            first[i] = sum;
            sum += counts[i];
        }

        // Build transformation vector
        var transform = try allocator.alloc(usize, n);
        defer allocator.free(transform);

        var occ: [256]usize = [_]usize{0} ** 256;
        for (bwt, 0..) |c, i| {
            transform[i] = first[c] + occ[c];
            occ[c] += 1;
        }

        // Reconstruct original (minus sentinel)
        var output = try allocator.alloc(u8, n - 1);
        var idx: usize = orig_pos;

        // Walk backwards through transform
        var out_idx: usize = n - 1;
        while (out_idx > 0) {
            out_idx -= 1;
            idx = transform[idx];
            if (bwt[idx] != SENTINEL) {
                output[out_idx] = bwt[idx];
            }
        }

        return output;
    }
};

/// Zero Run-Length Encoding (optimized for post-MTF data with many zeros)
const ZeroRLE = struct {
    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try std.ArrayListUnmanaged(u8).initCapacity(allocator, input.len);
        errdefer output.deinit(allocator);

        var i: usize = 0;
        while (i < input.len) {
            if (input[i] == 0) {
                // Count zeros
                var count: usize = 0;
                while (i + count < input.len and input[i + count] == 0 and count < 255) {
                    count += 1;
                }
                try output.append(allocator, 0); // Zero marker
                try output.append(allocator, @intCast(count)); // Count
                i += count;
            } else {
                try output.append(allocator, input[i]);
                i += 1;
            }
        }

        return output.toOwnedSlice(allocator);
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try std.ArrayListUnmanaged(u8).initCapacity(allocator, input.len);
        errdefer output.deinit(allocator);

        var i: usize = 0;
        while (i < input.len) {
            if (input[i] == 0 and i + 1 < input.len) {
                const count = input[i + 1];
                try output.appendNTimes(allocator, 0, count);
                i += 2;
            } else {
                try output.append(allocator, input[i]);
                i += 1;
            }
        }

        return output.toOwnedSlice(allocator);
    }
};

/// LZ77 - Sliding Window Dictionary Compression
const LZ77 = struct {
    const WINDOW_SIZE: usize = 4096;
    const MIN_MATCH: usize = 3;
    const MAX_MATCH: usize = 258;

    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try std.ArrayListUnmanaged(u8).initCapacity(allocator, input.len);
        errdefer output.deinit(allocator);

        var pos: usize = 0;
        while (pos < input.len) {
            var best_offset: u16 = 0;
            var best_length: u8 = 0;

            // Search for match in window
            const window_start = if (pos > WINDOW_SIZE) pos - WINDOW_SIZE else 0;

            var search_pos = window_start;
            while (search_pos < pos) : (search_pos += 1) {
                var length: usize = 0;
                while (pos + length < input.len and
                    length < MAX_MATCH and
                    input[search_pos + length] == input[pos + length])
                {
                    length += 1;
                }

                if (length >= MIN_MATCH and length > best_length) {
                    best_offset = @intCast(pos - search_pos);
                    best_length = @intCast(length);
                }
            }

            if (best_length >= MIN_MATCH) {
                // Emit back-reference: [0xFF][offset_hi][offset_lo][length]
                try output.append(allocator, 0xFF); // Escape byte
                try output.append(allocator, @truncate(best_offset >> 8));
                try output.append(allocator, @truncate(best_offset));
                try output.append(allocator, best_length);
                pos += best_length;
            } else {
                // Emit literal
                if (input[pos] == 0xFF) {
                    try output.append(allocator, 0xFF);
                    try output.append(allocator, 0); // Zero offset = literal 0xFF
                    try output.append(allocator, 0);
                    try output.append(allocator, 1);
                } else {
                    try output.append(allocator, input[pos]);
                }
                pos += 1;
            }
        }

        return output.toOwnedSlice(allocator);
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        var output = try std.ArrayListUnmanaged(u8).initCapacity(allocator, input.len * 2);
        errdefer output.deinit(allocator);

        var i: usize = 0;
        while (i < input.len) {
            if (input[i] == 0xFF and i + 3 < input.len) {
                const offset = (@as(u16, input[i + 1]) << 8) | input[i + 2];
                const length = input[i + 3];

                if (offset == 0) {
                    // Escaped literal 0xFF
                    try output.appendNTimes(allocator, 0xFF, length);
                } else {
                    // Back-reference
                    const start = output.items.len - offset;
                    for (0..length) |j| {
                        try output.append(allocator, output.items[start + j]);
                    }
                }
                i += 4;
            } else {
                try output.append(allocator, input[i]);
                i += 1;
            }
        }

        return output.toOwnedSlice(allocator);
    }
};

/// Simple Huffman Coding (canonical form)
const Huffman = struct {
    const MAX_SYMBOLS = 256;
    const MAX_CODE_LEN = 15;

    pub fn encode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) return try allocator.alloc(u8, 0);

        // Count frequencies
        var freq: [MAX_SYMBOLS]u32 = [_]u32{0} ** MAX_SYMBOLS;
        for (input) |c| freq[c] += 1;

        // Build code lengths using package-merge or simple method
        var code_len: [MAX_SYMBOLS]u8 = [_]u8{0} ** MAX_SYMBOLS;
        var n_symbols: usize = 0;

        for (0..MAX_SYMBOLS) |i| {
            if (freq[i] > 0) {
                n_symbols += 1;
                // Simple heuristic: more frequent = shorter code
                const f = freq[i];
                if (f > input.len / 4) {
                    code_len[i] = 2;
                } else if (f > input.len / 16) {
                    code_len[i] = 4;
                } else if (f > input.len / 64) {
                    code_len[i] = 6;
                } else {
                    code_len[i] = 8;
                }
            }
        }

        // For simplicity, just store code lengths + packed data
        // Real implementation would use canonical Huffman codes
        var output = try std.ArrayListUnmanaged(u8).initCapacity(allocator, input.len + 256);
        errdefer output.deinit(allocator);

        // Header: 256 bytes of code lengths
        for (0..256) |i| {
            try output.append(allocator, code_len[i]);
        }

        // Store original length (4 bytes)
        try output.append(allocator, @truncate(input.len));
        try output.append(allocator, @truncate(input.len >> 8));
        try output.append(allocator, @truncate(input.len >> 16));
        try output.append(allocator, @truncate(input.len >> 24));

        // For now, just copy data (proper bit-packing would go here)
        // This is a stub - real Huffman would pack bits
        for (input) |c| {
            try output.append(allocator, c);
        }

        return output.toOwnedSlice(allocator);
    }

    pub fn decode(allocator: Allocator, input: []const u8) ![]u8 {
        if (input.len < 260) return try allocator.alloc(u8, 0);

        // Read original length
        const orig_len = @as(usize, input[256]) |
            (@as(usize, input[257]) << 8) |
            (@as(usize, input[258]) << 16) |
            (@as(usize, input[259]) << 24);

        // For stub: just copy back
        const output = try allocator.alloc(u8, orig_len);
        @memcpy(output, input[260..][0..orig_len]);

        return output;
    }
};

// ============================================================================
// Pipeline Execution
// ============================================================================

const CompressionStep = enum {
    rle,
    delta,
    mtf,
    bwt,
    zero_rle,
    lz77,
    huffman,
};

const CompressionResult = struct {
    compressed_data: []u8,
    original_size: usize,
    compressed_size: usize,
    ratio: f64,
    is_lossless: bool,
    encode_time_ns: i128,
    decode_time_ns: i128,
    throughput_mbps: f64,
};

/// Parse a formula string
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
        } else if (std.ascii.eqlIgnoreCase(trimmed, "BWT")) {
            steps[count] = .bwt;
        } else if (std.ascii.eqlIgnoreCase(trimmed, "ZERORLE") or std.ascii.eqlIgnoreCase(trimmed, "ZRLE")) {
            steps[count] = .zero_rle;
        } else if (std.ascii.eqlIgnoreCase(trimmed, "LZ77") or std.ascii.eqlIgnoreCase(trimmed, "LZ")) {
            steps[count] = .lz77;
        } else if (std.ascii.eqlIgnoreCase(trimmed, "HUFFMAN") or std.ascii.eqlIgnoreCase(trimmed, "HUF")) {
            steps[count] = .huffman;
        } else {
            return error.UnknownStep;
        }

        count += 1;
        if (count >= 16) break;
    }

    return count;
}

/// Execute a compression pipeline with proper memory management
fn executeCompression(
    allocator: Allocator,
    input: []const u8,
    steps: []const CompressionStep,
) !CompressionResult {
    const start_time = posix.clock_gettime(.MONOTONIC) catch return error.TimerFailed;

    // Apply each compression step
    var current: []u8 = try allocator.dupe(u8, input);
    var prev: ?[]u8 = null;

    for (steps) |step| {
        const next = switch (step) {
            .rle => try RLE.encode(allocator, current),
            .delta => try Delta.encode(allocator, current),
            .mtf => try MTF.encode(allocator, current),
            .bwt => try BWT.encode(allocator, current),
            .zero_rle => try ZeroRLE.encode(allocator, current),
            .lz77 => try LZ77.encode(allocator, current),
            .huffman => try Huffman.encode(allocator, current),
        };

        // Free previous intermediate buffer
        if (prev) |p| allocator.free(p);
        prev = current;
        current = next;
    }

    // Free last intermediate
    if (prev) |p| allocator.free(p);

    const encode_end = posix.clock_gettime(.MONOTONIC) catch return error.TimerFailed;

    const compressed_size = current.len;

    // Verify lossless by decompressing
    var decompressed: []u8 = try allocator.dupe(u8, current);
    prev = null;

    // Apply decompression in reverse order
    var i: usize = steps.len;
    while (i > 0) {
        i -= 1;
        const next = switch (steps[i]) {
            .rle => try RLE.decode(allocator, decompressed),
            .delta => try Delta.decode(allocator, decompressed),
            .mtf => try MTF.decode(allocator, decompressed),
            .bwt => try BWT.decode(allocator, decompressed),
            .zero_rle => try ZeroRLE.decode(allocator, decompressed),
            .lz77 => try LZ77.decode(allocator, decompressed),
            .huffman => try Huffman.decode(allocator, decompressed),
        };

        if (prev) |p| allocator.free(p);
        prev = decompressed;
        decompressed = next;
    }

    if (prev) |p| allocator.free(p);

    const decode_end = posix.clock_gettime(.MONOTONIC) catch return error.TimerFailed;

    // Verify lossless
    const is_lossless = decompressed.len == input.len and std.mem.eql(u8, input, decompressed);

    allocator.free(decompressed);

    // Calculate timing
    const encode_ns = (@as(i128, encode_end.sec) - @as(i128, start_time.sec)) * 1_000_000_000 +
        (@as(i128, encode_end.nsec) - @as(i128, start_time.nsec));
    const decode_ns = (@as(i128, decode_end.sec) - @as(i128, encode_end.sec)) * 1_000_000_000 +
        (@as(i128, decode_end.nsec) - @as(i128, encode_end.nsec));

    const total_ns = encode_ns + decode_ns;
    const throughput = if (total_ns > 0)
        @as(f64, @floatFromInt(input.len)) / @as(f64, @floatFromInt(total_ns)) * 1000.0
    else
        0.0;

    return CompressionResult{
        .compressed_data = current,
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
        std.debug.print("Usage: compression-bench --formulas <file> --input <data_file> [--output <dir>] [--top N]\n\n", .{});
        std.debug.print("Supported algorithms:\n", .{});
        std.debug.print("  RLE      - Run-Length Encoding\n", .{});
        std.debug.print("  DELTA    - Delta Encoding\n", .{});
        std.debug.print("  MTF      - Move-to-Front Transform\n", .{});
        std.debug.print("  BWT      - Burrows-Wheeler Transform\n", .{});
        std.debug.print("  ZERORLE  - Zero Run-Length (post-MTF)\n", .{});
        std.debug.print("  LZ77     - Dictionary Compression\n", .{});
        std.debug.print("  HUFFMAN  - Huffman Coding (stub)\n", .{});
        std.debug.print("\nExample formulas:\n", .{});
        std.debug.print("  RLE\n", .{});
        std.debug.print("  BWT+MTF+ZERORLE\n", .{});
        std.debug.print("  LZ77+HUFFMAN\n", .{});
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
    var results = std.ArrayListUnmanaged(FormulaResult){};
    defer results.deinit(allocator);

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

        const result = executeCompression(allocator, input_data, steps[0..step_count]) catch continue;
        defer allocator.free(result.compressed_data);

        successful += 1;
        if (result.is_lossless) {
            lossless_count += 1;
            if (result.ratio < best_ratio) {
                best_ratio = result.ratio;
            }
        }

        const formula_copy = try allocator.dupe(u8, formula);
        try results.append(allocator, .{
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

    // Sort by compression ratio
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

    // Save results
    std.fs.cwd().makeDir(output_dir) catch {};

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

    for (results.items) |r| {
        allocator.free(r.formula);
    }
}
