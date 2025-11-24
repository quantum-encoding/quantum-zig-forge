//! Guardian Shield - eBPF-based System Security Framework
//!
//! Copyright (c) 2025 Richard Tune / Quantum Encoding Ltd
//! Author: Richard Tune
//! Contact: info@quantumencoding.io
//! Website: https://quantumencoding.io
//!
//! License: Dual License - MIT (Non-Commercial) / Commercial License
//!
//! NON-COMMERCIAL USE (MIT License):
//! Permission is hereby granted, free of charge, to any person obtaining a copy
//! of this software and associated documentation files (the "Software"), to deal
//! in the Software without restriction for NON-COMMERCIAL purposes, including
//! without limitation the rights to use, copy, modify, merge, publish, distribute,
//! sublicense, and/or sell copies of the Software for non-commercial purposes,
//! and to permit persons to whom the Software is furnished to do so, subject to
//! the following conditions:
//!
//! The above copyright notice and this permission notice shall be included in all
//! copies or substantial portions of the Software.
//!
//! THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//! IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//! FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//! AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//! LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//! OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//! SOFTWARE.
//!
//! COMMERCIAL USE:
//! Commercial use of this software requires a separate commercial license.
//! Contact info@quantumencoding.io for commercial licensing terms.


// chronos.zig - The Sovereign Clock: Monotonically Increasing Timeline
// Purpose: Provide absolute, verifiable sequencing for parallel agentic warfare
//
// Doctrine: The JesterNet maintains its own sovereign timeline, independent of
// system clocks. Every agentic action is marked with a unique Chronos Tick.
//
// Architecture:
//   - Persistent AtomicU64 counter (survives reboots)
//   - Lock-free atomic operations (thread-safe)
//   - Monotonic guarantee (only increments, never decrements)
//   - File-backed persistence (/var/lib/chronos/tick.dat)

const std = @import("std");

/// Default path for persistent tick storage
pub const DEFAULT_TICK_PATH = "/var/lib/chronos/tick.dat";

/// Fallback path if system path not writable (for development/testing)
pub const FALLBACK_TICK_PATH = "/tmp/chronos-tick.dat";

/// The Chronos Clock - maintains sovereign timeline
pub const ChronosClock = struct {
    tick: std.atomic.Value(u64),
    tick_path: []const u8,
    allocator: std.mem.Allocator,

    /// Initialize Chronos Clock with persistent storage
    pub fn init(allocator: std.mem.Allocator, tick_path: ?[]const u8) !ChronosClock {
        const path = tick_path orelse DEFAULT_TICK_PATH;

        // Ensure directory exists
        const dir_path = std.fs.path.dirname(path) orelse "/var/lib/chronos";
        std.fs.cwd().makePath(dir_path) catch |err| {
            // If we can't create system path, fall back to /tmp
            if (err == error.AccessDenied or err == error.PermissionDenied) {
                std.debug.print("⚠️  Cannot create {s}, using fallback: {s}\n", .{dir_path, FALLBACK_TICK_PATH});
                return initWithPath(allocator, FALLBACK_TICK_PATH);
            }
            return err;
        };

        return initWithPath(allocator, path);
    }

    fn initWithPath(allocator: std.mem.Allocator, path: []const u8) !ChronosClock {
        // Load existing tick from file, or start at 0
        const initial_tick = loadTickFromFile(path) catch |err| blk: {
            if (err == error.FileNotFound) {
                std.debug.print("🕐 Chronos Clock initializing (no previous tick found)\n", .{});
                break :blk 0;
            }
            return err;
        };

        std.debug.print("🕐 Chronos Clock initialized at TICK-{d:0>10}\n", .{initial_tick});

        return ChronosClock{
            .tick = std.atomic.Value(u64).init(initial_tick),
            .tick_path = path,
            .allocator = allocator,
        };
    }

    /// Get current tick (non-destructive read)
    pub fn getTick(self: *const ChronosClock) u64 {
        return self.tick.load(.monotonic);
    }

    /// Increment and return next tick (atomic operation)
    pub fn nextTick(self: *ChronosClock) !u64 {
        const new_tick = self.tick.fetchAdd(1, .monotonic) + 1;

        // Persist to disk after increment
        try self.persistTick(new_tick);

        return new_tick;
    }

    /// Persist current tick to disk
    pub fn persistTick(self: *const ChronosClock, tick: u64) !void {
        const file = try std.fs.cwd().createFile(self.tick_path, .{ .truncate = true });
        defer file.close();

        var buf: [32]u8 = undefined;
        const tick_str = try std.fmt.bufPrint(&buf, "{d}\n", .{tick});
        try file.writeAll(tick_str);
    }

    /// Graceful shutdown - ensure tick is persisted
    pub fn deinit(self: *ChronosClock) void {
        const current_tick = self.getTick();
        self.persistTick(current_tick) catch |err| {
            std.debug.print("⚠️  Failed to persist tick on shutdown: {any}\n", .{err});
        };
        std.debug.print("🕐 Chronos Clock shutdown at TICK-{d:0>10}\n", .{current_tick});
    }
};

/// Load tick from persistent storage
fn loadTickFromFile(path: []const u8) !u64 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf: [32]u8 = undefined;
    const bytes_read = try file.read(&buf);
    const content = std.mem.trim(u8, buf[0..bytes_read], &std.ascii.whitespace);

    return try std.fmt.parseInt(u64, content, 10);
}

// ============================================================
// Tests
// ============================================================

test "ChronosClock init and increment" {
    const allocator = std.testing.allocator;

    // Use temporary path for testing
    const test_path = "/tmp/chronos-test-tick.dat";
    defer std.fs.cwd().deleteFile(test_path) catch {};

    var clock = try ChronosClock.init(allocator, test_path);
    defer clock.deinit();

    // Initial tick should be 0
    try std.testing.expectEqual(@as(u64, 0), clock.getTick());

    // Increment and verify
    const tick1 = try clock.nextTick();
    try std.testing.expectEqual(@as(u64, 1), tick1);

    const tick2 = try clock.nextTick();
    try std.testing.expectEqual(@as(u64, 2), tick2);

    // Current tick should match last increment
    try std.testing.expectEqual(@as(u64, 2), clock.getTick());
}

test "ChronosClock persistence across restarts" {
    const allocator = std.testing.allocator;
    const test_path = "/tmp/chronos-persist-test.dat";
    defer std.fs.cwd().deleteFile(test_path) catch {};

    // First instance
    {
        var clock = try ChronosClock.init(allocator, test_path);
        defer clock.deinit();

        _ = try clock.nextTick(); // 1
        _ = try clock.nextTick(); // 2
        _ = try clock.nextTick(); // 3
    }

    // Second instance (simulates restart)
    {
        var clock = try ChronosClock.init(allocator, test_path);
        defer clock.deinit();

        // Should resume from persisted tick
        try std.testing.expectEqual(@as(u64, 3), clock.getTick());

        const tick4 = try clock.nextTick();
        try std.testing.expectEqual(@as(u64, 4), tick4);
    }
}

test "ChronosClock monotonic guarantee" {
    const allocator = std.testing.allocator;
    const test_path = "/tmp/chronos-monotonic-test.dat";
    defer std.fs.cwd().deleteFile(test_path) catch {};

    var clock = try ChronosClock.init(allocator, test_path);
    defer clock.deinit();

    var prev_tick: u64 = 0;
    var i: usize = 0;
    while (i < 100) : (i += 1) {
        const tick = try clock.nextTick();
        try std.testing.expect(tick > prev_tick); // Strict monotonic increase
        prev_tick = tick;
    }
}
