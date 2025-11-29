//! ═══════════════════════════════════════════════════════════════════════════
//! WARP GATE - Peer-to-Peer Code Transfer
//! ═══════════════════════════════════════════════════════════════════════════
//!
//! Direct laptop-to-laptop file transfer without cloud intermediaries.
//!
//! Features:
//! • One-time transfer codes (e.g., warp-729-alpha)
//! • NAT traversal via STUN + UDP hole punching
//! • Local network discovery via mDNS
//! • ChaCha20-Poly1305 encryption (no TLS overhead)
//! • Zero-copy streaming with io_uring
//! • Resume support for interrupted transfers
//!
//! Protocol flow:
//! 1. Sender generates transfer code from random bytes
//! 2. Both peers discover public IP:port via STUN
//! 3. Peers exchange endpoints through mDNS (local) or signaling (remote)
//! 4. UDP hole punching establishes direct connection
//! 5. Encrypted file stream with integrity verification

pub const crypto = @import("crypto/chacha.zig");
pub const network = @import("network/transport.zig");
pub const protocol = @import("protocol/wire.zig");
pub const discovery = @import("discovery/resolver.zig");
pub const warp_code = @import("protocol/warp_code.zig");

// Re-exports for convenience
pub const WarpCode = warp_code.WarpCode;
pub const Transport = network.Transport;
pub const FileStream = protocol.FileStream;
pub const Resolver = discovery.Resolver;

/// Warp Gate session for file transfer
pub const WarpSession = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    code: WarpCode,
    transport: ?Transport = null,
    resolver: Resolver,
    state: State = .idle,
    encryption_key: [32]u8 = undefined,

    pub const State = enum {
        idle,
        discovering,
        connecting,
        connected,
        handshaking,
        transferring,
        completed,
        failed,
    };

    pub const Role = enum {
        sender,
        receiver,
    };

    pub fn init(allocator: std.mem.Allocator, role: Role) !Self {
        const code = switch (role) {
            .sender => WarpCode.generate(),
            .receiver => WarpCode{ .bytes = [_]u8{0} ** 6 }, // Will be set via setCode
        };

        return Self{
            .allocator = allocator,
            .code = code,
            .resolver = try Resolver.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.transport) |*t| t.deinit();
        self.resolver.deinit();
        // Securely wipe encryption key
        crypto.secureZero(&self.encryption_key);
    }

    /// Set transfer code (receiver only)
    pub fn setCode(self: *Self, code_str: []const u8) !void {
        self.code = try WarpCode.parse(code_str);
        // Derive encryption key from code
        self.encryption_key = self.code.deriveKey();
    }

    /// Get transfer code string (sender displays this)
    pub fn getCodeString(self: *const Self) [WarpCode.STRING_LEN]u8 {
        return self.code.toString();
    }

    /// Start discovery and connection process
    pub fn connect(self: *Self) !void {
        self.state = .discovering;

        // Start mDNS discovery for local peers
        try self.resolver.startMdns(self.code.hash());

        // Query STUN for public endpoint
        const public_endpoint = try self.resolver.queryStun();
        _ = public_endpoint;

        // TODO: Exchange endpoints and perform hole punching
        self.state = .connecting;
    }

    /// Send a file or directory
    pub fn send(self: *Self, path: []const u8) !void {
        if (self.state != .connecting and self.state != .transferring) {
            return error.InvalidState;
        }

        self.state = .transferring;

        // Open file/directory and stream
        var stream = try FileStream.init(self.allocator, path);
        defer stream.deinit();

        // Send encrypted chunks
        while (try stream.nextChunk()) |chunk| {
            const encrypted = try crypto.encrypt(&self.encryption_key, chunk);
            if (self.transport) |*t| {
                try t.send(encrypted);
            }
        }

        self.state = .completed;
    }

    /// Receive files to destination
    pub fn receive(self: *Self, dest_path: []const u8) !void {
        if (self.state != .connecting and self.state != .transferring) {
            return error.InvalidState;
        }

        self.state = .transferring;

        // Create output stream
        var stream = try FileStream.initWrite(self.allocator, dest_path);
        defer stream.deinit();

        // Receive and decrypt chunks
        while (true) {
            if (self.transport) |*t| {
                const encrypted = try t.recv() orelse break;

                const decrypted = try crypto.decrypt(&self.encryption_key, encrypted);
                try stream.writeChunk(decrypted);
            } else break;
        }

        self.state = .completed;
    }
};

const std = @import("std");

// ═══════════════════════════════════════════════════════════════════════════
// Tests
// ═══════════════════════════════════════════════════════════════════════════

test "warp session lifecycle" {
    var sender = try WarpSession.init(std.testing.allocator, .sender);
    defer sender.deinit();

    const code_str = sender.getCodeString();
    try std.testing.expect(code_str[0] == 'w');
    try std.testing.expect(code_str[1] == 'a');
    try std.testing.expect(code_str[2] == 'r');
    try std.testing.expect(code_str[3] == 'p');
    try std.testing.expect(code_str[4] == '-');
}

test "warp code round-trip" {
    const original = WarpCode.generate();
    const str = original.toString();
    const parsed = try WarpCode.parse(&str);
    try std.testing.expectEqualSlices(u8, &original.bytes, &parsed.bytes);
}

test {
    std.testing.refAllDecls(@This());
}
