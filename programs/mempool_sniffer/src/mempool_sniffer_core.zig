const std = @import("std");
const linux = std.os.linux;
const posix = std.posix;
const IoUring = linux.IoUring;

// Re-export for internal use
const bitcoin = @import("bitcoin_protocol.zig");

// Bitcoin protocol constants
pub const MAGIC_MAINNET: u32 = 0xD9B4BEF9;
pub const MSG_TX: u32 = 1;
pub const WHALE_THRESHOLD: i64 = 100_000_000; // 1 BTC in satoshis
pub const PROTOCOL_VERSION: i32 = 70015;

// C FFI types
pub const MS_TxHash = extern struct {
    bytes: [32]u8,
};

pub const MS_Transaction = extern struct {
    hash: MS_TxHash,
    value_satoshis: i64,
    input_count: u32,
    output_count: u32,
    is_whale: u8,
};

pub const MS_Status = enum(c_int) {
    disconnected = 0,
    connecting = 1,
    connected = 2,
    handshake_complete = 3,
};

pub const MS_Error = enum(c_int) {
    success = 0,
    out_of_memory = 1,
    connection_failed = 2,
    invalid_handle = 3,
    already_running = 4,
    not_running = 5,
    io_error = 6,
};

pub const MS_TxCallback = ?*const fn (*const MS_Transaction, ?*anyopaque) callconv(.c) void;
pub const MS_StatusCallback = ?*const fn (MS_Status, [*c]const u8, ?*anyopaque) callconv(.c) void;

pub const Sniffer = struct {
    allocator: std.mem.Allocator,
    node_ip: []const u8,
    port: u16,

    // Callbacks
    tx_callback: MS_TxCallback,
    tx_user_data: ?*anyopaque,
    status_callback: MS_StatusCallback,
    status_user_data: ?*anyopaque,

    // Runtime state
    running: std.atomic.Value(bool),
    status: std.atomic.Value(MS_Status),
    thread: ?std.Thread,
    mutex: std.Thread.Mutex,

    pub fn init(allocator: std.mem.Allocator, node_ip: []const u8, port: u16) !*Sniffer {
        const sniffer = try allocator.create(Sniffer);
        errdefer allocator.destroy(sniffer);

        const ip_copy = try allocator.dupe(u8, node_ip);
        errdefer allocator.free(ip_copy);

        sniffer.* = Sniffer{
            .allocator = allocator,
            .node_ip = ip_copy,
            .port = port,
            .tx_callback = null,
            .tx_user_data = null,
            .status_callback = null,
            .status_user_data = null,
            .running = std.atomic.Value(bool).init(false),
            .status = std.atomic.Value(MS_Status).init(.disconnected),
            .thread = null,
            .mutex = std.Thread.Mutex{},
        };

        return sniffer;
    }

    pub fn deinit(self: *Sniffer) void {
        // Ensure stopped
        if (self.running.load(.acquire)) {
            self.stop();
        }

        self.allocator.free(self.node_ip);
        self.allocator.destroy(self);
    }

    pub fn start(self: *Sniffer) !void {
        self.mutex.lock();
        defer self.mutex.unlock();

        if (self.running.load(.acquire)) {
            return error.AlreadyRunning;
        }

        self.running.store(true, .release);
        self.thread = try std.Thread.spawn(.{}, snifferThread, .{self});
    }

    pub fn stop(self: *Sniffer) void {
        self.running.store(false, .release);

        self.mutex.lock();
        defer self.mutex.unlock();

        if (self.thread) |thread| {
            thread.join();
            self.thread = null;
        }

        self.status.store(.disconnected, .release);
    }

    fn notifyStatus(self: *Sniffer, status: MS_Status, message: []const u8) void {
        self.status.store(status, .release);

        if (self.status_callback) |callback| {
            var msg_buf: [256]u8 = undefined;
            const msg_z = std.fmt.bufPrintZ(&msg_buf, "{s}", .{message}) catch "Status change";
            callback(status, msg_z.ptr, self.status_user_data);
        }
    }

    fn notifyTransaction(self: *Sniffer, tx: *const MS_Transaction) void {
        if (self.tx_callback) |callback| {
            callback(tx, self.tx_user_data);
        }
    }

    fn snifferThread(self: *Sniffer) void {
        self.runSniffer() catch |err| {
            var buf: [128]u8 = undefined;
            const msg = std.fmt.bufPrint(&buf, "Error: {}", .{err}) catch "Unknown error";
            self.notifyStatus(.disconnected, msg);
        };
    }

    fn runSniffer(self: *Sniffer) !void {
        self.notifyStatus(.connecting, "Connecting to Bitcoin node...");

        // Parse IP address from string to [4]u8
        var ip_parts: [4]u8 = undefined;
        var iter = std.mem.splitScalar(u8, self.node_ip, '.');
        var idx: usize = 0;
        while (iter.next()) |part| : (idx += 1) {
            if (idx >= 4) return error.InvalidIPAddress;
            ip_parts[idx] = std.fmt.parseInt(u8, part, 10) catch return error.InvalidIPAddress;
        }
        if (idx != 4) return error.InvalidIPAddress;

        // Create socket
        const sockfd = try posix.socket(posix.AF.INET, posix.SOCK.STREAM, posix.IPPROTO.TCP);
        defer posix.close(sockfd);

        // Setup address
        var addr: posix.sockaddr.in = undefined;
        addr.family = posix.AF.INET;
        addr.port = std.mem.nativeToBig(u16, self.port);
        addr.addr = std.mem.nativeToBig(u32, (@as(u32, ip_parts[0]) << 24) | (@as(u32, ip_parts[1]) << 16) | (@as(u32, ip_parts[2]) << 8) | ip_parts[3]);

        // Connect to node
        try posix.connect(sockfd, @ptrCast(&addr), @sizeOf(@TypeOf(addr)));
        self.notifyStatus(.connected, "Connected to Bitcoin node");

        // Build and send version message
        const version_msg = try bitcoin.buildVersionMessage();
        _ = try posix.send(sockfd, &version_msg, 0);

        // Setup io_uring
        var ring = try IoUring.init(64, 0);
        defer ring.deinit();

        self.notifyStatus(.handshake_complete, "Handshake initiated");

        // Buffer for receiving data
        var buffer: [4096]u8 align(64) = undefined;

        while (self.running.load(.acquire)) {
            // Submit recv request
            const sqe = try ring.get_sqe();
            sqe.prep_recv(sockfd, &buffer, 0);
            sqe.user_data = 0;

            // Submit and wait
            _ = try ring.submit_and_wait(1);

            // Wait for completion
            var cqe = try ring.copy_cqe();
            defer ring.cqe_seen(&cqe);

            const bytes_read = @as(usize, @intCast(cqe.res));
            if (bytes_read <= 0) break;

            // Process received data
            var offset: usize = 0;
            while (offset + 24 <= bytes_read) {
                // Parse header
                const magic = std.mem.readInt(u32, buffer[offset..][0..4], .little);
                offset += 4;

                var command_buf: [12]u8 = undefined;
                @memcpy(&command_buf, buffer[offset..][0..12]);
                offset += 12;

                // Extract command string
                var command_str: []const u8 = &command_buf;
                if (std.mem.indexOfScalar(u8, &command_buf, 0)) |null_pos| {
                    command_str = command_buf[0..null_pos];
                }

                const length = std.mem.readInt(u32, buffer[offset..][0..4], .little);
                offset += 4;

                _ = std.mem.readInt(u32, buffer[offset..][0..4], .little); // checksum
                offset += 4;

                // Verify magic
                if (magic != MAGIC_MAINNET) continue;

                // Check if we have full payload
                if (offset + length > bytes_read) break;

                // Handle version - respond with verack
                if (std.mem.eql(u8, command_str, "version")) {
                    try bitcoin.sendVerack(sockfd);
                }

                // Handle verack
                if (std.mem.eql(u8, command_str, "verack")) {
                    self.notifyStatus(.handshake_complete, "Handshake complete - listening for transactions");
                }

                // Handle ping - respond with pong
                if (std.mem.eql(u8, command_str, "ping")) {
                    if (length >= 8) {
                        const nonce = std.mem.readInt(u64, buffer[offset..][0..8], .little);
                        try bitcoin.sendPong(sockfd, nonce);
                    }
                }

                // Handle tx - parse and invoke callback
                if (std.mem.eql(u8, command_str, "tx")) {
                    const tx = bitcoin.parseTransaction(buffer[offset..][0..length]) catch {
                        offset += length;
                        continue;
                    };

                    // Convert to C FFI type and invoke callback
                    const c_tx = MS_Transaction{
                        .hash = MS_TxHash{ .bytes = tx.hash },
                        .value_satoshis = tx.value_satoshis,
                        .input_count = tx.input_count,
                        .output_count = tx.output_count,
                        .is_whale = if (tx.value_satoshis >= WHALE_THRESHOLD) 1 else 0,
                    };
                    self.notifyTransaction(&c_tx);
                }

                // Handle inv - request full transaction via getdata
                if (std.mem.eql(u8, command_str, "inv")) {
                    var payload_offset: usize = 0;
                    const inv_count = std.mem.readInt(u32, buffer[offset + payload_offset..][0..4], .little);
                    payload_offset += 4;

                    var i: u32 = 0;
                    while (i < inv_count and payload_offset + 36 <= length) : (i += 1) {
                        const inv_type = std.mem.readInt(u32, buffer[offset + payload_offset..][0..4], .little);
                        payload_offset += 4;

                        if (inv_type == MSG_TX) {
                            var hash: [32]u8 = undefined;
                            @memcpy(&hash, buffer[offset + payload_offset..][0..32]);
                            try bitcoin.sendGetData(sockfd, MSG_TX, hash);
                        }

                        payload_offset += 32;
                    }
                }

                offset += length;
            }
        }
    }
};

// C FFI exports
export fn ms_sniffer_create(node_ip: [*c]const u8, port: u16) callconv(.c) ?*Sniffer {
    const ip_slice = std.mem.span(node_ip);
    return Sniffer.init(std.heap.c_allocator, ip_slice, port) catch null;
}

export fn ms_sniffer_destroy(sniffer: ?*Sniffer) callconv(.c) void {
    if (sniffer) |s| {
        s.deinit();
    }
}

export fn ms_sniffer_set_tx_callback(
    sniffer: ?*Sniffer,
    callback: MS_TxCallback,
    user_data: ?*anyopaque,
) callconv(.c) MS_Error {
    const s = sniffer orelse return .invalid_handle;
    s.tx_callback = callback;
    s.tx_user_data = user_data;
    return .success;
}

export fn ms_sniffer_set_status_callback(
    sniffer: ?*Sniffer,
    callback: MS_StatusCallback,
    user_data: ?*anyopaque,
) callconv(.c) MS_Error {
    const s = sniffer orelse return .invalid_handle;
    s.status_callback = callback;
    s.status_user_data = user_data;
    return .success;
}

export fn ms_sniffer_start(sniffer: ?*Sniffer) callconv(.c) MS_Error {
    const s = sniffer orelse return .invalid_handle;
    s.start() catch |err| {
        return switch (err) {
            error.AlreadyRunning => .already_running,
            error.OutOfMemory => .out_of_memory,
            else => .io_error,
        };
    };
    return .success;
}

export fn ms_sniffer_stop(sniffer: ?*Sniffer) callconv(.c) MS_Error {
    const s = sniffer orelse return .invalid_handle;
    s.stop();
    return .success;
}

export fn ms_sniffer_is_running(sniffer: ?*const Sniffer) callconv(.c) c_int {
    const s = sniffer orelse return 0;
    return if (s.running.load(.acquire)) 1 else 0;
}

export fn ms_sniffer_get_status(sniffer: ?*const Sniffer) callconv(.c) MS_Status {
    const s = sniffer orelse return .disconnected;
    return s.status.load(.acquire);
}

export fn ms_error_string(error_code: MS_Error) callconv(.c) [*c]const u8 {
    return switch (error_code) {
        .success => "Success",
        .out_of_memory => "Out of memory",
        .connection_failed => "Connection failed",
        .invalid_handle => "Invalid handle",
        .already_running => "Already running",
        .not_running => "Not running",
        .io_error => "I/O error",
    };
}

export fn ms_version() callconv(.c) [*c]const u8 {
    return "1.0.0-core";
}

export fn ms_performance_info() callconv(.c) [*c]const u8 {
    return "Bitcoin mempool sniffer | <1µs latency | io_uring | SIMD hash";
}
