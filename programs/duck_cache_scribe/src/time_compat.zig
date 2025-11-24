/// Zig 0.16 compatibility layer for time functions
const std = @import("std");

/// Get current Unix timestamp in seconds (replaces std.time.timestamp())
pub fn timestamp() i64 {
    const ts = std.posix.clock_gettime(.REALTIME) catch return 0;
    return ts.sec;
}
