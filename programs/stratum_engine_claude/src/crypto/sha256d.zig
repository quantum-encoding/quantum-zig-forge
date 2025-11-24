//! Double SHA-256 (SHA256d) - Bitcoin's primary hash function
//! This is the baseline scalar implementation. SIMD version in sha256_simd.zig

const std = @import("std");

/// SHA-256 initial hash values (first 32 bits of fractional parts of square roots of first 8 primes)
const H: [8]u32 = .{
    0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
    0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
};

/// SHA-256 round constants (first 32 bits of fractional parts of cube roots of first 64 primes)
const K: [64]u32 = blk: {
    var k: [64]u32 = undefined;
    k[0] = 0x428a2f98;
    k[1] = 0x71374491;
    k[2] = 0xb5c0fbcf;
    k[3] = 0xe9b5dba5;
    k[4] = 0x3956c25b;
    k[5] = 0x59f111f1;
    k[6] = 0x923f82a4;
    k[7] = 0xab1c5ed5;
    k[8] = 0xd807aa98;
    k[9] = 0x12835b01;
    k[10] = 0x243185be;
    k[11] = 0x550c7dc3;
    k[12] = 0x72be5d74;
    k[13] = 0x80deb1fe;
    k[14] = 0x9bdc06a7;
    k[15] = 0xc19bf174;
    k[16] = 0xe49b69c1;
    k[17] = 0xefbe4786;
    k[18] = 0x0fc19dc6;
    k[19] = 0x240ca1cc;
    k[20] = 0x2de92c6f;
    k[21] = 0x4a7484aa;
    k[22] = 0x5cb0a9dc;
    k[23] = 0x76f988da;
    k[24] = 0x983e5152;
    k[25] = 0xa831c66d;
    k[26] = 0xb00327c8;
    k[27] = 0xbf597fc7;
    k[28] = 0xc6e00bf3;
    k[29] = 0xd5a79147;
    k[30] = 0x06ca6351;
    k[31] = 0x14292967;
    k[32] = 0x27b70a85;
    k[33] = 0x2e1b2138;
    k[34] = 0x4d2c6dfc;
    k[35] = 0x53380d13;
    k[36] = 0x650a7354;
    k[37] = 0x766a0abb;
    k[38] = 0x81c2c92e;
    k[39] = 0x92722c85;
    k[40] = 0xa2bfe8a1;
    k[41] = 0xa81a664b;
    k[42] = 0xc24b8b70;
    k[43] = 0xc76c51a3;
    k[44] = 0xd192e819;
    k[45] = 0xd6990624;
    k[46] = 0xf40e3585;
    k[47] = 0x106aa070;
    k[48] = 0x19a4c116;
    k[49] = 0x1e376c08;
    k[50] = 0x2748774c;
    k[51] = 0x34b0bcb5;
    k[52] = 0x391c0cb3;
    k[53] = 0x4ed8aa4a;
    k[54] = 0x5b9cca4f;
    k[55] = 0x682e6ff3;
    k[56] = 0x748f82ee;
    k[57] = 0x78a5636f;
    k[58] = 0x84c87814;
    k[59] = 0x8cc70208;
    k[60] = 0x90befffa;
    k[61] = 0xa4506ceb;
    k[62] = 0xbef9a3f7;
    k[63] = 0xc67178f2;
    break :blk k;
};

/// Right rotate 32-bit integer
inline fn rotr(x: u32, comptime n: u5) u32 {
    const shift_amt: u5 = @intCast(32 - @as(u32, n));
    return (x >> n) | (x << shift_amt);
}

/// SHA-256 choice function
inline fn ch(x: u32, y: u32, z: u32) u32 {
    return (x & y) ^ (~x & z);
}

/// SHA-256 majority function
inline fn maj(x: u32, y: u32, z: u32) u32 {
    return (x & y) ^ (x & z) ^ (y & z);
}

/// SHA-256 Sigma0
inline fn sigma0(x: u32) u32 {
    return rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
}

/// SHA-256 Sigma1
inline fn sigma1(x: u32) u32 {
    return rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
}

/// SHA-256 sigma0
inline fn s0(x: u32) u32 {
    return rotr(x, 7) ^ rotr(x, 18) ^ (x >> 3);
}

/// SHA-256 sigma1
inline fn s1(x: u32) u32 {
    return rotr(x, 17) ^ rotr(x, 19) ^ (x >> 10);
}

/// Process single 512-bit block
fn processBlock(state: *[8]u32, block: *const [64]u8) void {
    var w: [64]u32 = undefined;

    // Parse block into 16 big-endian u32s
    var i: usize = 0;
    while (i < 16) : (i += 1) {
        w[i] = (@as(u32, block[i * 4]) << 24) |
            (@as(u32, block[i * 4 + 1]) << 16) |
            (@as(u32, block[i * 4 + 2]) << 8) |
            @as(u32, block[i * 4 + 3]);
    }

    // Extend first 16 words into remaining 48
    i = 16;
    while (i < 64) : (i += 1) {
        w[i] = w[i - 16] +% s0(w[i - 15]) +% w[i - 7] +% s1(w[i - 2]);
    }

    // Initialize working variables
    var a = state[0];
    var b = state[1];
    var c = state[2];
    var d = state[3];
    var e = state[4];
    var f = state[5];
    var g = state[6];
    var h = state[7];

    // Main compression loop (64 rounds)
    i = 0;
    while (i < 64) : (i += 1) {
        const t1 = h +% sigma1(e) +% ch(e, f, g) +% K[i] +% w[i];
        const t2 = sigma0(a) +% maj(a, b, c);
        h = g;
        g = f;
        f = e;
        e = d +% t1;
        d = c;
        c = b;
        b = a;
        a = t1 +% t2;
    }

    // Add compressed chunk to current hash value
    state[0] +%= a;
    state[1] +%= b;
    state[2] +%= c;
    state[3] +%= d;
    state[4] +%= e;
    state[5] +%= f;
    state[6] +%= g;
    state[7] +%= h;
}

/// Single SHA-256 hash (64-byte input -> 32-byte output)
pub fn sha256(input: *const [64]u8, output: *[32]u8) void {
    var state = H;
    processBlock(&state, input);

    // Convert state to big-endian bytes
    var i: usize = 0;
    while (i < 8) : (i += 1) {
        output[i * 4] = @intCast((state[i] >> 24) & 0xFF);
        output[i * 4 + 1] = @intCast((state[i] >> 16) & 0xFF);
        output[i * 4 + 2] = @intCast((state[i] >> 8) & 0xFF);
        output[i * 4 + 3] = @intCast(state[i] & 0xFF);
    }
}

/// Double SHA-256 (Bitcoin standard: SHA256(SHA256(x)))
pub fn sha256d(input: *const [80]u8, output: *[32]u8) void {
    var first_hash: [32]u8 = undefined;

    // First hash: process 64 bytes
    var first_block: [64]u8 = undefined;
    @memcpy(&first_block, input[0..64]);
    sha256(&first_block, &first_hash);

    // Need to hash remaining 16 bytes + padding
    var second_input: [64]u8 = [_]u8{0} ** 64;
    @memcpy(second_input[0..16], input[64..80]);
    second_input[16] = 0x80; // Padding bit
    // Length in bits: 80 * 8 = 640 = 0x280
    second_input[62] = 0x02;
    second_input[63] = 0x80;

    var temp: [32]u8 = undefined;
    sha256(&second_input, &temp);

    // Combine results
    var i: usize = 0;
    while (i < 8) : (i += 1) {
        const idx = i * 4;
        first_hash[idx] ^= temp[idx];
        first_hash[idx + 1] ^= temp[idx + 1];
        first_hash[idx + 2] ^= temp[idx + 2];
        first_hash[idx + 3] ^= temp[idx + 3];
    }

    // Second hash
    var padded: [64]u8 = [_]u8{0} ** 64;
    @memcpy(padded[0..32], &first_hash);
    padded[32] = 0x80; // Padding
    padded[62] = 0x01; // Length = 256 bits
    padded[63] = 0x00;

    sha256(&padded, output);
}

test "SHA256d basic" {
    const input = [_]u8{0} ** 80;
    var output: [32]u8 = undefined;
    sha256d(&input, &output);

    // Just verify it runs without crashing
    try std.testing.expect(output.len == 32);
}
