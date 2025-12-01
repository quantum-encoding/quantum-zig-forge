const std = @import("std");
const crypto = std.crypto;
// =============================================================================
// Error Codes
// =============================================================================
pub const QuantumCryptoError = enum(c_int) {
    success = 0,
    invalid_input = -1,
    invalid_output = -2,
    invalid_key_size = -3,
    invalid_nonce_size = -4,
    buffer_too_small = -5,
    out_of_memory = -6,
};
// =============================================================================
// Thread-Local Error Storage
// =============================================================================
threadlocal var last_error_msg: [256]u8 = undefined;
threadlocal var last_error_len: usize = 0;
fn setLastError(msg: []const u8) void {
    const copy_len = @min(msg.len, last_error_msg.len - 1);
    @memcpy(last_error_msg[0..copy_len], msg[0..copy_len]);
    last_error_msg[copy_len] = 0;
    last_error_len = copy_len;
}
/// Get the last error message for this thread
///
/// Returns the length of the error message copied to the buffer.
/// If the buffer is too small, the message is truncated.
export fn quantum_get_error(buf: [*c]u8, buf_size: usize) usize {
    if (buf_size == 0) return last_error_len;
    const copy_len = @min(last_error_len, buf_size - 1);
    @memcpy(buf[0..copy_len], last_error_msg[0..copy_len]);
    buf[copy_len] = 0;
    return copy_len;
}
// =============================================================================
// SHA-256: Bitcoin Address Generation, ECDSA Signing
// =============================================================================
/// Compute SHA-256 hash
///
/// Parameters:
/// - input: Input data to hash (borrowed, caller owns)
/// - input_len: Length of input data in bytes
/// - output: Output buffer for 32-byte hash (must be pre-allocated by caller)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
///
/// Example:
/// ```c
/// uint8_t hash[32];
/// const char* data = "hello world";
/// int result = quantum_sha256((uint8_t*)data, strlen(data), hash);
/// ```
export fn quantum_sha256(
    input: [*c]const u8,
    input_len: usize,
    output: [*c]u8,
) c_int {
    if (input_len > 0 and @intFromPtr(input) == 0) {
        setLastError("SHA-256: input pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0) {
        setLastError("SHA-256: output pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const input_slice = if (input_len > 0) input[0..input_len] else &[_]u8{};
    var out: [32]u8 = undefined;
    crypto.hash.sha2.Sha256.hash(input_slice, &out, .{});
    @memcpy(output[0..32], &out);
    return @intFromEnum(QuantumCryptoError.success);
}
/// Compute double SHA-256 (SHA256(SHA256(x)))
///
/// Used in Bitcoin for block hashing and transaction IDs.
///
/// Parameters:
/// - input: Input data to hash
/// - input_len: Length of input data in bytes
/// - output: Output buffer for 32-byte hash
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_sha256d(
    input: [*c]const u8,
    input_len: usize,
    output: [*c]u8,
) c_int {
    if (input_len > 0 and @intFromPtr(input) == 0) {
        setLastError("SHA-256d: input pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0) {
        setLastError("SHA-256d: output pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const input_slice = if (input_len > 0) input[0..input_len] else &[_]u8{};
    var first_hash: [32]u8 = undefined;
    var second_hash: [32]u8 = undefined;
    // First hash
    crypto.hash.sha2.Sha256.hash(input_slice, &first_hash, .{});
    // Second hash
    crypto.hash.sha2.Sha256.hash(&first_hash, &second_hash, .{});
    @memcpy(output[0..32], &second_hash);
    return @intFromEnum(QuantumCryptoError.success);
}
// =============================================================================
// SHA-512: BIP39 Seed Derivation (PBKDF2-HMAC-SHA512)
// =============================================================================
/// Compute SHA-512 hash
///
/// Used for BIP39 mnemonic-to-seed derivation with PBKDF2-HMAC-SHA512.
///
/// Parameters:
/// - input: Input data to hash
/// - input_len: Length of input data in bytes
/// - output: Output buffer for 64-byte hash (must be pre-allocated by caller)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_sha512(
    input: [*c]const u8,
    input_len: usize,
    output: [*c]u8,
) c_int {
    if (input_len > 0 and @intFromPtr(input) == 0) {
        setLastError("SHA-512: input pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0) {
        setLastError("SHA-512: output pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const input_slice = if (input_len > 0) input[0..input_len] else &[_]u8{};
    var out: [64]u8 = undefined;
    crypto.hash.sha2.Sha512.hash(input_slice, &out, .{});
    @memcpy(output[0..64], &out);
    return @intFromEnum(QuantumCryptoError.success);
}
/// Compute HMAC-SHA512
///
/// Used for BIP39 PBKDF2 key derivation.
///
/// Parameters:
/// - key: Secret key
/// - key_len: Length of key in bytes
/// - message: Message to authenticate
/// - message_len: Length of message in bytes
/// - output: Output buffer for 64-byte MAC (must be pre-allocated by caller)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_hmac_sha512(
    key: [*c]const u8,
    key_len: usize,
    message: [*c]const u8,
    message_len: usize,
    output: [*c]u8,
) c_int {
    if (key_len > 0 and @intFromPtr(key) == 0) {
        setLastError("HMAC-SHA512: key pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_key_size);
    }
    if (message_len > 0 and @intFromPtr(message) == 0) {
        setLastError("HMAC-SHA512: message pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0) {
        setLastError("HMAC-SHA512: output pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const key_slice = if (key_len > 0) key[0..key_len] else &[_]u8{};
    const message_slice = if (message_len > 0) message[0..message_len] else &[_]u8{};
    var out: [64]u8 = undefined;
    crypto.auth.hmac.sha2.HmacSha512.create(&out, message_slice, key_slice);
    @memcpy(output[0..64], &out);
    return @intFromEnum(QuantumCryptoError.success);
}
// =============================================================================
// BLAKE3: Modern, Fastest Hash Function
// =============================================================================
/// Compute BLAKE3 hash (32-byte output)
///
/// BLAKE3 is significantly faster than SHA-256 and provides better security margins.
/// Use for:
/// - Seed phrase hashing (PBKDF2 alternative)
/// - File integrity (wallet backups)
/// - General-purpose hashing
///
/// Parameters:
/// - input: Input data to hash
/// - input_len: Length of input data in bytes
/// - output: Output buffer for 32-byte hash
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_blake3(
    input: [*c]const u8,
    input_len: usize,
    output: [*c]u8,
) c_int {
    if (input_len > 0 and @intFromPtr(input) == 0) {
        setLastError("BLAKE3: input pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0) {
        setLastError("BLAKE3: output pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const input_slice = if (input_len > 0) input[0..input_len] else &[_]u8{};
    var out: [32]u8 = undefined;
    crypto.hash.Blake3.hash(input_slice, &out, .{});
    @memcpy(output[0..32], &out);
    return @intFromEnum(QuantumCryptoError.success);
}
/// Compute BLAKE3 hash with variable-length output
///
/// Parameters:
/// - input: Input data to hash
/// - input_len: Length of input data in bytes
/// - output: Output buffer (caller-allocated)
/// - output_len: Desired output length in bytes (must be > 0)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_blake3_variable(
    input: [*c]const u8,
    input_len: usize,
    output: [*c]u8,
    output_len: usize,
) c_int {
    if (input_len > 0 and @intFromPtr(input) == 0) {
        setLastError("BLAKE3: input pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0 or output_len == 0) {
        setLastError("BLAKE3: invalid output parameters");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const input_slice = if (input_len > 0) input[0..input_len] else &[_]u8{};
    const output_slice = output[0..output_len];
    var hasher = crypto.hash.Blake3.init(.{});
    hasher.update(input_slice);
    hasher.final(output_slice);
    return @intFromEnum(QuantumCryptoError.success);
}
// =============================================================================
// ChaCha20: Encrypted Wallet Storage
// =============================================================================
/// Encrypt data with ChaCha20 stream cipher
///
/// ChaCha20 is a modern, fast stream cipher used for:
/// - Encrypted wallet.dat files
/// - Secure communication channels
/// - Hardware wallet communication
///
/// WARNING: ChaCha20 requires a unique nonce for each message with the same key.
/// Nonce reuse completely breaks security. Use a counter or random nonce.
///
/// Parameters:
/// - key: 32-byte encryption key
/// - nonce: 12-byte nonce (must be unique for each message)
/// - counter: Initial counter value (usually 0)
/// - plaintext: Input plaintext data
/// - plaintext_len: Length of plaintext in bytes
/// - ciphertext: Output buffer for ciphertext (must be >= plaintext_len)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_chacha20_encrypt(
    key: [*c]const u8,
    nonce: [*c]const u8,
    counter: u32,
    plaintext: [*c]const u8,
    plaintext_len: usize,
    ciphertext: [*c]u8,
) c_int {
    if (@intFromPtr(key) == 0) {
        setLastError("ChaCha20: key pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_key_size);
    }
    if (@intFromPtr(nonce) == 0) {
        setLastError("ChaCha20: nonce pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_nonce_size);
    }
    if (plaintext_len > 0 and @intFromPtr(plaintext) == 0) {
        setLastError("ChaCha20: plaintext pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(ciphertext) == 0) {
        setLastError("ChaCha20: ciphertext pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const key_arr: [32]u8 = key[0..32].*;
    const nonce_arr: [12]u8 = nonce[0..12].*;
    const plaintext_slice = if (plaintext_len > 0) plaintext[0..plaintext_len] else &[_]u8{};
    const ciphertext_slice = ciphertext[0..plaintext_len];
    crypto.stream.chacha.ChaCha20IETF.xor(ciphertext_slice, plaintext_slice, counter, key_arr, nonce_arr);
    return @intFromEnum(QuantumCryptoError.success);
}
/// Decrypt data with ChaCha20 stream cipher
///
/// ChaCha20 is symmetric, so decryption is identical to encryption.
/// This is provided as a separate function for API clarity.
///
/// Parameters:
/// - key: 32-byte encryption key
/// - nonce: 12-byte nonce (must match encryption nonce)
/// - counter: Initial counter value (must match encryption counter)
/// - ciphertext: Input ciphertext data
/// - ciphertext_len: Length of ciphertext in bytes
/// - plaintext: Output buffer for plaintext (must be >= ciphertext_len)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_chacha20_decrypt(
    key: [*c]const u8,
    nonce: [*c]const u8,
    counter: u32,
    ciphertext: [*c]const u8,
    ciphertext_len: usize,
    plaintext: [*c]u8,
) c_int {
    // ChaCha20 is symmetric - encryption and decryption are identical
    return quantum_chacha20_encrypt(key, nonce, counter, ciphertext, ciphertext_len, plaintext);
}
// =============================================================================
// HMAC-SHA256: Message Authentication Codes
// =============================================================================
/// Compute HMAC-SHA256
///
/// Used for:
/// - BIP32 HD wallet key derivation
/// - PBKDF2 (password-based key derivation)
/// - API request signing
///
/// Parameters:
/// - key: Secret key
/// - key_len: Length of key in bytes
/// - message: Message to authenticate
/// - message_len: Length of message in bytes
/// - output: Output buffer for 32-byte MAC
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_hmac_sha256(
    key: [*c]const u8,
    key_len: usize,
    message: [*c]const u8,
    message_len: usize,
    output: [*c]u8,
) c_int {
    if (key_len > 0 and @intFromPtr(key) == 0) {
        setLastError("HMAC-SHA256: key pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_key_size);
    }
    if (message_len > 0 and @intFromPtr(message) == 0) {
        setLastError("HMAC-SHA256: message pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0) {
        setLastError("HMAC-SHA256: output pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    const key_slice = if (key_len > 0) key[0..key_len] else &[_]u8{};
    const message_slice = if (message_len > 0) message[0..message_len] else &[_]u8{};
    var out: [32]u8 = undefined;
    crypto.auth.hmac.sha2.HmacSha256.create(&out, message_slice, key_slice);
    @memcpy(output[0..32], &out);
    return @intFromEnum(QuantumCryptoError.success);
}
// =============================================================================
// PBKDF2-SHA256: Password-Based Key Derivation
// =============================================================================
/// Derive key from password using PBKDF2-SHA256
///
/// Used for:
/// - Converting seed phrases to master keys (BIP39)
/// - Encrypting wallet files with password
/// - Secure password storage
///
/// Parameters:
/// - password: User password
/// - password_len: Length of password in bytes
/// - salt: Salt value (typically user's email or random bytes)
/// - salt_len: Length of salt in bytes
/// - iterations: Number of iterations (recommend 100,000+ for security)
/// - output: Output buffer for derived key
/// - output_len: Desired key length in bytes
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
///
/// WARNING: This is CPU-intensive by design (to resist brute-force attacks).
/// With 100,000 iterations, expect ~100ms on modern hardware.
export fn quantum_pbkdf2_sha256(
    password: [*c]const u8,
    password_len: usize,
    salt: [*c]const u8,
    salt_len: usize,
    iterations: u32,
    output: [*c]u8,
    output_len: usize,
) c_int {
    if (password_len > 0 and @intFromPtr(password) == 0) {
        setLastError("PBKDF2: password pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (salt_len > 0 and @intFromPtr(salt) == 0) {
        setLastError("PBKDF2: salt pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0 or output_len == 0) {
        setLastError("PBKDF2: invalid output parameters");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    if (iterations == 0) {
        setLastError("PBKDF2: iterations must be > 0");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    const password_slice = if (password_len > 0) password[0..password_len] else &[_]u8{};
    const salt_slice = if (salt_len > 0) salt[0..salt_len] else &[_]u8{};
    const output_slice = output[0..output_len];
    crypto.pwhash.pbkdf2(output_slice, password_slice, salt_slice, iterations, crypto.auth.hmac.sha2.HmacSha256) catch {
        setLastError("PBKDF2: derivation failed");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    };
    return @intFromEnum(QuantumCryptoError.success);
}
/// Derive key from password using PBKDF2-HMAC-SHA512 (BIP39 standard)
///
/// BIP39 specification requires PBKDF2-HMAC-SHA512 with exactly 2048 iterations.
/// The salt is "mnemonic" + passphrase.
///
/// Used for:
/// - Converting BIP39 seed phrases to master keys
/// - Bitcoin/Ethereum wallet seed derivation
/// - Any application requiring BIP39 compliance
///
/// Parameters:
/// - password: User password (typically the mnemonic phrase)
/// - password_len: Length of password in bytes
/// - salt: Salt value (typically "mnemonic" + optional passphrase)
/// - salt_len: Length of salt in bytes
/// - iterations: Number of iterations (BIP39 standard: 2048)
/// - output: Output buffer for derived key
/// - output_len: Desired key length in bytes (BIP39 standard: 64 bytes)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
///
/// Performance:
/// - With 2048 iterations (BIP39 standard), expect ~10-20ms on modern hardware
/// - SHA512 is ~2x slower than SHA256 but provides better security margins
export fn quantum_pbkdf2_sha512(
    password: [*c]const u8,
    password_len: usize,
    salt: [*c]const u8,
    salt_len: usize,
    iterations: u32,
    output: [*c]u8,
    output_len: usize,
) c_int {
    if (password_len > 0 and @intFromPtr(password) == 0) {
        setLastError("PBKDF2-SHA512: password pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (salt_len > 0 and @intFromPtr(salt) == 0) {
        setLastError("PBKDF2-SHA512: salt pointer is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0 or output_len == 0) {
        setLastError("PBKDF2-SHA512: invalid output parameters");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }
    if (iterations == 0) {
        setLastError("PBKDF2-SHA512: iterations must be > 0");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    const password_slice = if (password_len > 0) password[0..password_len] else &[_]u8{};
    const salt_slice = if (salt_len > 0) salt[0..salt_len] else &[_]u8{};
    const output_slice = output[0..output_len];
    crypto.pwhash.pbkdf2(output_slice, password_slice, salt_slice, iterations, crypto.auth.hmac.sha2.HmacSha512) catch {
        setLastError("PBKDF2-SHA512: derivation failed");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    };
    return @intFromEnum(QuantumCryptoError.success);
}
// =============================================================================
// Secure Memory Operations
// =============================================================================
/// Securely zero memory (prevents compiler optimization)
///
/// Use to erase sensitive data (private keys, passwords) from memory.
/// Unlike memset, this is guaranteed not to be optimized away by the compiler.
///
/// Parameters:
/// - ptr: Pointer to memory to zero
/// - len: Number of bytes to zero
export fn quantum_secure_zero(ptr: [*c]u8, len: usize) void {
    if (len == 0 or @intFromPtr(ptr) == 0) return;
    // Use volatile to prevent compiler optimization
    const slice = ptr[0..len];
    for (slice) |*byte| {
        @as(*volatile u8, byte).* = 0;
    }
}
/// Constant-time memory comparison
///
/// Use to compare secrets (passwords, MACs) without leaking timing information.
/// Returns 0 if equal, non-zero if different.
///
/// Parameters:
/// - a: First buffer
/// - b: Second buffer
/// - len: Number of bytes to compare
///
/// Returns:
/// - 0 if buffers are equal
/// - 1 if buffers differ
export fn quantum_secure_compare(a: [*c]const u8, b: [*c]const u8, len: usize) c_int {
    if (len == 0) return 0;
    if (@intFromPtr(a) == 0 or @intFromPtr(b) == 0) return 1;

    // Manual constant-time comparison (timing_safe.eql requires fixed-size arrays)
    // This mirrors the stdlib implementation: XOR all bytes and check if result is zero
    var acc: u8 = 0;
    var i: usize = 0;
    while (i < len) : (i += 1) {
        acc |= a[i] ^ b[i];
    }

    // Convert to constant-time boolean check
    // If acc == 0, all bytes were equal
    const bits = @typeInfo(u8).int.bits;
    const Cext = std.meta.Int(.unsigned, bits + 1);
    const equal = @as(bool, @bitCast(@as(u1, @truncate((@as(Cext, acc) -% 1) >> bits))));

    return if (equal) 0 else 1;
}
// =============================================================================
// Version Information
// =============================================================================
/// Get library version string
///
/// Returns a null-terminated string like "quantum-crypto-1.0.0"
export fn quantum_version() [*:0]const u8 {
    return "quantum-crypto-1.0.0";
}
/// Get Zig stdlib version used for crypto implementations
export fn quantum_zig_version() [*:0]const u8 {
    return "zig-0.16.0-dev.1484";
}
// =============================================================================
// Tests
// =============================================================================
test "SHA-256 correctness" {
    const input = "hello world";
    var output: [32]u8 = undefined;
    const result = quantum_sha256(input.ptr, input.len, &output);
    try std.testing.expectEqual(@as(c_int, 0), result);
    // Known SHA-256 hash of "hello world"
    const expected_hex = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9";
    var expected: [32]u8 = undefined;
    _ = try std.fmt.hexToBytes(&expected, expected_hex);
    try std.testing.expectEqualSlices(u8, &expected, &output);
}
test "BLAKE3 correctness" {
    const input = "hello world";
    var output: [32]u8 = undefined;
    const result = quantum_blake3(input.ptr, input.len, &output);
    try std.testing.expectEqual(@as(c_int, 0), result);
    // Verify it's not all zeros
    var is_zero = true;
    for (output) |byte| {
        if (byte != 0) {
            is_zero = false;
            break;
        }
    }
    try std.testing.expect(!is_zero);
}
test "ChaCha20 encrypt/decrypt" {
    const key = [_]u8{1} ** 32;
    const nonce = [_]u8{2} ** 12;
    const plaintext = "Attack at dawn!";
    var ciphertext: [100]u8 = undefined;
    var decrypted: [100]u8 = undefined;
    // Encrypt
    const enc_result = quantum_chacha20_encrypt(
        &key,
        &nonce,
        0,
        plaintext.ptr,
        plaintext.len,
        &ciphertext,
    );
    try std.testing.expectEqual(@as(c_int, 0), enc_result);
    // Decrypt
    const dec_result = quantum_chacha20_decrypt(
        &key,
        &nonce,
        0,
        &ciphertext,
        plaintext.len,
        &decrypted,
    );
    try std.testing.expectEqual(@as(c_int, 0), dec_result);
    // Verify round-trip
    try std.testing.expectEqualSlices(u8, plaintext, decrypted[0..plaintext.len]);
}
test "secure memory operations" {
    var secret = [_]u8{ 1, 2, 3, 4, 5 };
    // Zero memory
    quantum_secure_zero(&secret, secret.len);
    try std.testing.expectEqualSlices(u8, &[_]u8{0} ** 5, &secret);
    // Constant-time compare
    const a = [_]u8{ 1, 2, 3 };
    const b = [_]u8{ 1, 2, 3 };
    const c = [_]u8{ 1, 2, 4 };
    try std.testing.expectEqual(@as(c_int, 0), quantum_secure_compare(&a, &b, 3));
    try std.testing.expectEqual(@as(c_int, 1), quantum_secure_compare(&a, &c, 3));
}
test "SHA-512 correctness" {
    const input = "hello world";
    var output: [64]u8 = undefined;
    const result = quantum_sha512(input.ptr, input.len, &output);
    try std.testing.expectEqual(@as(c_int, 0), result);
    // Known SHA-512 hash of "hello world"
    const expected_hex = "309ecc489c12d6eb4cc40f50c902f2b4d0ed77ee511a7c7a9bcd3ca86d4cd86f989dd35bc5ff499670da34255b45b0cfd830e81f605dcf7dc5542e93ae9cd76f";
    var expected: [64]u8 = undefined;
    _ = try std.fmt.hexToBytes(&expected, expected_hex);
    try std.testing.expectEqualSlices(u8, &expected, &output);
}
test "HMAC-SHA512 correctness" {
    const key = "secret";
    const message = "hello world";
    var output: [64]u8 = undefined;
    const result = quantum_hmac_sha512(key.ptr, key.len, message.ptr, message.len, &output);
    try std.testing.expectEqual(@as(c_int, 0), result);
    // Verify it's not all zeros
    var is_zero = true;
    for (output) |byte| {
        if (byte != 0) {
            is_zero = false;
            break;
        }
    }
    try std.testing.expect(!is_zero);
}
test "BIP39 PBKDF2-SHA512 Test Vector 1" {
    // BIP39 test vector (verified against Python hashlib)
    // Mnemonic: "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
    // Passphrase: "" (empty)
    // Expected seed from PBKDF2-HMAC-SHA512(mnemonic, "mnemonic" + passphrase, 2048)

    const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about";
    const salt = "mnemonic"; // BIP39 salt is "mnemonic" + optional passphrase
    const iterations = 2048; // BIP39 standard
    var output: [64]u8 = undefined;

    const result = quantum_pbkdf2_sha512(
        mnemonic.ptr,
        mnemonic.len,
        salt.ptr,
        salt.len,
        iterations,
        &output,
        64,
    );
    try std.testing.expectEqual(@as(c_int, 0), result);

    // Expected seed (verified with Python hashlib.pbkdf2_hmac)
    const expected_hex = "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4";
    var expected: [64]u8 = undefined;
    _ = try std.fmt.hexToBytes(&expected, expected_hex);

    try std.testing.expectEqualSlices(u8, &expected, &output);
}
test "BIP39 PBKDF2-SHA512 Test Vector 2" {
    // BIP39 test vector with passphrase
    // Mnemonic: "legal winner thank year wave sausage worth useful legal winner thank yellow"
    // Passphrase: "TREZOR"
    // Expected: 0x2e8905819b8723fe2c1d161860e5ee1830318dbf49a83bd451cfb8440c28bd6fa457fe1296106559a3c80937a1c1069be3a3a5bd381ee6260e8d9739fce1f607

    const mnemonic = "legal winner thank year wave sausage worth useful legal winner thank yellow";
    const salt = "mnemonicTREZOR"; // "mnemonic" + "TREZOR"
    const iterations = 2048;
    var output: [64]u8 = undefined;

    const result = quantum_pbkdf2_sha512(
        mnemonic.ptr,
        mnemonic.len,
        salt.ptr,
        salt.len,
        iterations,
        &output,
        64,
    );
    try std.testing.expectEqual(@as(c_int, 0), result);

    const expected_hex = "2e8905819b8723fe2c1d161860e5ee1830318dbf49a83bd451cfb8440c28bd6fa457fe1296106559a3c80937a1c1069be3a3a5bd381ee6260e8d9739fce1f607";
    var expected: [64]u8 = undefined;
    _ = try std.fmt.hexToBytes(&expected, expected_hex);

    try std.testing.expectEqualSlices(u8, &expected, &output);
}

// =============================================================================
// Batch SHA-256d: High-Performance Bitcoin Mining Hashing
// =============================================================================
// These functions provide batch processing for SHA-256d (double SHA-256),
// which is used extensively in Bitcoin mining for:
// - Block header hashing (finding valid nonces)
// - Transaction ID computation
// - Merkle tree construction
//
// The stdlib's SHA-256 implementation is already SIMD-optimized internally.
// This batch API provides a convenient interface for processing multiple
// hashes and reduces FFI overhead.
// =============================================================================

// Maximum batch size - chosen to balance memory usage and throughput
const MaxBatchSize: usize = 16;

/// Compute batch SHA-256d (double SHA-256)
///
/// Processes multiple inputs efficiently. Each input is hashed with SHA-256
/// twice (SHA256(SHA256(x))), which is the standard Bitcoin hashing scheme.
///
/// Parameters:
/// - inputs: Array of pointers to input data
/// - input_len: Length of each input in bytes (must be same for all)
/// - outputs: Array of pointers to 32-byte output buffers
/// - count: Number of inputs/outputs to process (max 16)
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
///
/// Use case: Bitcoin mining, transaction ID computation, merkle tree building
export fn quantum_sha256d_batch(
    inputs: [*c]const [*c]const u8,
    input_len: usize,
    outputs: [*c][*c]u8,
    count: usize,
) c_int {
    if (count == 0) {
        return @intFromEnum(QuantumCryptoError.success);
    }
    if (count > MaxBatchSize) {
        setLastError("SHA-256d batch: count exceeds maximum (16)");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(inputs) == 0 or @intFromPtr(outputs) == 0) {
        setLastError("SHA-256d batch: null pointer");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }

    // Process each input
    for (0..count) |i| {
        if (@intFromPtr(inputs[i]) == 0 or @intFromPtr(outputs[i]) == 0) {
            setLastError("SHA-256d batch: null pointer in array");
            return @intFromEnum(QuantumCryptoError.invalid_input);
        }

        const input_slice = inputs[i][0..input_len];
        const output_ptr = outputs[i];

        // First SHA-256
        var first_hash: [32]u8 = undefined;
        crypto.hash.sha2.Sha256.hash(input_slice, &first_hash, .{});

        // Second SHA-256
        var second_hash: [32]u8 = undefined;
        crypto.hash.sha2.Sha256.hash(&first_hash, &second_hash, .{});

        // Copy to output
        @memcpy(output_ptr[0..32], &second_hash);
    }

    return @intFromEnum(QuantumCryptoError.success);
}

/// Get the maximum batch size for batch operations
///
/// Returns the maximum number of hashes that can be processed in a single call.
export fn quantum_sha256d_batch_size() usize {
    return MaxBatchSize;
}

// =============================================================================
// Merkle Tree Construction: Bitcoin Block Merkle Root
// =============================================================================
// The Merkle root is a hash that summarizes all transactions in a Bitcoin block.
// It's computed by:
// 1. Hashing all transactions with SHA-256d
// 2. Pairing hashes and concatenating them
// 3. Hashing each pair with SHA-256d
// 4. Repeating until only one hash remains (the root)
//
// For mining, we compute the root from:
// - coinbase_hash: The SHA-256d of the coinbase transaction
// - merkle_branches: Pre-computed sibling hashes from the mining pool
// =============================================================================

/// Compute Bitcoin Merkle root from coinbase hash and branches
///
/// Used in Bitcoin mining to compute the Merkle root for block header construction.
/// The coinbase hash is combined with each branch hash in sequence using SHA-256d.
///
/// Parameters:
/// - coinbase_hash: 32-byte hash of the coinbase transaction
/// - branches: Array of 32-byte branch hashes (from mining pool)
/// - branch_count: Number of branches
/// - output: 32-byte output buffer for the Merkle root
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
///
/// Algorithm:
/// ```
/// current = coinbase_hash
/// for each branch in branches:
///     current = SHA-256d(current || branch)
/// return current
/// ```
export fn quantum_merkle_root(
    coinbase_hash: [*c]const u8,
    branches: [*c]const [*c]const u8,
    branch_count: usize,
    output: [*c]u8,
) c_int {
    if (@intFromPtr(coinbase_hash) == 0) {
        setLastError("Merkle root: coinbase_hash is null");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(output) == 0) {
        setLastError("Merkle root: output is null");
        return @intFromEnum(QuantumCryptoError.invalid_output);
    }

    // Start with coinbase hash
    var current: [32]u8 = undefined;
    @memcpy(&current, coinbase_hash[0..32]);

    // Process each branch
    for (0..branch_count) |i| {
        if (@intFromPtr(branches[i]) == 0) {
            setLastError("Merkle root: branch pointer is null");
            return @intFromEnum(QuantumCryptoError.invalid_input);
        }

        // Concatenate current and branch
        var concat: [64]u8 = undefined;
        @memcpy(concat[0..32], &current);
        @memcpy(concat[32..64], branches[i][0..32]);

        // Double SHA-256
        var first_hash: [32]u8 = undefined;
        crypto.hash.sha2.Sha256.hash(&concat, &first_hash, .{});
        crypto.hash.sha2.Sha256.hash(&first_hash, &current, .{});
    }

    @memcpy(output[0..32], &current);
    return @intFromEnum(QuantumCryptoError.success);
}

/// Build a complete Merkle tree from transaction hashes
///
/// Constructs a full Merkle tree from a list of transaction hashes.
/// If the number of leaves is odd, the last hash is duplicated.
///
/// Parameters:
/// - tx_hashes: Array of 32-byte transaction hashes
/// - tx_count: Number of transactions
/// - output: 32-byte output buffer for the Merkle root
///
/// Returns:
/// - 0 on success
/// - negative error code on failure
export fn quantum_merkle_root_from_txs(
    tx_hashes: [*c]const [*c]const u8,
    tx_count: usize,
    output: [*c]u8,
) c_int {
    if (tx_count == 0) {
        setLastError("Merkle root: no transactions");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }
    if (@intFromPtr(tx_hashes) == 0 or @intFromPtr(output) == 0) {
        setLastError("Merkle root: null pointer");
        return @intFromEnum(QuantumCryptoError.invalid_input);
    }

    // Single transaction case
    if (tx_count == 1) {
        if (@intFromPtr(tx_hashes[0]) == 0) {
            setLastError("Merkle root: null transaction hash");
            return @intFromEnum(QuantumCryptoError.invalid_input);
        }
        @memcpy(output[0..32], tx_hashes[0][0..32]);
        return @intFromEnum(QuantumCryptoError.success);
    }

    // Use stack buffer for small trees, heap for larger
    const max_stack_txs = 64;
    var stack_buffer: [max_stack_txs * 32]u8 = undefined;

    var current_level: []u8 = undefined;
    var next_level: []u8 = undefined;
    var heap_buffer: ?[]u8 = null;
    var heap_buffer2: ?[]u8 = null;

    // Determine buffer allocation strategy
    if (tx_count <= max_stack_txs) {
        current_level = stack_buffer[0 .. tx_count * 32];
    } else {
        heap_buffer = std.heap.page_allocator.alloc(u8, tx_count * 32) catch {
            setLastError("Merkle root: out of memory");
            return @intFromEnum(QuantumCryptoError.out_of_memory);
        };
        current_level = heap_buffer.?;
    }

    // Copy initial transaction hashes
    for (0..tx_count) |i| {
        if (@intFromPtr(tx_hashes[i]) == 0) {
            if (heap_buffer) |buf| std.heap.page_allocator.free(buf);
            setLastError("Merkle root: null transaction hash");
            return @intFromEnum(QuantumCryptoError.invalid_input);
        }
        @memcpy(current_level[i * 32 .. (i + 1) * 32], tx_hashes[i][0..32]);
    }

    var level_count = tx_count;

    // Build tree level by level
    while (level_count > 1) {
        // Calculate next level size (round up for odd counts)
        const next_count = (level_count + 1) / 2;
        const next_size = next_count * 32;

        // Allocate next level buffer
        if (next_count <= max_stack_txs and heap_buffer == null) {
            next_level = stack_buffer[0..next_size];
        } else {
            heap_buffer2 = std.heap.page_allocator.alloc(u8, next_size) catch {
                if (heap_buffer) |buf| std.heap.page_allocator.free(buf);
                setLastError("Merkle root: out of memory");
                return @intFromEnum(QuantumCryptoError.out_of_memory);
            };
            next_level = heap_buffer2.?;
        }

        // Process pairs
        var pair_idx: usize = 0;
        var out_idx: usize = 0;
        while (pair_idx < level_count) : ({
            pair_idx += 2;
            out_idx += 1;
        }) {
            var concat: [64]u8 = undefined;
            @memcpy(concat[0..32], current_level[pair_idx * 32 .. (pair_idx + 1) * 32]);

            // If odd, duplicate last hash
            if (pair_idx + 1 < level_count) {
                @memcpy(concat[32..64], current_level[(pair_idx + 1) * 32 .. (pair_idx + 2) * 32]);
            } else {
                @memcpy(concat[32..64], current_level[pair_idx * 32 .. (pair_idx + 1) * 32]);
            }

            // Double SHA-256
            var first_hash: [32]u8 = undefined;
            crypto.hash.sha2.Sha256.hash(&concat, &first_hash, .{});
            crypto.hash.sha2.Sha256.hash(&first_hash, next_level[out_idx * 32 ..][0..32], .{});
        }

        // Free old buffer if heap allocated
        if (heap_buffer) |buf| {
            std.heap.page_allocator.free(buf);
        }
        heap_buffer = heap_buffer2;
        heap_buffer2 = null;
        current_level = next_level;
        level_count = next_count;
    }

    // Copy result
    @memcpy(output[0..32], current_level[0..32]);

    // Cleanup
    if (heap_buffer) |buf| {
        std.heap.page_allocator.free(buf);
    }

    return @intFromEnum(QuantumCryptoError.success);
}

// =============================================================================
// Batch and Merkle Tests
// =============================================================================

test "SHA-256d batch single item" {
    const input = "hello world padded to be longer!"; // 32 bytes
    var inputs: [1][*c]const u8 = .{input.ptr};
    var output: [32]u8 = undefined;
    var outputs: [1][*c]u8 = .{&output};

    const result = quantum_sha256d_batch(&inputs, input.len, &outputs, 1);
    try std.testing.expectEqual(@as(c_int, 0), result);

    // Verify against standard double SHA-256
    var expected1: [32]u8 = undefined;
    var expected2: [32]u8 = undefined;
    crypto.hash.sha2.Sha256.hash(input, &expected1, .{});
    crypto.hash.sha2.Sha256.hash(&expected1, &expected2, .{});

    try std.testing.expectEqualSlices(u8, &expected2, &output);
}

test "SHA-256d batch multiple items" {
    const inputs_data = [_][]const u8{
        "input number one, padded nicely!",
        "input number two, padded nicely!",
        "input number three padded nicely",
        "input number four, padded nicely",
    };

    var input_ptrs: [4][*c]const u8 = undefined;
    for (0..4) |i| {
        input_ptrs[i] = inputs_data[i].ptr;
    }

    var outputs: [4][32]u8 = undefined;
    var output_ptrs: [4][*c]u8 = undefined;
    for (0..4) |i| {
        output_ptrs[i] = &outputs[i];
    }

    const result = quantum_sha256d_batch(&input_ptrs, 32, &output_ptrs, 4);
    try std.testing.expectEqual(@as(c_int, 0), result);

    // Verify each output matches sequential computation
    for (0..4) |i| {
        var expected1: [32]u8 = undefined;
        var expected2: [32]u8 = undefined;
        crypto.hash.sha2.Sha256.hash(inputs_data[i], &expected1, .{});
        crypto.hash.sha2.Sha256.hash(&expected1, &expected2, .{});
        try std.testing.expectEqualSlices(u8, &expected2, &outputs[i]);
    }
}

test "Merkle root with single branch" {
    var coinbase: [32]u8 = undefined;
    var branch: [32]u8 = undefined;
    var output: [32]u8 = undefined;

    // Fill with test data
    for (0..32) |i| {
        coinbase[i] = @intCast(i);
        branch[i] = @intCast(32 + i);
    }

    var branches: [1][*]const u8 = .{&branch};

    const result = quantum_merkle_root(&coinbase, &branches, 1, &output);
    try std.testing.expectEqual(@as(c_int, 0), result);

    // Verify manually
    var concat: [64]u8 = undefined;
    @memcpy(concat[0..32], &coinbase);
    @memcpy(concat[32..64], &branch);

    var expected1: [32]u8 = undefined;
    var expected2: [32]u8 = undefined;
    crypto.hash.sha2.Sha256.hash(&concat, &expected1, .{});
    crypto.hash.sha2.Sha256.hash(&expected1, &expected2, .{});

    try std.testing.expectEqualSlices(u8, &expected2, &output);
}

test "Merkle root from transactions" {
    // Create 4 transaction hashes
    var tx1: [32]u8 = [_]u8{1} ** 32;
    var tx2: [32]u8 = [_]u8{2} ** 32;
    var tx3: [32]u8 = [_]u8{3} ** 32;
    var tx4: [32]u8 = [_]u8{4} ** 32;

    var tx_ptrs: [4][*]const u8 = .{ &tx1, &tx2, &tx3, &tx4 };
    var output: [32]u8 = undefined;

    const result = quantum_merkle_root_from_txs(&tx_ptrs, 4, &output);
    try std.testing.expectEqual(@as(c_int, 0), result);

    // Output should not be all zeros
    var is_zero = true;
    for (output) |byte| {
        if (byte != 0) {
            is_zero = false;
            break;
        }
    }
    try std.testing.expect(!is_zero);
}

test "Merkle root single transaction" {
    var tx: [32]u8 = [_]u8{0xAB} ** 32;
    var tx_ptrs: [1][*]const u8 = .{&tx};
    var output: [32]u8 = undefined;

    const result = quantum_merkle_root_from_txs(&tx_ptrs, 1, &output);
    try std.testing.expectEqual(@as(c_int, 0), result);

    // Single transaction should return itself as root
    try std.testing.expectEqualSlices(u8, &tx, &output);
}

test "batch size returns correct value" {
    const size = quantum_sha256d_batch_size();
    try std.testing.expect(size == 8 or size == 16);
}
