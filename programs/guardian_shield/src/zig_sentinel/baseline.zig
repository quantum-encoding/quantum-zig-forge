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


// SPDX-License-Identifier: GPL-2.0
//
// baseline.zig - Baseline learning and persistence for zig-sentinel
//
// Purpose: Learn "normal" behavior patterns and persist them to disk
// Algorithm: Welford's online algorithm for numerically stable mean/variance
//

const std = @import("std");
const time_compat = @import("time_compat.zig");

/// Statistical baseline for a (PID, syscall) pair
pub const BaselineStats = struct {
    /// Number of samples collected
    count: u64,

    /// Running mean (average syscalls per update interval)
    mean: f64,

    /// Welford's M2 accumulator (for variance calculation)
    /// variance = m2 / (count - 1)
    /// stddev = sqrt(variance)
    m2: f64,

    /// Minimum observed value
    min: u64,

    /// Maximum observed value
    max: u64,

    /// Timestamp of last update (Unix epoch seconds)
    last_updated: i64,

    /// Calculate standard deviation
    pub fn stddev(self: BaselineStats) f64 {
        if (self.count < 2) return 0.0;
        const variance = self.m2 / @as(f64, @floatFromInt(self.count - 1));
        return @sqrt(variance);
    }

    /// Update statistics with new observation using Welford's algorithm
    /// This is numerically stable and suitable for online computation
    pub fn update(self: *BaselineStats, value: u64) void {
        self.count += 1;

        const value_f64 = @as(f64, @floatFromInt(value));
        const delta = value_f64 - self.mean;
        self.mean += delta / @as(f64, @floatFromInt(self.count));
        const delta2 = value_f64 - self.mean;
        self.m2 += delta * delta2;

        // Update min/max
        if (value < self.min) self.min = value;
        if (value > self.max) self.max = value;

        // Update timestamp
        self.last_updated = time_compat.timestamp();
    }

    /// Initialize with first observation
    pub fn init(value: u64) BaselineStats {
        return .{
            .count = 1,
            .mean = @as(f64, @floatFromInt(value)),
            .m2 = 0.0,
            .min = value,
            .max = value,
            .last_updated = time_compat.timestamp(),
        };
    }
};

/// Key for baseline lookup: (PID, syscall_nr)
pub const BaselineKey = struct {
    pid: u32,
    syscall_nr: u32,

    pub fn eql(self: BaselineKey, other: BaselineKey) bool {
        return self.pid == other.pid and self.syscall_nr == other.syscall_nr;
    }

    pub fn hash(self: BaselineKey) u64 {
        var hasher = std.hash.Wyhash.init(0);
        std.hash.autoHash(&hasher, self.pid);
        std.hash.autoHash(&hasher, self.syscall_nr);
        return hasher.final();
    }
};

/// Context for baseline learning
pub const BaselineContext = struct {
    const Self = @This();

    /// Map of (PID, syscall) -> statistics
    baselines: std.AutoHashMap(BaselineKey, BaselineStats),

    /// Learning period duration (seconds)
    learning_period_seconds: u32,

    /// Time when learning started
    learning_start_time: i64,

    /// Whether we're still in learning phase
    is_learning: bool,

    /// Path to baseline storage directory
    storage_path: []const u8,

    /// Allocator for heap operations
    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        learning_period_seconds: u32,
        storage_path: []const u8,
    ) Self {
        return .{
            .baselines = std.AutoHashMap(BaselineKey, BaselineStats).init(allocator),
            .learning_period_seconds = learning_period_seconds,
            .learning_start_time = time_compat.timestamp(),
            .is_learning = true,
            .storage_path = storage_path,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        self.baselines.deinit();
    }

    /// Update baseline with new observation
    pub fn updateBaseline(self: *Self, key: BaselineKey, value: u64) !void {
        if (self.baselines.getPtr(key)) |stats| {
            stats.update(value);
        } else {
            try self.baselines.put(key, BaselineStats.init(value));
        }
    }

    /// Check if learning period has completed
    pub fn checkLearningComplete(self: *Self) void {
        const current_time = time_compat.timestamp();
        const elapsed = current_time - self.learning_start_time;

        if (self.is_learning and elapsed >= self.learning_period_seconds) {
            self.is_learning = false;
            std.debug.print("\n✅ Learning period complete ({d}s)\n", .{elapsed});
            std.debug.print("📊 Baselines established for {d} (PID, syscall) pairs\n\n",
                .{self.baselines.count()});
        }
    }

    /// Get baseline statistics for a key
    pub fn getBaseline(self: *Self, key: BaselineKey) ?BaselineStats {
        return self.baselines.get(key);
    }

    /// Display learning progress
    pub fn displayProgress(self: *Self) void {
        const current_time = time_compat.timestamp();
        const elapsed = current_time - self.learning_start_time;

        std.debug.print("\r📚 Learning: {d}/{d}s | Patterns: {d}   ",
            .{ elapsed, self.learning_period_seconds, self.baselines.count() });
    }
};

/// Serialization structure for JSON output
pub const BaselineEntry = struct {
    pid: u32,
    syscall_nr: u32,
    count: u64,
    mean: f64,
    stddev: f64,
    min: u64,
    max: u64,
    last_updated: i64,
};

/// Save baselines for a specific PID to JSON file
pub fn saveBaselinesForPid(
    ctx: *BaselineContext,
    pid: u32,
) !void {
    // Create storage directory if it doesn't exist
    std.fs.cwd().makePath(ctx.storage_path) catch |err| {
        if (err != error.PathAlreadyExists) return err;
    };

    // Build filename: {storage_path}/{pid}.json
    const filename = try std.fmt.allocPrint(
        ctx.allocator,
        "{s}/{d}.json",
        .{ ctx.storage_path, pid },
    );
    defer ctx.allocator.free(filename);

    // Collect all baselines for this PID
    var entries = std.ArrayList(BaselineEntry){};
    defer entries.deinit(ctx.allocator);

    var iter = ctx.baselines.iterator();
    while (iter.next()) |entry| {
        if (entry.key_ptr.pid == pid) {
            try entries.append(ctx.allocator, .{
                .pid = entry.key_ptr.pid,
                .syscall_nr = entry.key_ptr.syscall_nr,
                .count = entry.value_ptr.count,
                .mean = entry.value_ptr.mean,
                .stddev = entry.value_ptr.stddev(),
                .min = entry.value_ptr.min,
                .max = entry.value_ptr.max,
                .last_updated = entry.value_ptr.last_updated,
            });
        }
    }

    if (entries.items.len == 0) return; // No baselines for this PID

    // Write to file
    const file = try std.fs.cwd().createFile(filename, .{});
    defer file.close();

    // Simple JSON array serialization (manual string formatting)
    try file.writeAll("[\n");
    for (entries.items, 0..) |entry, i| {
        // Format each entry manually
        const entry_str = try std.fmt.allocPrint(
            ctx.allocator,
            \\  {{
            \\    "pid": {d},
            \\    "syscall_nr": {d},
            \\    "count": {d},
            \\    "mean": {d:.2},
            \\    "stddev": {d:.2},
            \\    "min": {d},
            \\    "max": {d},
            \\    "last_updated": {d}
            \\  }}
        , .{
            entry.pid,
            entry.syscall_nr,
            entry.count,
            entry.mean,
            entry.stddev,
            entry.min,
            entry.max,
            entry.last_updated,
        });
        defer ctx.allocator.free(entry_str);

        try file.writeAll(entry_str);

        if (i < entries.items.len - 1) {
            try file.writeAll(",\n");
        } else {
            try file.writeAll("\n");
        }
    }
    try file.writeAll("]\n");
}

/// Save all baselines to disk (one file per PID)
pub fn saveAllBaselines(ctx: *BaselineContext) !void {
    // Get unique PIDs
    var pids = std.AutoHashMap(u32, void).init(ctx.allocator);
    defer pids.deinit();

    var iter = ctx.baselines.iterator();
    while (iter.next()) |entry| {
        try pids.put(entry.key_ptr.pid, {});
    }

    // Save baselines for each PID
    var pid_iter = pids.iterator();
    while (pid_iter.next()) |entry| {
        try saveBaselinesForPid(ctx, entry.key_ptr.*);
    }

    std.debug.print("💾 Saved baselines for {d} processes to {s}/\n",
        .{ pids.count(), ctx.storage_path });
}

/// Load baselines from disk for a specific PID
pub fn loadBaselinesForPid(
    ctx: *BaselineContext,
    pid: u32,
) !void {
    const filename = try std.fmt.allocPrint(
        ctx.allocator,
        "{s}/{d}.json",
        .{ ctx.storage_path, pid },
    );
    defer ctx.allocator.free(filename);

    const file = std.fs.cwd().openFile(filename, .{}) catch |err| {
        if (err == error.FileNotFound) return; // No baseline file, skip
        return err;
    };
    defer file.close();

    // Read entire file
    const file_size = (try file.stat()).size;
    const content = try ctx.allocator.alloc(u8, file_size);
    defer ctx.allocator.free(content);
    _ = try file.read(content);

    // Parse JSON array
    const parsed = try std.json.parseFromSlice(
        []BaselineEntry,
        ctx.allocator,
        content,
        .{},
    );
    defer parsed.deinit();

    // Load each baseline entry into the context
    for (parsed.value) |entry| {
        const key = BaselineKey{
            .pid = entry.pid,
            .syscall_nr = entry.syscall_nr,
        };

        // Reconstruct M2 from stddev and count
        // variance = stddev^2
        // m2 = variance * (count - 1)
        const variance = entry.stddev * entry.stddev;
        const m2 = if (entry.count > 1)
            variance * @as(f64, @floatFromInt(entry.count - 1))
        else
            0.0;

        const stats = BaselineStats{
            .count = entry.count,
            .mean = entry.mean,
            .m2 = m2,
            .min = entry.min,
            .max = entry.max,
            .last_updated = entry.last_updated,
        };

        try ctx.baselines.put(key, stats);
    }
}

/// Load all baselines from disk (scan directory for PID files)
pub fn loadAllBaselines(ctx: *BaselineContext) !usize {
    var loaded_count: usize = 0;

    // Open baseline storage directory
    var dir = std.fs.cwd().openDir(ctx.storage_path, .{ .iterate = true }) catch |err| {
        if (err == error.FileNotFound) return 0; // No baseline directory yet
        return err;
    };
    defer dir.close();

    // Iterate through files
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .file) continue;

        // Check if filename is {pid}.json
        if (std.mem.endsWith(u8, entry.name, ".json")) {
            // Extract PID from filename
            const pid_str = entry.name[0 .. entry.name.len - 5]; // Remove ".json"
            const pid = std.fmt.parseInt(u32, pid_str, 10) catch continue;

            // Load baselines for this PID
            loadBaselinesForPid(ctx, pid) catch |err| {
                std.debug.print("⚠️  Failed to load baselines for PID {d}: {any}\n", .{ pid, err });
                continue;
            };

            loaded_count += 1;
        }
    }

    return loaded_count;
}
