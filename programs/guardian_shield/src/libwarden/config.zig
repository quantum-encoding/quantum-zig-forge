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


// config.zig - Configuration parser for libwarden.so V4
// Purpose: Load and parse warden-config.json at runtime with robust parsing

const std = @import("std");

// ============================================================
// Configuration Structures
// ============================================================

pub const GlobalConfig = struct {
    enabled: bool = true,
    log_level: []const u8 = "normal",
    log_target: []const u8 = "stderr",
    block_emoji: []const u8 = "🛡️",
    warning_emoji: []const u8 = "⚠️",
    allow_emoji: []const u8 = "✓",
};

pub const ProtectedPath = struct {
    path: []const u8,
    description: []const u8,
    block_operations: []const []const u8,
};

pub const WhitelistedPath = struct {
    path: []const u8,
    description: []const u8,
};

pub const ProtectionConfig = struct {
    protected_paths: []ProtectedPath,
    whitelisted_paths: []WhitelistedPath,
};

pub const AdvancedConfig = struct {
    cache_path_checks: bool = true,
    max_cache_size: usize = 1000,
    allow_symlink_bypass: bool = false,
    canonicalize_paths: bool = true,
    notify_auditd: bool = true,
    auditd_key: []const u8 = "libwarden_block",
    allow_env_override: bool = false,
};

pub const DirectoryProtection = struct {
    enabled: bool = true,
    description: []const u8 = "",
    protected_roots: []const []const u8,
    protected_patterns: []const []const u8,
};

// V7.1: Process-aware restrictions
pub const ProcessRestrictions = struct {
    block_tmp_write: bool = false,
    block_tmp_execute: bool = false,
    block_dotfile_write: bool = false,
    monitored_dotfiles: []const []const u8 = &[_][]const u8{},
};

pub const RestrictedProcess = struct {
    name: []const u8,
    description: []const u8,
    restrictions: ProcessRestrictions,
};

pub const ProcessRestrictionConfig = struct {
    enabled: bool = false,
    description: []const u8 = "",
    restricted_processes: []const RestrictedProcess = &[_]RestrictedProcess{},
    whitelist_mode: bool = false,
    enforcement_level: []const u8 = "strict",
    log_process_name: bool = true,
};

// V7.2: Process exemptions for trusted build tools
pub const ProcessExemptions = struct {
    enabled: bool = true,
    description: []const u8 = "",
    exempt_processes: []const []const u8 = &[_][]const u8{},
};

// Root config structure matching JSON schema
const RawConfig = struct {
    global: GlobalConfig,
    protection: ProtectionConfig,
    directory_protection: DirectoryProtection = DirectoryProtection{
        .protected_roots = &[_][]const u8{},
        .protected_patterns = &[_][]const u8{},
    },
    process_exemptions: ProcessExemptions = ProcessExemptions{},
    process_restrictions: ProcessRestrictionConfig = ProcessRestrictionConfig{},
    advanced: AdvancedConfig,
};

pub const Config = struct {
    global: GlobalConfig,
    protected_paths: []ProtectedPath,
    whitelisted_paths: []WhitelistedPath,
    directory_protection: DirectoryProtection,
    process_exemptions: ProcessExemptions,
    process_restrictions: ProcessRestrictionConfig,
    advanced: AdvancedConfig,

    // Allocator used for dynamic memory
    allocator: std.mem.Allocator,

    // Store the parsed JSON result for proper cleanup
    parsed_json: ?*std.json.Parsed(RawConfig) = null,

    pub fn deinit(self: *Config) void {
        if (self.parsed_json) |parsed| {
            parsed.deinit();
            self.allocator.destroy(parsed);
        } else {
            // For default config, manually free allocations
            self.allocator.free(self.protected_paths);
            self.allocator.free(self.whitelisted_paths);
        }
    }
};

// ============================================================
// Configuration Loading
// ============================================================

const CONFIG_PATHS = [_][]const u8{
    "/etc/warden/warden-config.json",
    "/forge/config/warden-config-docker-test.json", // Docker test config
    "./config/warden-config.json",
    "/home/founder/zig_forge/config/warden-config.json",
};

/// Load configuration from JSON file
pub fn loadConfig(allocator: std.mem.Allocator) !Config {
    // Try each config path in order
    for (CONFIG_PATHS) |path| {
        if (loadConfigFromPath(allocator, path)) |config| {
            std.debug.print("[libwarden.so] ✓ Loaded config from: {s}\n", .{path});
            return config;
        } else |_| {
            continue;
        }
    }

    // If no config found, return error
    std.debug.print("[libwarden.so] ⚠️  No config file found, using defaults\n", .{});
    return error.ConfigNotFound;
}

fn loadConfigFromPath(allocator: std.mem.Allocator, path: []const u8) !Config {
    // Open file
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    // Read entire file
    const file_size = try file.getEndPos();
    const content = try allocator.alloc(u8, file_size);
    // DO NOT FREE: parseFromSlice stores pointers into this buffer
    // In LD_PRELOAD libraries, we intentionally leak memory on init
    // defer allocator.free(content);  // REMOVED - would cause use-after-free

    const bytes_read = try file.read(content);
    if (bytes_read != file_size) return error.ReadError;

    // Parse JSON directly into struct using parseFromSlice
    const parsed_ptr = try allocator.create(std.json.Parsed(RawConfig));
    parsed_ptr.* = try std.json.parseFromSlice(
        RawConfig,
        allocator,
        content,
        .{ .ignore_unknown_fields = true },
    );

    return Config{
        .global = parsed_ptr.value.global,
        .protected_paths = parsed_ptr.value.protection.protected_paths,
        .whitelisted_paths = parsed_ptr.value.protection.whitelisted_paths,
        .directory_protection = parsed_ptr.value.directory_protection,
        .process_exemptions = parsed_ptr.value.process_exemptions,
        .process_restrictions = parsed_ptr.value.process_restrictions,
        .advanced = parsed_ptr.value.advanced,
        .allocator = allocator,
        .parsed_json = parsed_ptr,
    };
}

// ============================================================
// Default/Fallback Configuration
// ============================================================

/// Returns hardcoded default configuration if JSON loading fails
pub fn getDefaultConfig(allocator: std.mem.Allocator) !Config {
    var protected_paths = try allocator.alloc(ProtectedPath, 9);
    protected_paths[0] = ProtectedPath{
        .path = "/etc/",
        .description = "System configuration",
        .block_operations = &[_][]const u8{ "unlink", "unlinkat", "rmdir", "open_write", "rename" },
    };
    protected_paths[1] = ProtectedPath{
        .path = "/boot/",
        .description = "Boot partition",
        .block_operations = &[_][]const u8{ "unlink", "unlinkat", "rmdir", "open_write", "rename" },
    };
    protected_paths[2] = ProtectedPath{
        .path = "/sys/",
        .description = "Kernel sysfs",
        .block_operations = &[_][]const u8{ "unlink", "unlinkat", "rmdir", "open_write", "rename" },
    };
    protected_paths[3] = ProtectedPath{
        .path = "/proc/",
        .description = "Process filesystem",
        .block_operations = &[_][]const u8{ "unlink", "unlinkat", "rmdir", "open_write", "rename" },
    };
    protected_paths[4] = ProtectedPath{
        .path = "/dev/sda",
        .description = "Block device",
        .block_operations = &[_][]const u8{"open_write"},
    };
    protected_paths[5] = ProtectedPath{
        .path = "/dev/nvme",
        .description = "NVMe device",
        .block_operations = &[_][]const u8{"open_write"},
    };
    protected_paths[6] = ProtectedPath{
        .path = "/dev/vd",
        .description = "Virtual disk",
        .block_operations = &[_][]const u8{"open_write"},
    };
    protected_paths[7] = ProtectedPath{
        .path = "/usr/lib/",
        .description = "System libraries",
        .block_operations = &[_][]const u8{ "unlink", "unlinkat", "rmdir", "open_write" },
    };
    protected_paths[8] = ProtectedPath{
        .path = "/usr/bin/",
        .description = "System binaries",
        .block_operations = &[_][]const u8{ "unlink", "unlinkat", "rmdir", "open_write" },
    };

    var whitelisted_paths = try allocator.alloc(WhitelistedPath, 5);
    whitelisted_paths[0] = WhitelistedPath{ .path = "/proc/self/", .description = "Process-specific" };
    whitelisted_paths[1] = WhitelistedPath{ .path = "/tmp/", .description = "Temporary directory" };
    whitelisted_paths[2] = WhitelistedPath{ .path = "/home/founder/tmp/", .description = "User temp" };
    whitelisted_paths[3] = WhitelistedPath{ .path = "/home/founder/sandbox/", .description = "Sandbox" };
    whitelisted_paths[4] = WhitelistedPath{ .path = "/home/founder/.claude/", .description = "Claude Code directory" };

    return Config{
        .global = GlobalConfig{},
        .protected_paths = protected_paths,
        .whitelisted_paths = whitelisted_paths,
        .directory_protection = DirectoryProtection{
            .protected_roots = &[_][]const u8{},
            .protected_patterns = &[_][]const u8{},
        },
        .process_exemptions = ProcessExemptions{},
        .process_restrictions = ProcessRestrictionConfig{},
        .advanced = AdvancedConfig{},
        .allocator = allocator,
    };
}
