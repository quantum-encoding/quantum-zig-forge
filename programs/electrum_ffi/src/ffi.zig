const std = @import("std");
const net = std.net;
const electrum = @import("electrum.zig");

// =============================================================================
// ELECTRUM FFI - C-Compatible Electrum Client Interface
// =============================================================================

// =============================================================================
// Error Codes
// =============================================================================

pub const ElectrumResult = enum(c_int) {
    success = 0,
    connection_failed = -1,
    tls_failed = -2,
    send_failed = -3,
    receive_failed = -4,
    timeout = -5,
    invalid_response = -6,
    server_error = -7,
    buffer_too_small = -8,
    invalid_scripthash = -9,
    not_connected = -10,
    parse_error = -11,
    null_pointer = -12,
};

// =============================================================================
// Thread-Local Error Storage
// =============================================================================

threadlocal var last_error_msg: [512]u8 = undefined;
threadlocal var last_error_len: usize = 0;

fn setLastError(msg: []const u8) void {
    const copy_len = @min(msg.len, last_error_msg.len - 1);
    @memcpy(last_error_msg[0..copy_len], msg[0..copy_len]);
    last_error_msg[copy_len] = 0;
    last_error_len = copy_len;
}

/// Get the last error message for this thread
export fn electrum_get_error(buf: [*c]u8, buf_size: usize) usize {
    if (buf_size == 0) return last_error_len;
    const copy_len = @min(last_error_len, buf_size - 1);
    @memcpy(buf[0..copy_len], last_error_msg[0..copy_len]);
    buf[copy_len] = 0;
    return copy_len;
}

// =============================================================================
// C-Compatible Structures
// =============================================================================

/// UTXO structure for FFI
pub const CUtxo = extern struct {
    txid: [32]u8,
    vout: u32,
    value: u64,
    height: u32,
};

/// Balance response
pub const CBalance = extern struct {
    confirmed: u64,
    unconfirmed: i64,
};

/// Connection handle (opaque)
pub const ConnectionHandle = u64;

// =============================================================================
// Connection Management (Stateless API)
// =============================================================================

// For simplicity and thread safety, we use a stateless API where each call
// creates a new connection. For production, you'd want persistent connections.

/// Perform a blocking Electrum request (opens connection, sends, receives, closes)
fn performElectrumRequest(
    host: []const u8,
    port: u16,
    request: []const u8,
    response_buf: []u8,
) !usize {
    // Connect with TCP
    const address = net.Address.resolveIp(host, port) catch |err| {
        setLastError("Failed to resolve host");
        return err;
    };

    var stream = net.Stream.connect(address) catch |err| {
        setLastError("Connection failed");
        return err;
    };
    defer stream.close();

    // Send request
    stream.writeAll(request) catch |err| {
        setLastError("Failed to send request");
        return err;
    };

    // Read response (until newline)
    var total_read: usize = 0;
    while (total_read < response_buf.len) {
        const bytes_read = stream.read(response_buf[total_read..]) catch |err| {
            setLastError("Failed to read response");
            return err;
        };

        if (bytes_read == 0) break; // EOF

        total_read += bytes_read;

        // Check for newline (end of JSON-RPC response)
        if (std.mem.lastIndexOfScalar(u8, response_buf[0..total_read], '\n')) |_| {
            break;
        }
    }

    return total_read;
}

// =============================================================================
// Core FFI Functions
// =============================================================================

/// Get balance for a scripthash (hex string)
///
/// Parameters:
/// - host: Server hostname (null-terminated)
/// - port: Server port (usually 50002 for SSL, 50001 for TCP)
/// - scripthash_hex: 64-character hex scripthash
/// - out_balance: Output balance structure
///
/// Returns: 0 on success, negative error code on failure
export fn electrum_get_balance(
    host: [*c]const u8,
    host_len: usize,
    port: u16,
    scripthash_hex: [*c]const u8,
    out_balance: *CBalance,
) c_int {
    if (@intFromPtr(host) == 0 or @intFromPtr(scripthash_hex) == 0 or @intFromPtr(out_balance) == 0) {
        return @intFromEnum(ElectrumResult.null_pointer);
    }

    const allocator = std.heap.page_allocator;

    // Build request
    const request = electrum.buildRequest(
        allocator,
        "blockchain.scripthash.get_balance",
        .{scripthash_hex[0..64]},
        1,
    ) catch {
        setLastError("Failed to build request");
        return @intFromEnum(ElectrumResult.parse_error);
    };
    defer allocator.free(request);

    // Perform request
    var response_buf: [4096]u8 = undefined;
    const response_len = performElectrumRequest(
        host[0..host_len],
        port,
        request,
        &response_buf,
    ) catch {
        return @intFromEnum(ElectrumResult.connection_failed);
    };

    // Parse response
    const balance = electrum.parseBalanceResponse(response_buf[0..response_len]) catch {
        setLastError("Failed to parse balance response");
        return @intFromEnum(ElectrumResult.parse_error);
    };

    out_balance.confirmed = balance.confirmed;
    out_balance.unconfirmed = balance.unconfirmed;

    return @intFromEnum(ElectrumResult.success);
}

/// Get UTXOs (unspent transaction outputs) for a scripthash
///
/// Parameters:
/// - host: Server hostname
/// - host_len: Length of hostname
/// - port: Server port
/// - scripthash_hex: 64-character hex scripthash
/// - out_utxos: Output array of UTXOs
/// - max_utxos: Maximum number of UTXOs to return
/// - out_count: Actual number of UTXOs returned
///
/// Returns: 0 on success, negative error code on failure
export fn electrum_list_unspent(
    host: [*c]const u8,
    host_len: usize,
    port: u16,
    scripthash_hex: [*c]const u8,
    out_utxos: [*c]CUtxo,
    max_utxos: usize,
    out_count: *usize,
) c_int {
    if (@intFromPtr(host) == 0 or @intFromPtr(scripthash_hex) == 0 or
        @intFromPtr(out_utxos) == 0 or @intFromPtr(out_count) == 0)
    {
        return @intFromEnum(ElectrumResult.null_pointer);
    }

    const allocator = std.heap.page_allocator;

    // Build request
    const request = electrum.buildRequest(
        allocator,
        "blockchain.scripthash.listunspent",
        .{scripthash_hex[0..64]},
        1,
    ) catch {
        setLastError("Failed to build request");
        return @intFromEnum(ElectrumResult.parse_error);
    };
    defer allocator.free(request);

    // Perform request
    var response_buf: [65536]u8 = undefined; // 64KB for UTXO list
    const response_len = performElectrumRequest(
        host[0..host_len],
        port,
        request,
        &response_buf,
    ) catch {
        return @intFromEnum(ElectrumResult.connection_failed);
    };

    // Parse response
    const utxos = electrum.parseUtxoResponse(allocator, response_buf[0..response_len]) catch {
        setLastError("Failed to parse UTXO response");
        return @intFromEnum(ElectrumResult.parse_error);
    };
    defer allocator.free(utxos);

    // Copy to output
    const copy_count = @min(utxos.len, max_utxos);
    for (utxos[0..copy_count], 0..) |utxo, i| {
        out_utxos[i] = CUtxo{
            .txid = utxo.txid,
            .vout = utxo.vout,
            .value = utxo.value,
            .height = utxo.height,
        };
    }
    out_count.* = copy_count;

    return @intFromEnum(ElectrumResult.success);
}

/// Broadcast a raw transaction
///
/// Parameters:
/// - host: Server hostname
/// - host_len: Length of hostname
/// - port: Server port
/// - raw_tx_hex: Hex-encoded raw transaction
/// - raw_tx_hex_len: Length of hex string
/// - out_txid: Output buffer for txid (64 bytes for hex)
///
/// Returns: 0 on success, negative error code on failure
export fn electrum_broadcast_tx(
    host: [*c]const u8,
    host_len: usize,
    port: u16,
    raw_tx_hex: [*c]const u8,
    raw_tx_hex_len: usize,
    out_txid: [*c]u8,
) c_int {
    if (@intFromPtr(host) == 0 or @intFromPtr(raw_tx_hex) == 0 or @intFromPtr(out_txid) == 0) {
        return @intFromEnum(ElectrumResult.null_pointer);
    }

    const allocator = std.heap.page_allocator;

    // Build request
    const request = electrum.buildRequest(
        allocator,
        "blockchain.transaction.broadcast",
        .{raw_tx_hex[0..raw_tx_hex_len]},
        1,
    ) catch {
        setLastError("Failed to build request");
        return @intFromEnum(ElectrumResult.parse_error);
    };
    defer allocator.free(request);

    // Perform request
    var response_buf: [4096]u8 = undefined;
    const response_len = performElectrumRequest(
        host[0..host_len],
        port,
        request,
        &response_buf,
    ) catch {
        return @intFromEnum(ElectrumResult.connection_failed);
    };

    // Parse response - extract txid from result
    const response = response_buf[0..response_len];

    // Look for "result":"<txid>"
    if (std.mem.indexOf(u8, response, "\"result\":\"")) |pos| {
        const txid_start = pos + 10;
        if (txid_start + 64 <= response.len) {
            @memcpy(out_txid[0..64], response[txid_start .. txid_start + 64]);
            return @intFromEnum(ElectrumResult.success);
        }
    }

    // Check for error
    if (std.mem.indexOf(u8, response, "\"error\":")) |_| {
        setLastError("Server returned error");
        return @intFromEnum(ElectrumResult.server_error);
    }

    setLastError("Invalid response format");
    return @intFromEnum(ElectrumResult.invalid_response);
}

/// Get raw transaction by txid
///
/// Parameters:
/// - host: Server hostname
/// - host_len: Length of hostname
/// - port: Server port
/// - txid_hex: 64-character txid
/// - out_raw_tx: Output buffer for hex-encoded raw tx
/// - out_raw_tx_size: Size of output buffer
/// - out_len: Actual length of raw tx hex
///
/// Returns: 0 on success, negative error code on failure
export fn electrum_get_transaction(
    host: [*c]const u8,
    host_len: usize,
    port: u16,
    txid_hex: [*c]const u8,
    out_raw_tx: [*c]u8,
    out_raw_tx_size: usize,
    out_len: *usize,
) c_int {
    if (@intFromPtr(host) == 0 or @intFromPtr(txid_hex) == 0 or
        @intFromPtr(out_raw_tx) == 0 or @intFromPtr(out_len) == 0)
    {
        return @intFromEnum(ElectrumResult.null_pointer);
    }

    const allocator = std.heap.page_allocator;

    // Build request
    const request = electrum.buildRequest(
        allocator,
        "blockchain.transaction.get",
        .{txid_hex[0..64]},
        1,
    ) catch {
        setLastError("Failed to build request");
        return @intFromEnum(ElectrumResult.parse_error);
    };
    defer allocator.free(request);

    // Perform request
    var response_buf: [262144]u8 = undefined; // 256KB for raw tx
    const response_len = performElectrumRequest(
        host[0..host_len],
        port,
        request,
        &response_buf,
    ) catch {
        return @intFromEnum(ElectrumResult.connection_failed);
    };

    const response = response_buf[0..response_len];

    // Look for "result":"<raw_tx_hex>"
    if (std.mem.indexOf(u8, response, "\"result\":\"")) |pos| {
        const tx_start = pos + 10;
        // Find closing quote
        if (std.mem.indexOfScalarPos(u8, response, tx_start, '"')) |tx_end| {
            const tx_len = tx_end - tx_start;
            if (tx_len > out_raw_tx_size) {
                setLastError("Buffer too small for transaction");
                return @intFromEnum(ElectrumResult.buffer_too_small);
            }
            @memcpy(out_raw_tx[0..tx_len], response[tx_start..tx_end]);
            out_len.* = tx_len;
            return @intFromEnum(ElectrumResult.success);
        }
    }

    // Check for error
    if (std.mem.indexOf(u8, response, "\"error\":")) |_| {
        setLastError("Server returned error");
        return @intFromEnum(ElectrumResult.server_error);
    }

    setLastError("Invalid response format");
    return @intFromEnum(ElectrumResult.invalid_response);
}

/// Get current block height (tip)
export fn electrum_get_tip(
    host: [*c]const u8,
    host_len: usize,
    port: u16,
    out_height: *u32,
    out_block_hash: [*c]u8, // 64 bytes for hex
) c_int {
    if (@intFromPtr(host) == 0 or @intFromPtr(out_height) == 0 or @intFromPtr(out_block_hash) == 0) {
        return @intFromEnum(ElectrumResult.null_pointer);
    }

    const allocator = std.heap.page_allocator;

    // Build request
    const request = electrum.buildRequest(
        allocator,
        "blockchain.headers.subscribe",
        {},
        1,
    ) catch {
        setLastError("Failed to build request");
        return @intFromEnum(ElectrumResult.parse_error);
    };
    defer allocator.free(request);

    // Perform request
    var response_buf: [4096]u8 = undefined;
    const response_len = performElectrumRequest(
        host[0..host_len],
        port,
        request,
        &response_buf,
    ) catch {
        return @intFromEnum(ElectrumResult.connection_failed);
    };

    const response = response_buf[0..response_len];

    // Parse height from response
    if (std.mem.indexOf(u8, response, "\"height\":")) |pos| {
        const start = pos + 9;
        var end = start;
        while (end < response.len and response[end] >= '0' and response[end] <= '9') : (end += 1) {}
        out_height.* = std.fmt.parseInt(u32, response[start..end], 10) catch 0;
    }

    // Parse hex header (80 bytes = 160 hex chars)
    if (std.mem.indexOf(u8, response, "\"hex\":\"")) |pos| {
        const start = pos + 7;
        // Block hash is double SHA256 of header, reversed
        // For now, just copy first 64 chars as placeholder
        if (start + 64 <= response.len) {
            @memcpy(out_block_hash[0..64], response[start .. start + 64]);
        }
    }

    return @intFromEnum(ElectrumResult.success);
}

// =============================================================================
// Scripthash Helper Functions
// =============================================================================

/// Compute scripthash for P2WPKH from pubkey hash
export fn electrum_scripthash_p2wpkh(
    pubkey_hash: [*c]const u8,
    out_scripthash: [*c]u8, // 64 bytes for hex output
) c_int {
    if (@intFromPtr(pubkey_hash) == 0 or @intFromPtr(out_scripthash) == 0) {
        return @intFromEnum(ElectrumResult.null_pointer);
    }

    var pk_hash: [20]u8 = undefined;
    @memcpy(&pk_hash, pubkey_hash[0..20]);

    const scripthash = electrum.computeP2wpkhScripthash(&pk_hash);
    const hex = electrum.scripthashToHex(&scripthash);
    @memcpy(out_scripthash[0..64], &hex);

    return @intFromEnum(ElectrumResult.success);
}

/// Compute scripthash for P2PKH from pubkey hash
export fn electrum_scripthash_p2pkh(
    pubkey_hash: [*c]const u8,
    out_scripthash: [*c]u8, // 64 bytes for hex output
) c_int {
    if (@intFromPtr(pubkey_hash) == 0 or @intFromPtr(out_scripthash) == 0) {
        return @intFromEnum(ElectrumResult.null_pointer);
    }

    var pk_hash: [20]u8 = undefined;
    @memcpy(&pk_hash, pubkey_hash[0..20]);

    const scripthash = electrum.computeP2pkhScripthash(&pk_hash);
    const hex = electrum.scripthashToHex(&scripthash);
    @memcpy(out_scripthash[0..64], &hex);

    return @intFromEnum(ElectrumResult.success);
}

/// Get size of CUtxo struct
export fn electrum_utxo_size() usize {
    return @sizeOf(CUtxo);
}

/// Get size of CBalance struct
export fn electrum_balance_size() usize {
    return @sizeOf(CBalance);
}
