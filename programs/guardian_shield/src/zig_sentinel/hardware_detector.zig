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
// hardware_detector.zig - Automatic Hardware Capability Detection
//
// Purpose: Detect CPU cores, cache sizes, and memory to select appropriate hardware profile
// Architecture: Reads /proc/cpuinfo, /proc/meminfo, /sys/devices/system/cpu
// Philosophy: Know thyself - the weapon must understand its host
//

const std = @import("std");

/// Hardware capabilities detected from the system
pub const HardwareCapabilities = struct {
    /// Number of logical CPU cores
    cpu_cores: u32,

    /// L3 cache size in MB (total across all sockets)
    l3_cache_mb: u32,

    /// Total system memory in MB
    total_memory_mb: u64,

    /// Number of NUMA nodes (0 if not detected)
    numa_nodes: u32,

    /// CPU model name
    cpu_model: [256]u8,
    cpu_model_len: usize,

    /// Detected hardware tier (0-3)
    tier: u8,

    /// Profile name
    profile_name: [64]u8,
    profile_name_len: usize,
};

/// Hardware tier classification
pub const HardwareTier = enum(u8) {
    embedded = 0, // 1-4 cores, <8MB cache
    laptop = 1, // 4-16 cores, 8-32MB cache
    server = 2, // 16-128 cores, 32-256MB cache
    c4d_instance = 3, // 256+ cores, 1GB+ cache
};

/// Hardware detector
pub const HardwareDetector = struct {
    const Self = @This();

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }

    /// Detect hardware capabilities
    pub fn detect(self: *Self) !HardwareCapabilities {
        var caps: HardwareCapabilities = undefined;

        // Detect CPU cores
        caps.cpu_cores = try self.detectCPUCores();

        // Detect L3 cache size
        caps.l3_cache_mb = try self.detectL3CacheSize();

        // Detect total memory
        caps.total_memory_mb = try self.detectTotalMemory();

        // Detect NUMA nodes
        caps.numa_nodes = self.detectNUMANodes() catch 0;

        // Get CPU model
        const model = try self.detectCPUModel();
        defer self.allocator.free(model); // Free allocated model string
        @memcpy(caps.cpu_model[0..model.len], model);
        caps.cpu_model_len = model.len;

        // Classify hardware tier
        caps.tier = @intFromEnum(self.classifyTier(&caps));

        // Get profile name
        const profile_name = self.getTierProfileName(caps.tier);
        @memcpy(caps.profile_name[0..profile_name.len], profile_name);
        caps.profile_name_len = profile_name.len;

        return caps;
    }

    /// Detect number of CPU cores
    fn detectCPUCores(self: *Self) !u32 {
        // Try reading /proc/cpuinfo
        const file = std.fs.openFileAbsolute("/proc/cpuinfo", .{}) catch |err| {
            std.log.err("Failed to open /proc/cpuinfo: {}", .{err});
            return error.CannotDetectCPU;
        };
        defer file.close();

        // /proc files don't have a real file size, use fixed buffer
        const buffer = try self.allocator.alloc(u8, 1024 * 1024);
        defer self.allocator.free(buffer);
        const bytes_read = try file.read(buffer);
        const content = buffer[0..bytes_read];

        // Count "processor" lines
        var cores: u32 = 0;
        var lines = std.mem.splitScalar(u8, content, '\n');
        while (lines.next()) |line| {
            if (std.mem.startsWith(u8, line, "processor")) {
                cores += 1;
            }
        }

        if (cores == 0) {
            // Fallback: Try std.Thread.getCpuCount()
            cores = @intCast(std.Thread.getCpuCount() catch 1);
        }

        return cores;
    }

    /// Detect L3 cache size in MB
    fn detectL3CacheSize(self: *Self) !u32 {
        // Try reading cache info from sysfs
        var total_l3_kb: u64 = 0;

        // Iterate over CPU indices to find cache info
        var cpu_idx: u32 = 0;
        while (cpu_idx < 1024) : (cpu_idx += 1) {
            const path = std.fmt.allocPrint(
                self.allocator,
                "/sys/devices/system/cpu/cpu{d}/cache/index3/size",
                .{cpu_idx},
            ) catch break;
            defer self.allocator.free(path);

            const file = std.fs.openFileAbsolute(path, .{}) catch break;
            defer file.close();

            var buf: [64]u8 = undefined;
            const bytes_read = try file.read(&buf);
            if (bytes_read == 0) break;

            // Parse size (format: "12288K" or "12M")
            const size_str = std.mem.trim(u8, buf[0..bytes_read], " \n\r\t");
            if (size_str.len == 0) break;

            const unit = size_str[size_str.len - 1];
            const value_str = size_str[0 .. size_str.len - 1];
            const value = std.fmt.parseInt(u64, value_str, 10) catch break;

            const kb_value = switch (unit) {
                'K' => value,
                'M' => value * 1024,
                'G' => value * 1024 * 1024,
                else => 0,
            };

            total_l3_kb = kb_value;
            break; // Found L3 cache for first CPU, assume uniform
        }

        if (total_l3_kb == 0) {
            // Fallback: Parse /proc/cpuinfo for "cache size"
            const file = std.fs.openFileAbsolute("/proc/cpuinfo", .{}) catch {
                return 0; // Unknown cache size
            };
            defer file.close();

            // /proc files don't have a real file size, use fixed buffer
            const buffer = try self.allocator.alloc(u8, 1024 * 1024);
            defer self.allocator.free(buffer);
            const bytes_read = try file.read(buffer);
            const content = buffer[0..bytes_read];

            var lines = std.mem.splitScalar(u8, content, '\n');
            while (lines.next()) |line| {
                if (std.mem.startsWith(u8, line, "cache size")) {
                    // Format: "cache size\t: 12288 KB"
                    if (std.mem.indexOf(u8, line, ":")) |colon_pos| {
                        const value_part = std.mem.trim(u8, line[colon_pos + 1 ..], " \t");
                        var parts = std.mem.splitScalar(u8, value_part, ' ');
                        if (parts.next()) |num_str| {
                            const kb = std.fmt.parseInt(u64, num_str, 10) catch 0;
                            total_l3_kb = kb;
                            break;
                        }
                    }
                }
            }
        }

        const total_l3_mb: u32 = @intCast(total_l3_kb / 1024);
        return total_l3_mb;
    }

    /// Detect total system memory in MB
    fn detectTotalMemory(self: *Self) !u64 {
        const file = std.fs.openFileAbsolute("/proc/meminfo", .{}) catch |err| {
            std.log.err("Failed to open /proc/meminfo: {}", .{err});
            return error.CannotDetectMemory;
        };
        defer file.close();

        // /proc files don't have a real file size, use fixed buffer
        const buffer = try self.allocator.alloc(u8, 64 * 1024);
        defer self.allocator.free(buffer);
        const bytes_read = try file.read(buffer);
        const content = buffer[0..bytes_read];

        // Find "MemTotal:" line
        var lines = std.mem.splitScalar(u8, content, '\n');
        while (lines.next()) |line| {
            if (std.mem.startsWith(u8, line, "MemTotal:")) {
                // Format: "MemTotal:       16384000 kB"
                if (std.mem.indexOf(u8, line, ":")) |colon_pos| {
                    const value_part = std.mem.trim(u8, line[colon_pos + 1 ..], " \t");
                    var parts = std.mem.splitScalar(u8, value_part, ' ');
                    if (parts.next()) |kb_str| {
                        const kb = try std.fmt.parseInt(u64, kb_str, 10);
                        return kb / 1024; // Convert to MB
                    }
                }
            }
        }

        return error.CannotDetectMemory;
    }

    /// Detect number of NUMA nodes
    fn detectNUMANodes(self: *Self) !u32 {
        _ = self;

        var dir = std.fs.openDirAbsolute("/sys/devices/system/node", .{ .iterate = true }) catch {
            return 0; // No NUMA support or not accessible
        };
        defer dir.close();

        var count: u32 = 0;
        var iter = dir.iterate();
        while (iter.next() catch null) |entry| {
            if (std.mem.startsWith(u8, entry.name, "node")) {
                count += 1;
            }
        }

        return count;
    }

    /// Detect CPU model name
    fn detectCPUModel(self: *Self) ![]const u8 {
        const file = std.fs.openFileAbsolute("/proc/cpuinfo", .{}) catch {
            return "Unknown CPU";
        };
        defer file.close();

        // /proc files don't have a real file size, use fixed buffer
        const buffer = try self.allocator.alloc(u8, 1024 * 1024);
        defer self.allocator.free(buffer);
        const bytes_read = try file.read(buffer);
        const content = buffer[0..bytes_read];

        // Find "model name" line
        var lines = std.mem.splitScalar(u8, content, '\n');
        while (lines.next()) |line| {
            if (std.mem.startsWith(u8, line, "model name")) {
                if (std.mem.indexOf(u8, line, ":")) |colon_pos| {
                    const model = std.mem.trim(u8, line[colon_pos + 1 ..], " \t");
                    // Allocate and return copy
                    const model_copy = try self.allocator.alloc(u8, model.len);
                    @memcpy(model_copy, model);
                    return model_copy;
                }
            }
        }

        const fallback = "Unknown CPU";
        const copy = try self.allocator.alloc(u8, fallback.len);
        @memcpy(copy, fallback);
        return copy;
    }

    /// Classify hardware into tier
    fn classifyTier(self: *Self, caps: *const HardwareCapabilities) HardwareTier {
        _ = self;

        // C4D instance: 256+ cores OR 1GB+ cache
        if (caps.cpu_cores >= 256 or caps.l3_cache_mb >= 1024) {
            return .c4d_instance;
        }

        // Server: 16+ cores OR 32MB+ cache
        if (caps.cpu_cores >= 16 or caps.l3_cache_mb >= 32) {
            return .server;
        }

        // Laptop: 4+ cores OR 8MB+ cache
        if (caps.cpu_cores >= 4 or caps.l3_cache_mb >= 8) {
            return .laptop;
        }

        // Embedded: Everything else
        return .embedded;
    }

    /// Get profile name for tier
    fn getTierProfileName(self: *Self, tier: u8) []const u8 {
        _ = self;
        return switch (@as(HardwareTier, @enumFromInt(tier))) {
            .embedded => "embedded",
            .laptop => "laptop",
            .server => "server",
            .c4d_instance => "c4d_instance",
        };
    }

    /// Print hardware capabilities
    pub fn printCapabilities(caps: *const HardwareCapabilities) void {
        std.debug.print("╔═══════════════════════════════════════════════════════════╗\n", .{});
        std.debug.print("║         HARDWARE CAPABILITIES DETECTED                    ║\n", .{});
        std.debug.print("╚═══════════════════════════════════════════════════════════╝\n", .{});
        std.debug.print("\n", .{});

        std.debug.print("CPU Model:    {s}\n", .{caps.cpu_model[0..caps.cpu_model_len]});
        std.debug.print("CPU Cores:    {d}\n", .{caps.cpu_cores});
        std.debug.print("L3 Cache:     {d} MB\n", .{caps.l3_cache_mb});
        std.debug.print("Total Memory: {d} MB ({d:.1} GB)\n", .{
            caps.total_memory_mb,
            @as(f64, @floatFromInt(caps.total_memory_mb)) / 1024.0,
        });
        if (caps.numa_nodes > 0) {
            std.debug.print("NUMA Nodes:   {d}\n", .{caps.numa_nodes});
        }
        std.debug.print("\n", .{});
        std.debug.print("Detected Tier:    {d} ({s})\n", .{
            caps.tier,
            caps.profile_name[0..caps.profile_name_len],
        });
        std.debug.print("\n", .{});

        // Recommended configuration
        const profile = caps.profile_name[0..caps.profile_name_len];
        if (std.mem.eql(u8, profile, "embedded")) {
            std.debug.print("Recommended Configuration:\n", .{});
            std.debug.print("  - Max Patterns: 5\n", .{});
            std.debug.print("  - Categories: reverse_shell, privilege_escalation\n", .{});
            std.debug.print("  - Multi-Dimensional: Disabled\n", .{});
        } else if (std.mem.eql(u8, profile, "laptop")) {
            std.debug.print("Recommended Configuration:\n", .{});
            std.debug.print("  - Max Patterns: 20\n", .{});
            std.debug.print("  - Categories: reverse_shell, privesc, fork_bomb, crypto_mining\n", .{});
            std.debug.print("  - Multi-Dimensional: Enabled\n", .{});
            std.debug.print("  - Resource Monitoring: 5s interval\n", .{});
        } else if (std.mem.eql(u8, profile, "server")) {
            std.debug.print("Recommended Configuration:\n", .{});
            std.debug.print("  - Max Patterns: 1,000\n", .{});
            std.debug.print("  - Categories: All major threats\n", .{});
            std.debug.print("  - Multi-Dimensional: Enabled\n", .{});
            std.debug.print("  - Resource Monitoring: 2s interval\n", .{});
            std.debug.print("  - Network Monitoring: Enabled\n", .{});
        } else if (std.mem.eql(u8, profile, "c4d_instance")) {
            std.debug.print("Recommended Configuration:\n", .{});
            std.debug.print("  - Max Patterns: 100,000+\n", .{});
            std.debug.print("  - Categories: ALL (full threat intelligence)\n", .{});
            std.debug.print("  - Multi-Dimensional: Enabled\n", .{});
            std.debug.print("  - XDP Layer: Enabled\n", .{});
            std.debug.print("  - DPDK Layer: Enabled\n", .{});
            std.debug.print("  - Resource Monitoring: 1s interval\n", .{});
            std.debug.print("  - Network Monitoring: 1s interval\n", .{});
            std.debug.print("\n", .{});
            std.debug.print("  Pattern Database Cache Residency:\n", .{});
            const pattern_db_mb: u32 = 150; // 100K patterns × 1.5KB
            const cache_percent = (@as(f64, @floatFromInt(pattern_db_mb)) / @as(f64, @floatFromInt(caps.l3_cache_mb))) * 100.0;
            std.debug.print("    - Pattern DB Size: {d} MB\n", .{pattern_db_mb});
            std.debug.print("    - L3 Cache Usage: {d:.1}%\n", .{cache_percent});
            std.debug.print("    - Lookup Latency: <100ns (cache resident)\n", .{});
        }

        std.debug.print("\n", .{});
    }
};

/// Test hardware detection
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var detector = HardwareDetector.init(allocator);
    defer detector.deinit();

    std.debug.print("Detecting hardware capabilities...\n\n", .{});

    const caps = try detector.detect();

    HardwareDetector.printCapabilities(&caps);

    // Free CPU model string
    if (caps.cpu_model_len > 0) {
        // Model was allocated in detectCPUModel, but we copied it to the struct
        // The allocator will clean it up
    }
}
