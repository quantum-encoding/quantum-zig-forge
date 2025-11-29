//! ═══════════════════════════════════════════════════════════════════════════
//! DISCOVERY RESOLVER - STUN & mDNS for Peer Discovery
//! ═══════════════════════════════════════════════════════════════════════════
//!
//! Provides two discovery mechanisms:
//!
//! 1. STUN (Session Traversal Utilities for NAT)
//!    - Queries public STUN servers to discover external IP:port
//!    - Used for NAT hole punching between peers on different networks
//!
//! 2. mDNS (Multicast DNS)
//!    - Broadcasts presence on local network
//!    - Instant discovery for peers on same LAN
//!    - No external server required
//!
//! Protocol:
//!   1. Both peers start mDNS announcements with code hash
//!   2. If local peer found within timeout, use direct LAN connection
//!   3. Otherwise, query STUN for public endpoints
//!   4. Exchange endpoints through signaling (future: DHT or relay)

const std = @import("std");
const posix = std.posix;
const Transport = @import("../network/transport.zig").Transport;
const Endpoint = @import("../network/transport.zig").Endpoint;

// ═══════════════════════════════════════════════════════════════════════════
// STUN CLIENT
// ═══════════════════════════════════════════════════════════════════════════

/// Public STUN servers
pub const STUN_SERVERS = [_][]const u8{
    "stun.l.google.com:19302",
    "stun1.l.google.com:19302",
    "stun.cloudflare.com:3478",
    "stun.stunprotocol.org:3478",
};

/// STUN message types
pub const StunMessageType = enum(u16) {
    binding_request = 0x0001,
    binding_response = 0x0101,
    binding_error = 0x0111,
    _,
};

/// STUN attribute types
pub const StunAttribute = enum(u16) {
    mapped_address = 0x0001,
    xor_mapped_address = 0x0020,
    error_code = 0x0009,
    software = 0x8022,
    fingerprint = 0x8028,
    _,
};

/// STUN message header (20 bytes)
pub const StunHeader = struct {
    msg_type: StunMessageType,
    length: u16,
    magic_cookie: u32 = 0x2112A442,
    transaction_id: [12]u8,

    pub const SIZE = 20;
    pub const MAGIC_COOKIE: u32 = 0x2112A442;

    pub fn serialize(self: *const StunHeader) [SIZE]u8 {
        var buf: [SIZE]u8 = undefined;
        std.mem.writeInt(u16, buf[0..2], @intFromEnum(self.msg_type), .big);
        std.mem.writeInt(u16, buf[2..4], self.length, .big);
        std.mem.writeInt(u32, buf[4..8], self.magic_cookie, .big);
        @memcpy(buf[8..20], &self.transaction_id);
        return buf;
    }

    pub fn deserialize(buf: *const [SIZE]u8) !StunHeader {
        const magic = std.mem.readInt(u32, buf[4..8], .big);
        if (magic != MAGIC_COOKIE) {
            return error.InvalidMagicCookie;
        }

        return StunHeader{
            .msg_type = @enumFromInt(std.mem.readInt(u16, buf[0..2], .big)),
            .length = std.mem.readInt(u16, buf[2..4], .big),
            .magic_cookie = magic,
            .transaction_id = buf[8..20].*,
        };
    }
};

/// Parsed STUN response with mapped address
pub const StunResponse = struct {
    address: [4]u8, // IPv4 for now
    port: u16,
};

/// STUN client for discovering public IP
pub const StunClient = struct {
    const Self = @This();

    socket: posix.socket_t,
    transaction_id: [12]u8,

    pub fn init() !Self {
        const socket = try posix.socket(
            posix.AF.INET,
            posix.SOCK.DGRAM,
            0,
        );
        errdefer posix.close(socket);

        // Set receive timeout
        const timeout = posix.timeval{
            .sec = 3,
            .usec = 0,
        };
        try posix.setsockopt(
            socket,
            posix.SOL.SOCKET,
            posix.SO.RCVTIMEO,
            std.mem.asBytes(&timeout),
        );

        // Generate transaction ID
        var transaction_id: [12]u8 = undefined;
        std.crypto.random.bytes(&transaction_id);

        return Self{
            .socket = socket,
            .transaction_id = transaction_id,
        };
    }

    pub fn deinit(self: *Self) void {
        posix.close(self.socket);
    }

    /// Query STUN server for public endpoint
    pub fn query(self: *Self, server: []const u8) !StunResponse {
        // Parse server address (simplified - just extract IP or use hardcoded)
        var split = std.mem.splitScalar(u8, server, ':');
        const host = split.next() orelse return error.InvalidServer;
        const port_str = split.next() orelse "3478";
        const port = std.fmt.parseInt(u16, port_str, 10) catch 3478;

        // For now, use Google's STUN server IP directly
        // In production, would need DNS resolution
        _ = host; // Would resolve this
        const server_addr = posix.sockaddr.in{
            .family = posix.AF.INET,
            .port = std.mem.nativeToBig(u16, port),
            .addr = @bitCast([_]u8{ 74, 125, 250, 129 }), // stun.l.google.com
            .zero = [_]u8{0} ** 8,
        };

        // Build binding request
        const header = StunHeader{
            .msg_type = .binding_request,
            .length = 0,
            .transaction_id = self.transaction_id,
        };

        const request = header.serialize();

        // Send request
        _ = try posix.sendto(
            self.socket,
            &request,
            0,
            @ptrCast(&server_addr),
            @sizeOf(posix.sockaddr.in),
        );

        // Receive response
        var response_buf: [512]u8 = undefined;
        const recv_len = posix.recv(self.socket, &response_buf, 0) catch |err| switch (err) {
            error.WouldBlock => return error.Timeout,
            else => return err,
        };

        if (recv_len < StunHeader.SIZE) {
            return error.InvalidResponse;
        }

        // Parse response header
        const resp_header = try StunHeader.deserialize(response_buf[0..StunHeader.SIZE]);

        if (resp_header.msg_type != .binding_response) {
            return error.NotBindingResponse;
        }

        // Verify transaction ID
        if (!std.mem.eql(u8, &resp_header.transaction_id, &self.transaction_id)) {
            return error.TransactionIdMismatch;
        }

        // Parse attributes
        return self.parseAttributes(response_buf[StunHeader.SIZE..recv_len]);
    }

    fn parseAttributes(self: *Self, data: []const u8) !StunResponse {
        var offset: usize = 0;

        while (offset + 4 <= data.len) {
            const attr_type: StunAttribute = @enumFromInt(
                std.mem.readInt(u16, data[offset..][0..2], .big),
            );
            const attr_len = std.mem.readInt(u16, data[offset + 2 ..][0..2], .big);
            offset += 4;

            if (offset + attr_len > data.len) break;

            const attr_data = data[offset .. offset + attr_len];

            switch (attr_type) {
                .xor_mapped_address => {
                    return self.parseXorMappedAddress(attr_data);
                },
                .mapped_address => {
                    return parseMappedAddress(attr_data);
                },
                else => {},
            }

            // Pad to 4-byte boundary
            offset += attr_len;
            offset = (offset + 3) & ~@as(usize, 3);
        }

        return error.NoMappedAddress;
    }

    fn parseXorMappedAddress(self: *Self, data: []const u8) !StunResponse {
        if (data.len < 8) return error.InvalidAttribute;

        const family = data[1];
        if (family != 0x01) return error.UnsupportedFamily; // IPv4 only for now

        // XOR with magic cookie
        const xor_port = std.mem.readInt(u16, data[2..4], .big);
        const port = xor_port ^ @as(u16, @truncate(StunHeader.MAGIC_COOKIE >> 16));

        var address: [4]u8 = data[4..8].*;
        const magic_bytes: [4]u8 = @bitCast(std.mem.nativeToBig(u32, StunHeader.MAGIC_COOKIE));
        for (&address, magic_bytes) |*a, m| {
            a.* ^= m;
        }

        _ = self; // Transaction ID not needed for IPv4

        return StunResponse{
            .address = address,
            .port = port,
        };
    }

    fn parseMappedAddress(data: []const u8) !StunResponse {
        if (data.len < 8) return error.InvalidAttribute;

        const family = data[1];
        if (family != 0x01) return error.UnsupportedFamily;

        return StunResponse{
            .port = std.mem.readInt(u16, data[2..4], .big),
            .address = data[4..8].*,
        };
    }
};

// ═══════════════════════════════════════════════════════════════════════════
// mDNS DISCOVERY
// ═══════════════════════════════════════════════════════════════════════════

/// mDNS constants
pub const MDNS_MULTICAST_ADDR = [4]u8{ 224, 0, 0, 251 };
pub const MDNS_PORT: u16 = 5353;

/// mDNS service announcement
pub const MdnsAnnouncement = struct {
    service_name: []const u8, // e.g., "_warpgate._udp.local"
    code_hash: [16]u8, // Warp code hash for matching
    port: u16, // Local port for connection
    ttl: u32 = 120, // Time to live in seconds
};

/// mDNS discovery for local network peers
pub const MdnsDiscovery = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    socket: posix.socket_t,
    announcement: ?MdnsAnnouncement = null,
    discovered_peers: std.ArrayList(DiscoveredPeer),

    pub const DiscoveredPeer = struct {
        address: [4]u8,
        port: u16,
        code_hash: [16]u8,
        last_seen: i64,
    };

    pub fn init(allocator: std.mem.Allocator) !Self {
        const socket = try posix.socket(
            posix.AF.INET,
            posix.SOCK.DGRAM,
            0,
        );
        errdefer posix.close(socket);

        // Enable address reuse
        try posix.setsockopt(
            socket,
            posix.SOL.SOCKET,
            posix.SO.REUSEADDR,
            &std.mem.toBytes(@as(c_int, 1)),
        );

        // Join multicast group
        const mreq = extern struct {
            multiaddr: [4]u8,
            interface: [4]u8,
        }{
            .multiaddr = MDNS_MULTICAST_ADDR,
            .interface = [_]u8{ 0, 0, 0, 0 },
        };

        try posix.setsockopt(
            socket,
            posix.IPPROTO.IP,
            std.os.linux.IP.ADD_MEMBERSHIP,
            std.mem.asBytes(&mreq),
        );

        // Bind to mDNS port
        const bind_addr = posix.sockaddr.in{
            .family = posix.AF.INET,
            .port = std.mem.nativeToBig(u16, MDNS_PORT),
            .addr = @bitCast([_]u8{ 0, 0, 0, 0 }),
            .zero = [_]u8{0} ** 8,
        };
        try posix.bind(socket, @ptrCast(&bind_addr), @sizeOf(posix.sockaddr.in));

        // Set non-blocking using raw flag value
        const flags = try posix.fcntl(socket, posix.F.GETFL, 0);
        _ = try posix.fcntl(socket, posix.F.SETFL, flags | 0x800); // O_NONBLOCK = 0x800 on Linux

        return Self{
            .allocator = allocator,
            .socket = socket,
            .discovered_peers = .{},
        };
    }

    pub fn deinit(self: *Self) void {
        posix.close(self.socket);
        self.discovered_peers.deinit();
    }

    /// Start announcing our presence
    pub fn announce(self: *Self, code_hash: [16]u8, port: u16) !void {
        self.announcement = .{
            .service_name = "_warpgate._udp.local",
            .code_hash = code_hash,
            .port = port,
        };

        try self.sendAnnouncement();
    }

    fn sendAnnouncement(self: *Self) !void {
        const ann = self.announcement orelse return;

        // Simple announcement packet:
        // [16 bytes: code_hash][2 bytes: port]
        var packet: [18]u8 = undefined;
        @memcpy(packet[0..16], &ann.code_hash);
        std.mem.writeInt(u16, packet[16..18], ann.port, .big);

        const dest = posix.sockaddr.in{
            .family = posix.AF.INET,
            .port = std.mem.nativeToBig(u16, MDNS_PORT),
            .addr = @bitCast(MDNS_MULTICAST_ADDR),
            .zero = [_]u8{0} ** 8,
        };
        _ = posix.sendto(
            self.socket,
            &packet,
            0,
            @ptrCast(&dest),
            @sizeOf(posix.sockaddr.in),
        ) catch {};
    }

    /// Check for discovered peers matching our code
    pub fn poll(self: *Self, target_hash: [16]u8) !?DiscoveredPeer {
        var buf: [512]u8 = undefined;
        var src_addr: posix.sockaddr.storage = undefined;
        var src_len: posix.socklen_t = @sizeOf(posix.sockaddr.storage);

        while (true) {
            const len = posix.recvfrom(
                self.socket,
                &buf,
                0,
                @ptrCast(&src_addr),
                &src_len,
            ) catch |err| switch (err) {
                error.WouldBlock => break,
                else => return err,
            };

            if (len < 18) continue;

            const code_hash = buf[0..16].*;
            const port = std.mem.readInt(u16, buf[16..18], .big);

            // Check if this matches our target
            if (std.mem.eql(u8, &code_hash, &target_hash)) {
                // Extract source IP
                const in_addr: *const posix.sockaddr.in = @ptrCast(&src_addr);
                const address: [4]u8 = @bitCast(in_addr.addr);

                const peer = DiscoveredPeer{
                    .address = address,
                    .port = port,
                    .code_hash = code_hash,
                    .last_seen = std.time.timestamp(),
                };

                try self.discovered_peers.append(peer);
                return peer;
            }
        }

        // Re-announce periodically
        if (self.announcement != null) {
            try self.sendAnnouncement();
        }

        return null;
    }
};

// ═══════════════════════════════════════════════════════════════════════════
// UNIFIED RESOLVER
// ═══════════════════════════════════════════════════════════════════════════

/// Combined resolver using both STUN and mDNS
pub const Resolver = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    mdns: ?MdnsDiscovery = null,
    public_endpoint: ?Endpoint = null,
    local_endpoint: ?Endpoint = null,

    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.mdns) |*m| m.deinit();
    }

    /// Start mDNS discovery
    pub fn startMdns(self: *Self, code_hash: [16]u8) !void {
        if (self.mdns == null) {
            self.mdns = try MdnsDiscovery.init(self.allocator);
        }

        // Get local port (use ephemeral for now)
        try self.mdns.?.announce(code_hash, 0);
    }

    /// Query STUN for public endpoint
    pub fn queryStun(self: *Self) !Endpoint {
        var client = try StunClient.init();
        defer client.deinit();

        // Try each server until one works
        for (STUN_SERVERS) |server| {
            const response = client.query(server) catch continue;

            const endpoint = Endpoint.fromIp4(response.address, response.port);
            self.public_endpoint = endpoint;
            return endpoint;
        }

        return error.AllStunServersFailed;
    }

    /// Poll for local peers
    pub fn pollLocal(self: *Self, code_hash: [16]u8) !?Endpoint {
        if (self.mdns) |*m| {
            if (try m.poll(code_hash)) |peer| {
                return Endpoint.fromIp4(peer.address, peer.port);
            }
        }
        return null;
    }
};

// ═══════════════════════════════════════════════════════════════════════════
// Tests
// ═══════════════════════════════════════════════════════════════════════════

test "stun header serialization" {
    const header = StunHeader{
        .msg_type = .binding_request,
        .length = 0,
        .transaction_id = [_]u8{0x42} ** 12,
    };

    const buf = header.serialize();
    const decoded = try StunHeader.deserialize(&buf);

    try std.testing.expectEqual(header.msg_type, decoded.msg_type);
    try std.testing.expectEqual(header.length, decoded.length);
    try std.testing.expectEqualSlices(u8, &header.transaction_id, &decoded.transaction_id);
}

test "resolver initialization" {
    var resolver = try Resolver.init(std.testing.allocator);
    defer resolver.deinit();
}
