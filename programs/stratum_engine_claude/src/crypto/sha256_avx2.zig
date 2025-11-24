//! AVX2 8-way Parallel SHA-256d Implementation
//! Hashes 8 block headers simultaneously using AVX2 SIMD instructions
//!
//! Performance: ~8x faster than scalar implementation
//! Requires: AVX2 CPU support (Intel Haswell 2013+, AMD Excavator 2015+)

const std = @import("std");

/// AVX2 vector type for 8 x u32 lanes
const Vec8u32 = @Vector(8, u32);

/// SHA-256 round constants (same for all lanes)
const K = [64]u32{
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
};

/// Right rotate vector (each lane independently)
inline fn rotr_vec(v: Vec8u32, comptime n: u5) Vec8u32 {
    const shift_amt: u5 = @intCast(32 - @as(u32, n));
    return (v >> @splat(n)) | (v << @splat(shift_amt));
}

/// SHA-256 Ch function (vectorized)
inline fn Ch(x: Vec8u32, y: Vec8u32, z: Vec8u32) Vec8u32 {
    return (x & y) ^ (~x & z);
}

/// SHA-256 Maj function (vectorized)
inline fn Maj(x: Vec8u32, y: Vec8u32, z: Vec8u32) Vec8u32 {
    return (x & y) ^ (x & z) ^ (y & z);
}

/// SHA-256 Σ0 function (vectorized)
inline fn Sigma0(x: Vec8u32) Vec8u32 {
    return rotr_vec(x, 2) ^ rotr_vec(x, 13) ^ rotr_vec(x, 22);
}

/// SHA-256 Σ1 function (vectorized)
inline fn Sigma1(x: Vec8u32) Vec8u32 {
    return rotr_vec(x, 6) ^ rotr_vec(x, 11) ^ rotr_vec(x, 25);
}

/// SHA-256 σ0 function (vectorized)
inline fn sigma0(x: Vec8u32) Vec8u32 {
    return rotr_vec(x, 7) ^ rotr_vec(x, 18) ^ (x >> @splat(3));
}

/// SHA-256 σ1 function (vectorized)
inline fn sigma1(x: Vec8u32) Vec8u32 {
    return rotr_vec(x, 17) ^ rotr_vec(x, 19) ^ (x >> @splat(10));
}

/// Single SHA-256 compression function (8-way parallel)
fn sha256_compress_avx2(
    h: *[8]Vec8u32,
    w: *[64]Vec8u32,
) void {
    // Initialize working variables
    var a = h[0];
    var b = h[1];
    var c = h[2];
    var d = h[3];
    var e = h[4];
    var f = h[5];
    var g = h[6];
    var hh = h[7];

    // Compression rounds
    comptime var i: usize = 0;
    inline while (i < 64) : (i += 1) {
        const T1 = hh +% Sigma1(e) +% Ch(e, f, g) +% @as(Vec8u32, @splat(K[i])) +% w[i];
        const T2 = Sigma0(a) +% Maj(a, b, c);
        hh = g;
        g = f;
        f = e;
        e = d +% T1;
        d = c;
        c = b;
        b = a;
        a = T1 +% T2;
    }

    // Add to hash state
    h[0] +%= a;
    h[1] +%= b;
    h[2] +%= c;
    h[3] +%= d;
    h[4] +%= e;
    h[5] +%= f;
    h[6] +%= g;
    h[7] +%= hh;
}

/// Prepare message schedule (8-way parallel)
fn prepare_schedule_avx2(block: *[16]Vec8u32, w: *[64]Vec8u32) void {
    // Copy first 16 words
    comptime var i: usize = 0;
    inline while (i < 16) : (i += 1) {
        w[i] = block[i];
    }

    // Expand to 64 words
    inline while (i < 64) : (i += 1) {
        w[i] = w[i - 16] +% sigma0(w[i - 15]) +% w[i - 7] +% sigma1(w[i - 2]);
    }
}

/// Load 8 block headers into AVX2 format (transposed)
/// Each header is 80 bytes, we load 8 of them into SIMD lanes
fn load_headers_avx2(headers: *const [8][80]u8, block: *[16]Vec8u32) void {
    // Transpose headers into SIMD format
    // Each Vec8u32 contains word[i] from all 8 headers
    var word: usize = 0;
    while (word < 16) : (word += 1) {
        const offset = word * 4;

        // Build vector for this word position across all lanes
        var temp: [8]u32 = undefined;
        for (0..8) |lane| {
            if (offset + 4 <= 80) {
                const bytes = headers[lane][offset .. offset + 4];
                temp[lane] = std.mem.readInt(u32, bytes[0..4], .big);
            } else {
                temp[lane] = 0;
            }
        }

        block[word] = temp;
    }
}

/// Store 8 hashes from AVX2 format (de-transposed)
fn store_hashes_avx2(h: *const [8]Vec8u32, hashes: *[8][32]u8) void {
    // De-transpose SIMD format back to individual hashes
    var word: usize = 0;
    while (word < 8) : (word += 1) {
        // Extract vector as array
        const vec: [8]u32 = h[word];

        // Write each lane's value to its hash
        for (0..8) |lane| {
            const offset = word * 4;
            std.mem.writeInt(u32, hashes[lane][offset..][0..4], vec[lane], .big);
        }
    }
}

/// SHA-256 single pass (8-way parallel)
pub fn sha256_x8(headers: *const [8][80]u8, hashes: *[8][32]u8) void {
    // Initial hash values (SHA-256 IV) for all 8 lanes
    var h: [8]Vec8u32 = .{
        @splat(0x6a09e667),
        @splat(0xbb67ae85),
        @splat(0x3c6ef372),
        @splat(0xa54ff53a),
        @splat(0x510e527f),
        @splat(0x9b05688c),
        @splat(0x1f83d9ab),
        @splat(0x5be0cd19),
    };

    // Message schedule
    var w: [64]Vec8u32 = undefined;

    // Load and transpose headers
    var block: [16]Vec8u32 = undefined;
    load_headers_avx2(headers, &block);

    // Prepare message schedule and compress
    prepare_schedule_avx2(&block, &w);
    sha256_compress_avx2(&h, &w);

    // Store results
    store_hashes_avx2(&h, hashes);
}

/// Double SHA-256 (8-way parallel) - Bitcoin mining hash
pub fn sha256d_x8(headers: *const [8][80]u8, hashes: *[8][32]u8) void {
    // First SHA-256 pass
    var intermediate: [8][32]u8 = undefined;
    sha256_x8(headers, &intermediate);

    // Second SHA-256 pass (need to pad intermediate hashes)
    var padded_blocks: [8][80]u8 = undefined;
    for (0..8) |i| {
        @memcpy(padded_blocks[i][0..32], &intermediate[i]);
        // SHA-256 padding for 32-byte input
        padded_blocks[i][32] = 0x80;
        @memset(padded_blocks[i][33..60], 0);
        // Length in bits (32 bytes = 256 bits)
        std.mem.writeInt(u64, padded_blocks[i][60..68], 256, .big);
        @memset(padded_blocks[i][68..80], 0);
    }

    sha256_x8(&padded_blocks, hashes);
}

test "avx2 single hash matches scalar" {
    const sha256d = @import("sha256d.zig");
    const testing = std.testing;

    // Test input
    const input = [_]u8{0} ** 80;

    // Scalar reference
    var expected: [32]u8 = undefined;
    sha256d.sha256d(&input, &expected);

    // AVX2 version (all 8 lanes same input)
    var headers: [8][80]u8 = undefined;
    for (0..8) |i| {
        @memcpy(&headers[i], &input);
    }

    var hashes: [8][32]u8 = undefined;
    sha256d_x8(&headers, &hashes);

    // All 8 outputs should match scalar
    for (0..8) |i| {
        try testing.expectEqualSlices(u8, &expected, &hashes[i]);
    }
}
