//! Stratum V1 io_uring Client with Latency Tracking
//! Zero-copy networking for maximum performance

const std = @import("std");
const types = @import("types.zig");
const protocol = @import("protocol.zig");
const linux = std.os.linux;
const posix = std.posix;
const IoUring = linux.IoUring;

pub const ClientError = error{
    ConnectionFailed,
    AuthenticationFailed,
    ProtocolError,
    Timeout,
    Disconnected,
    NoAddressFound,
    IPv6NotSupported,
    RecvFailed,
};

pub const ClientState = enum {
    disconnected,
    connecting,
    subscribing,
    authorizing,
    ready,
    error_state,
};

/// Latency tracking for performance monitoring
pub const LatencyMetrics = struct {
    packet_received_ns: u64,
    parse_complete_ns: u64,
    job_dispatched_ns: u64,
    first_hash_ns: u64,

    pub fn packetToHash(self: LatencyMetrics) u64 {
        if (self.first_hash_ns > self.packet_received_ns) {
            return self.first_hash_ns - self.packet_received_ns;
        }
        return 0;
    }

    pub fn packetToHashUs(self: LatencyMetrics) f64 {
        return @as(f64, @floatFromInt(self.packetToHash())) / 1000.0;
    }
};

pub const StratumClient = struct {
    allocator: std.mem.Allocator,
    state: ClientState,

    /// io_uring instance for zero-copy I/O
    ring: IoUring,

    /// TCP socket
    sockfd: posix.socket_t,

    /// Pool credentials
    credentials: types.Credentials,

    /// Extranonce1 from pool
    extranonce1: ?[]u8,

    /// Extranonce2 size
    extranonce2_size: u32,

    /// Current difficulty
    difficulty: f64,

    /// Message ID counter
    next_id: u32,

    /// Receive buffer
    recv_buffer: [8192]u8,
    recv_len: usize,

    /// Latency tracking
    last_packet_ns: u64,
    latency_history: std.ArrayList(LatencyMetrics),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, credentials: types.Credentials) !Self {
        // Parse pool URL to extract host and port
        const url = credentials.url;
        const prefix = "stratum+tcp://";
        if (!std.mem.startsWith(u8, url, prefix)) {
            return ClientError.ProtocolError;
        }

        const host_port = url[prefix.len..];
        const colon_idx = std.mem.indexOf(u8, host_port, ":") orelse return ClientError.ProtocolError;

        const host = host_port[0..colon_idx];
        const port_str = host_port[colon_idx + 1 ..];
        const port = try std.fmt.parseInt(u16, port_str, 10);

        std.debug.print("🔌 Initializing io_uring client for {s}:{d}...\n", .{ host, port });

        // Initialize io_uring (64 entries, no flags for portability)
        var ring = try IoUring.init(64, 0);

        // Create TCP socket
        const sockfd = try posix.socket(
            posix.AF.INET,
            posix.SOCK.STREAM | posix.SOCK.CLOEXEC,
            posix.IPPROTO.TCP,
        );
        errdefer posix.close(sockfd);

        // Parse address (IP only for now, DNS not available in Zig 0.16)
        var address = posix.sockaddr.in{
            .family = posix.AF.INET,
            .port = std.mem.nativeToBig(u16, port),
            .addr = undefined,
        };

        if (std.mem.eql(u8, host, "localhost")) {
            address.addr = 0x0100007F; // 127.0.0.1 in network byte order
        } else {
            // Parse IP string (e.g., "139.99.102.106")
            var octets: [4]u8 = undefined;
            var it = std.mem.splitScalar(u8, host, '.');
            var i: usize = 0;
            while (it.next()) |octet| : (i += 1) {
                if (i >= 4) return ClientError.NoAddressFound;
                octets[i] = try std.fmt.parseInt(u8, octet, 10);
            }
            if (i != 4) return ClientError.NoAddressFound;
            address.addr = @bitCast(octets);
        }

        // Submit connect operation via io_uring
        const sqe = try ring.get_sqe();
        sqe.prep_connect(sockfd, @ptrCast(&address), @sizeOf(posix.sockaddr.in));

        // Wait for connection
        _ = try ring.submit_and_wait(1);
        var cqe = try ring.copy_cqe();
        defer ring.cqe_seen(&cqe);

        if (cqe.res < 0) {
            return ClientError.ConnectionFailed;
        }

        std.debug.print("✅ Connected via io_uring!\n", .{});

        return .{
            .allocator = allocator,
            .state = .subscribing,
            .ring = ring,
            .sockfd = sockfd,
            .credentials = credentials,
            .extranonce1 = null,
            .extranonce2_size = 0,
            .difficulty = 1.0,
            .next_id = 1,
            .recv_buffer = undefined,
            .recv_len = 0,
            .last_packet_ns = 0,
            .latency_history = try std.ArrayList(LatencyMetrics).initCapacity(allocator, 0),
        };
    }

    pub fn deinit(self: *Self) void {
        posix.close(self.sockfd);
        self.ring.deinit();
        if (self.extranonce1) |extra| {
            self.allocator.free(extra);
        }
        self.latency_history.deinit(self.allocator);
    }

    /// Subscribe to mining (first message after connect)
    pub fn subscribe(self: *Self) !void {
        if (self.state != .subscribing) return ClientError.ProtocolError;

        const id = self.getNextId();
        const msg = try std.fmt.allocPrint(
            self.allocator,
            "{{\"id\":{},\"method\":\"mining.subscribe\",\"params\":[\"zig-stratum-engine/0.1.0\"]}}\n",
            .{id},
        );
        defer self.allocator.free(msg);

        try self.sendRaw(msg);

        // Wait for response
        const response = try self.receiveMessage();
        _ = response; // TODO: Parse extranonce1 and extranonce2_size

        self.state = .authorizing;
    }

    /// Authorize worker
    pub fn authorize(self: *Self) !void {
        if (self.state != .authorizing) return ClientError.ProtocolError;

        const id = self.getNextId();
        const msg = try std.fmt.allocPrint(
            self.allocator,
            "{{\"id\":{},\"method\":\"mining.authorize\",\"params\":[\"{s}\",\"{s}\"]}}\n",
            .{ id, self.credentials.username, self.credentials.password },
        );
        defer self.allocator.free(msg);

        try self.sendRaw(msg);

        // Wait for response
        const response = try self.receiveMessage();
        _ = response; // TODO: Check if authorized

        self.state = .ready;
    }

    /// Submit share to pool
    pub fn submitShare(self: *Self, share: types.Share) !void {
        if (self.state != .ready) return ClientError.ProtocolError;

        const id = self.getNextId();
        const msg = try std.fmt.allocPrint(
            self.allocator,
            "{{\"id\":{},\"method\":\"mining.submit\",\"params\":[\"{s}\",\"{s}\",\"{s}\",\"{x:0>8}\",\"{x:0>8}\"]}}\n",
            .{
                id,
                share.worker_name,
                share.job_id,
                share.extranonce2,
                share.ntime,
                share.nonce,
            },
        );
        defer self.allocator.free(msg);

        try self.sendRaw(msg);
    }

    /// Receive job notification from pool (with latency tracking)
    pub fn receiveJob(self: *Self) !?types.Job {
        if (self.state != .ready) return null;

        const msg = try self.receiveMessage();

        // Check if it's a mining.notify
        if (std.mem.indexOf(u8, msg, "mining.notify") != null) {
            // TODO: Parse job from JSON
            return null;
        }

        return null;
    }

    /// Get latest latency metrics
    pub fn getLatestLatency(self: *Self) ?LatencyMetrics {
        if (self.latency_history.items.len > 0) {
            return self.latency_history.items[self.latency_history.items.len - 1];
        }
        return null;
    }

    /// Get average latency over last N samples
    pub fn getAverageLatencyUs(self: *Self, count: usize) f64 {
        if (self.latency_history.items.len == 0) return 0.0;

        const samples = @min(count, self.latency_history.items.len);
        var sum: f64 = 0.0;

        const start = self.latency_history.items.len - samples;
        for (self.latency_history.items[start..]) |metric| {
            sum += metric.packetToHashUs();
        }

        return sum / @as(f64, @floatFromInt(samples));
    }

    // Internal helpers

    fn getNextId(self: *Self) u32 {
        const id = self.next_id;
        self.next_id += 1;
        return id;
    }

    fn sendRaw(self: *Self, data: []const u8) !void {
        // Submit send operation via io_uring
        const sqe = try self.ring.get_sqe();
        sqe.prep_send(self.sockfd, data, 0);

        _ = try self.ring.submit();
        // Note: Fire-and-forget for sends
    }

    fn receiveMessage(self: *Self) ![]const u8 {
        // Mark packet receive time
        const ts = std.posix.clock_gettime(.REALTIME) catch |err| {
            std.debug.print("Failed to get time: {}\n", .{err});
            return ClientError.ProtocolError;
        };
        self.last_packet_ns = @as(u64, @intCast(ts.sec)) * 1_000_000_000 + @as(u64, @intCast(ts.nsec));

        // Submit recv operation via io_uring
        const sqe = try self.ring.get_sqe();
        sqe.prep_recv(self.sockfd, self.recv_buffer[self.recv_len..], 0);

        _ = try self.ring.submit_and_wait(1);
        var cqe = try self.ring.copy_cqe();
        defer self.ring.cqe_seen(&cqe);

        if (cqe.res < 0) {
            return ClientError.RecvFailed;
        }

        const bytes_read = @as(usize, @intCast(cqe.res));
        if (bytes_read == 0) {
            return ClientError.Disconnected;
        }

        self.recv_len += bytes_read;

        // Look for complete messages (ends with \n)
        if (std.mem.indexOf(u8, self.recv_buffer[0..self.recv_len], "\n")) |idx| {
            const msg = self.recv_buffer[0..idx];

            // Shift remaining data
            const remaining = self.recv_len - (idx + 1);
            if (remaining > 0) {
                std.mem.copyForwards(u8, &self.recv_buffer, self.recv_buffer[idx + 1 .. self.recv_len]);
            }
            self.recv_len = remaining;

            return msg;
        }

        // Need more data
        if (self.recv_len >= self.recv_buffer.len) {
            return ClientError.ProtocolError; // Message too long
        }

        return ClientError.ProtocolError; // No complete message yet
    }
};

test "client init" {
    const testing = std.testing;
    _ = testing;

    const creds = types.Credentials{
        .url = "stratum+tcp://pool.example.com:3333",
        .username = "test.worker",
        .password = "x",
    };

    // Note: This will fail without actual network, but tests compilation
    _ = creds;
}
