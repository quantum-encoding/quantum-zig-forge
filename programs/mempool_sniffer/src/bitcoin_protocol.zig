const std = @import("std");

// Bitcoin protocol helper functions
// TODO: Extract from /home/founder/zig_forge/grok/src/stratum/client.zig

pub fn buildVersionMessage() ![125]u8 {
    // Placeholder - will be filled from client.zig
    return error.NotImplemented;
}

pub fn parseTransaction(payload: []const u8) !void {
    // Placeholder - will be filled from client.zig
    _ = payload;
    return error.NotImplemented;
}
