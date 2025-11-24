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


// libwarden.so V7.1 - Guardian Shield with Process-Aware Security ("Whitelist of the Damned")
// Purpose: Runtime-configurable syscall interception with surgical process restrictions
//
// V7.1 Features (The "Whitelist of the Damned" Doctrine):
// - NEW: Process-aware restrictions - target untrusted AI agents specifically
// - NEW: Block /tmp write for restricted processes (python, harvester, codex-cli)
// - NEW: Block /tmp execute for restricted processes (prevents Ephemeral Execution Attack)
// - NEW: Protect dotfiles (.bashrc, .zshrc) from modification by untrusted processes
// - NEW: chmod() interceptor (prevents making /tmp files executable)
// - NEW: execve() interceptor (blocks execution from /tmp)
// - V7.0: Protect directory structures (Living Citadel) while allowing internal operations
// - V7.0: Git's internal mechanisms (.git/index.lock) allowed
// - Thread-safe initialization using std.once
// - Memory safety: No atexit cleanup (OS handles cleanup on process exit)
// - Robust JSON parsing with parseFromSlice
// - Zero race conditions, zero segfaults
//
// Protected syscalls: unlink, unlinkat, rmdir, open, openat, rename, renameat, chmod, execve

const std = @import("std");
const config_mod = @import("config.zig");

const c = @cImport({
    @cInclude("dlfcn.h");
    @cInclude("fcntl.h");
    @cInclude("unistd.h");
    @cInclude("stdlib.h");
});

// Import errno functions
extern "c" fn __errno_location() *c_int;

// ============================================================
// Global State (Thread-Safe Singleton)
// ============================================================

const GlobalState = struct {
    config: config_mod.Config,

    // Function pointers to original syscalls
    original_unlink: *const fn ([*:0]const u8) callconv(.c) c_int,
    original_unlinkat: *const fn (c_int, [*:0]const u8, c_int) callconv(.c) c_int,
    original_rmdir: *const fn ([*:0]const u8) callconv(.c) c_int,
    original_open: *const fn ([*:0]const u8, c_int, ...) callconv(.c) c_int,
    original_openat: *const fn (c_int, [*:0]const u8, c_int, ...) callconv(.c) c_int,
    original_rename: *const fn ([*:0]const u8, [*:0]const u8) callconv(.c) c_int,
    original_renameat: *const fn (c_int, [*:0]const u8, c_int, [*:0]const u8) callconv(.c) c_int,
    original_chmod: *const fn ([*:0]const u8, c_int) callconv(.c) c_int,
    original_execve: *const fn ([*:0]const u8, [*:null]?[*:0]const u8, [*:null]?[*:0]const u8) callconv(.c) c_int,

    fn deinit(self: *GlobalState) void {
        self.config.deinit();
    }
};

// V6.1: Use c_allocator instead of GPA for LD_PRELOAD safety
// The C allocator doesn't have destructors, so it won't try to clean up on exit
// Memory "leaks" are intentional - the OS cleans up when the process dies
const allocator = std.heap.c_allocator;
var global_state: ?*GlobalState = null;

const InitOnce = struct {
    fn do() void {
        // Use the global c_allocator (no local shadowing needed)

        const state = allocator.create(GlobalState) catch {
            std.debug.print("[libwarden.so] ⚠️  Failed to allocate global state\n", .{});
            return;
        };

        // Load configuration
        var cfg = config_mod.loadConfig(allocator) catch |err| blk: {
            std.debug.print("[libwarden.so] ⚠️  Config load failed ({any}), using defaults\n", .{err});
            break :blk config_mod.getDefaultConfig(allocator) catch |default_err| {
                std.debug.print("[libwarden.so] ⚠️  Default config failed ({any}), shield disabled!\n", .{default_err});
                allocator.destroy(state);
                return;
            };
        };

        // Load function pointers
        const unlink_ptr = c.dlsym(c.RTLD_NEXT, "unlink") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original unlink\n", .{});
            // V6.1: Do NOT call cfg.deinit() - let memory leak
            allocator.destroy(state);
            return;
        };

        const unlinkat_ptr = c.dlsym(c.RTLD_NEXT, "unlinkat") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original unlinkat\n", .{});
            allocator.destroy(state);
            return;
        };

        const rmdir_ptr = c.dlsym(c.RTLD_NEXT, "rmdir") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original rmdir\n", .{});
            allocator.destroy(state);
            return;
        };

        const open_ptr = c.dlsym(c.RTLD_NEXT, "open") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original open\n", .{});
            allocator.destroy(state);
            return;
        };

        const openat_ptr = c.dlsym(c.RTLD_NEXT, "openat") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original openat\n", .{});
            allocator.destroy(state);
            return;
        };

        const rename_ptr = c.dlsym(c.RTLD_NEXT, "rename") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original rename\n", .{});
            allocator.destroy(state);
            return;
        };

        const renameat_ptr = c.dlsym(c.RTLD_NEXT, "renameat") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original renameat\n", .{});
            allocator.destroy(state);
            return;
        };

        const chmod_ptr = c.dlsym(c.RTLD_NEXT, "chmod") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original chmod\n", .{});
            allocator.destroy(state);
            return;
        };

        const execve_ptr = c.dlsym(c.RTLD_NEXT, "execve") orelse {
            std.debug.print("[libwarden.so] ⚠️  Failed to load original execve\n", .{});
            allocator.destroy(state);
            return;
        };

        // Print initialization message BEFORE moving cfg into state
        if (cfg.global.enabled) {
            std.debug.print("[libwarden.so] {s} Guardian Shield V7.2 - Scanning background process...\n", .{cfg.global.block_emoji});
        } else {
            std.debug.print("[libwarden.so] ⚠️  Shield is DISABLED via config\n", .{});
        }

        // Initialize state
        state.* = GlobalState{
            .config = cfg,
            .original_unlink = @ptrCast(unlink_ptr),
            .original_unlinkat = @ptrCast(unlinkat_ptr),
            .original_rmdir = @ptrCast(rmdir_ptr),
            .original_open = @ptrCast(open_ptr),
            .original_openat = @ptrCast(openat_ptr),
            .original_rename = @ptrCast(rename_ptr),
            .original_renameat = @ptrCast(renameat_ptr),
            .original_chmod = @ptrCast(chmod_ptr),
            .original_execve = @ptrCast(execve_ptr),
        };

        global_state = state;

        // V6.1: Do NOT register atexit cleanup
        // Rationale: LD_PRELOAD libraries should not free memory on exit
        // The OS will clean up when the process terminates
        // Attempting cleanup causes use-after-free when Python's cleanup
        // tries to access our intercepted functions after we've freed our state
        //
        // _ = c.atexit(cleanupGlobalState);  // REMOVED in V6.1
    }
};

var init_once = std.once(InitOnce.do);

// V6.1: This function should NEVER be called in an LD_PRELOAD library
// Kept for reference only - cleanup on exit causes crashes
fn cleanupGlobalState() callconv(.c) void {
    // INTENTIONALLY LEFT EMPTY
    // Rationale: LD_PRELOAD libraries must not free memory on process exit
    // The OS will reclaim all memory when the process terminates
    // Attempting cleanup here causes use-after-free when the host process
    // (Python, bash, etc.) tries to call our intercepted functions during
    // its own cleanup sequence
}

fn getState() ?*GlobalState {
    init_once.call();
    return global_state;
}

// ============================================================
// V7.1: Process Detection Logic
// ============================================================

/// Get the current process name by reading /proc/self/comm
fn getCurrentProcessName(buffer: []u8) ?[]const u8 {
    const file = std.fs.openFileAbsolute("/proc/self/comm", .{}) catch return null;
    defer file.close();

    const bytes_read = file.read(buffer) catch return null;
    if (bytes_read == 0) return null;

    // Trim trailing newline
    var len = bytes_read;
    while (len > 0 and (buffer[len - 1] == '\n' or buffer[len - 1] == '\r')) {
        len -= 1;
    }

    return buffer[0..len];
}

/// V7.2: Check if the current process is exempt (trusted build tool)
fn isProcessExempt() bool {
    const state = getState() orelse return false;

    if (!state.config.process_exemptions.enabled) return false;

    var proc_name_buf: [256]u8 = undefined;
    const proc_name = getCurrentProcessName(&proc_name_buf) orelse return false;

    // Check if this process is in the exempt list
    for (state.config.process_exemptions.exempt_processes) |exempt_name| {
        if (std.mem.eql(u8, proc_name, exempt_name)) {
            return true;
        }
    }

    return false;
}

/// V7.1: Check if the current process is on the restricted list
fn getProcessRestrictions() ?*const config_mod.ProcessRestrictions {
    const state = getState() orelse return null;

    if (!state.config.process_restrictions.enabled) return null;

    var proc_name_buf: [256]u8 = undefined;
    const proc_name = getCurrentProcessName(&proc_name_buf) orelse return null;

    // Check if this process is in the restricted list
    for (state.config.process_restrictions.restricted_processes) |*restricted| {
        if (std.mem.eql(u8, proc_name, restricted.name)) {
            return &restricted.restrictions;
        }
    }

    return null;
}

/// V7.1: Check if a path is /tmp or a dotfile that should be monitored
fn isPathRestrictedForProcess(path: [*:0]const u8, restrictions: *const config_mod.ProcessRestrictions, is_write: bool) bool {
    const path_slice = std.mem.span(path);

    // Check /tmp restrictions
    if (is_write and restrictions.block_tmp_write) {
        if (std.mem.startsWith(u8, path_slice, "/tmp/")) {
            return true;
        }
    }

    // Check dotfile restrictions
    if (is_write and restrictions.block_dotfile_write) {
        // Extract filename from path
        const filename_start = if (std.mem.lastIndexOf(u8, path_slice, "/")) |idx| idx + 1 else 0;
        const filename = path_slice[filename_start..];

        // Check if it's in the monitored dotfiles list
        for (restrictions.monitored_dotfiles) |dotfile| {
            if (std.mem.eql(u8, filename, dotfile) or std.mem.endsWith(u8, path_slice, dotfile)) {
                return true;
            }
        }
    }

    return false;
}

// ============================================================
// Path Checking Logic (Config-Driven)
// ============================================================

/// Simple glob pattern matching for `**/.git` style patterns
fn matchesGlobPattern(path_slice: []const u8, pattern: []const u8) bool {
    // Handle `**/.git` pattern
    if (std.mem.startsWith(u8, pattern, "**/")) {
        const suffix = pattern[3..];
        // Check if path ends with the suffix or contains it as a directory component
        if (std.mem.endsWith(u8, path_slice, suffix)) return true;

        // Check for `/.git/` or `/.git` anywhere in path
        var search_pattern_buf: [256]u8 = undefined;
        const search_pattern = std.fmt.bufPrint(&search_pattern_buf, "/{s}", .{suffix}) catch return false;
        if (std.mem.indexOf(u8, path_slice, search_pattern)) |_| return true;
    }
    return false;
}

/// V7: Check if a path is a protected directory ITSELF (not files within it)
/// The Living Citadel Doctrine:
///   - Block: rmdir on /path/to/zig_forge or /path/to/.git
///   - Block: rename of /path/to/zig_forge or /path/to/.git
///   - Allow: unlink on /path/to/zig_forge/file.zig (file inside Citadel)
///   - Allow: unlink on /path/to/.git/index.lock (git's internal operations)
fn isProtectedDirectoryItself(path: [*:0]const u8) bool {
    const state = getState() orelse return false;

    if (!state.config.directory_protection.enabled) return false;

    const path_slice = std.mem.span(path);

    // Check if this path IS a protected root (exact match)
    for (state.config.directory_protection.protected_roots) |root| {
        if (std.mem.eql(u8, path_slice, root)) return true;
    }

    // Check if this path IS a .git directory (for pattern **/.git)
    for (state.config.directory_protection.protected_patterns) |pattern| {
        if (std.mem.eql(u8, pattern, "**/.git")) {
            // Check if path ends with "/.git" or is exactly ".git"
            if (std.mem.endsWith(u8, path_slice, "/.git")) return true;
            if (std.mem.eql(u8, path_slice, ".git")) return true;
        }
    }

    return false;
}

fn isWhitelisted(path: [*:0]const u8) bool {
    const state = getState() orelse return false;
    const path_slice = std.mem.span(path);

    for (state.config.whitelisted_paths) |whitelist| {
        if (std.mem.startsWith(u8, path_slice, whitelist.path)) {
            return true;
        }
    }
    return false;
}

fn isProtectedForOperation(path: [*:0]const u8, operation: []const u8) bool {
    const state = getState() orelse return false;

    // Check if globally disabled
    if (!state.config.global.enabled) return false;

    // Check environment override
    if (state.config.advanced.allow_env_override) {
        if (std.process.getEnvVarOwned(allocator, "LIBWARDEN_OVERRIDE")) |override_val| {
            defer allocator.free(override_val);
            if (std.mem.eql(u8, override_val, "1")) {
                return false;
            }
        } else |_| {}
    }

    // Whitelist takes precedence
    if (isWhitelisted(path)) return false;

    const path_slice = std.mem.span(path);

    // Check protected paths
    for (state.config.protected_paths) |protected| {
        if (std.mem.startsWith(u8, path_slice, protected.path)) {
            // Check if this operation is blocked for this path
            for (protected.block_operations) |blocked_op| {
                if (std.mem.eql(u8, blocked_op, operation)) {
                    return true;
                }
            }
        }
    }

    return false;
}

fn logBlock(operation: []const u8, path: [*:0]const u8) void {
    const state = getState() orelse {
        std.debug.print("[libwarden.so] 🛡️  BLOCKED {s}: {s}\n", .{ operation, path });
        return;
    };

    std.debug.print("[libwarden.so] {s} BLOCKED {s}: {s}\n", .{ state.config.global.block_emoji, operation, path });
}

// ============================================================
// Syscall Interceptors - unlink() family
// ============================================================

export fn unlink(path: [*:0]const u8) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools (bypass ALL checks for performance)
    if (isProcessExempt()) {
        return state.original_unlink(path);
    }

    // V7.1: Check process-specific restrictions FIRST
    if (getProcessRestrictions()) |restrictions| {
        if (isPathRestrictedForProcess(path, restrictions, true)) {
            logBlock("unlink [PROCESS-RESTRICTED]", path);
            __errno_location().* = 13;
            return -1;
        }
    }

    // V7: unlink operates on FILES, not directories
    // We don't check isProtectedDirectoryItself() here because:
    //   - unlink cannot remove directories (use rmdir for that)
    //   - We want to allow git to manage .git/index.lock and other internal files
    // Only check the operation-level protection

    if (isProtectedForOperation(path, "unlink")) {
        logBlock("unlink", path);
        __errno_location().* = 13; // EACCES
        return -1;
    }

    return state.original_unlink(path);
}

export fn unlinkat(dirfd: c_int, path: [*:0]const u8, flags: c_int) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        return state.original_unlinkat(dirfd, path, flags);
    }

    // V7.1: Check process-specific restrictions FIRST
    if (getProcessRestrictions()) |restrictions| {
        if (isPathRestrictedForProcess(path, restrictions, true)) {
            logBlock("unlinkat [PROCESS-RESTRICTED]", path);
            __errno_location().* = 13;
            return -1;
        }
    }

    // V7: unlinkat can remove files OR directories (with AT_REMOVEDIR flag)
    // Only check directory protection if this is a directory removal operation
    const AT_REMOVEDIR: c_int = 0x200;
    if ((flags & AT_REMOVEDIR) != 0) {
        // This is rmdir-equivalent, check if it's a protected directory
        if (isProtectedDirectoryItself(path)) {
            logBlock("unlinkat/rmdir (Citadel protected)", path);
            __errno_location().* = 13;
            return -1;
        }
    }

    if (isProtectedForOperation(path, "unlinkat")) {
        logBlock("unlinkat", path);
        __errno_location().* = 13;
        return -1;
    }

    return state.original_unlinkat(dirfd, path, flags);
}

export fn rmdir(path: [*:0]const u8) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        return state.original_rmdir(path);
    }

    // V7: rmdir operates on directories - THIS is where Living Citadel protection applies
    // Check if this is a protected directory itself
    if (isProtectedDirectoryItself(path)) {
        logBlock("rmdir (Citadel protected)", path);
        __errno_location().* = 13;
        return -1;
    }

    if (isProtectedForOperation(path, "rmdir")) {
        logBlock("rmdir", path);
        __errno_location().* = 13;
        return -1;
    }

    return state.original_rmdir(path);
}

// ============================================================
// Syscall Interceptors - open() family
// ============================================================

export fn open(path: [*:0]const u8, flags: c_int, ...) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        if ((flags & c.O_CREAT) != 0) {
            var args = @cVaStart();
            const mode = @cVaArg(&args, c_int);
            @cVaEnd(&args);
            return state.original_open(path, flags, mode);
        }
        return state.original_open(path, flags);
    }

    const is_write = (flags & c.O_WRONLY) != 0 or (flags & c.O_RDWR) != 0;

    // V7.1: Check process-specific restrictions FIRST (surgical, targeted)
    if (getProcessRestrictions()) |restrictions| {
        if (isPathRestrictedForProcess(path, restrictions, is_write)) {
            logBlock("open(write) [PROCESS-RESTRICTED]", path);
            __errno_location().* = 13;
            return -1;
        }
    }

    // V7.0: Check global protection rules
    if (is_write and isProtectedForOperation(path, "open_write")) {
        logBlock("open(write)", path);
        __errno_location().* = 13;
        return -1;
    }

    // Handle O_CREAT mode parameter if present
    if ((flags & c.O_CREAT) != 0) {
        var args = @cVaStart();
        const mode = @cVaArg(&args, c_int);
        @cVaEnd(&args);
        return state.original_open(path, flags, mode);
    }

    return state.original_open(path, flags);
}

export fn openat(dirfd: c_int, path: [*:0]const u8, flags: c_int, ...) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        if ((flags & c.O_CREAT) != 0) {
            var args = @cVaStart();
            const mode = @cVaArg(&args, c_int);
            @cVaEnd(&args);
            return state.original_openat(dirfd, path, flags, mode);
        }
        return state.original_openat(dirfd, path, flags);
    }

    const is_write = (flags & c.O_WRONLY) != 0 or (flags & c.O_RDWR) != 0;

    // V7.1: Check process-specific restrictions FIRST
    if (getProcessRestrictions()) |restrictions| {
        if (isPathRestrictedForProcess(path, restrictions, is_write)) {
            logBlock("openat(write) [PROCESS-RESTRICTED]", path);
            __errno_location().* = 13;
            return -1;
        }
    }

    // V7.0: Check global protection rules
    if (is_write and isProtectedForOperation(path, "open_write")) {
        logBlock("openat(write)", path);
        __errno_location().* = 13;
        return -1;
    }

    // Handle O_CREAT mode parameter if present
    if ((flags & c.O_CREAT) != 0) {
        var args = @cVaStart();
        const mode = @cVaArg(&args, c_int);
        @cVaEnd(&args);
        return state.original_openat(dirfd, path, flags, mode);
    }

    return state.original_openat(dirfd, path, flags);
}

// ============================================================
// Syscall Interceptors - rename() family
// ============================================================

export fn rename(oldpath: [*:0]const u8, newpath: [*:0]const u8) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        return state.original_rename(oldpath, newpath);
    }

    // V7.1: Check process-specific restrictions FIRST (for both paths)
    if (getProcessRestrictions()) |restrictions| {
        if (isPathRestrictedForProcess(oldpath, restrictions, true) or
            isPathRestrictedForProcess(newpath, restrictions, true)) {
            logBlock("rename [PROCESS-RESTRICTED]", oldpath);
            __errno_location().* = 13;
            return -1;
        }
    }

    // V7: rename can move/rename files OR directories
    // Check if we're trying to rename a protected directory itself
    if (isProtectedDirectoryItself(oldpath) or isProtectedDirectoryItself(newpath)) {
        logBlock("rename (Citadel protected)", oldpath);
        __errno_location().* = 13;
        return -1;
    }

    if (isProtectedForOperation(oldpath, "rename") or isProtectedForOperation(newpath, "rename")) {
        logBlock("rename", oldpath);
        __errno_location().* = 13;
        return -1;
    }

    return state.original_rename(oldpath, newpath);
}

export fn renameat(olddirfd: c_int, oldpath: [*:0]const u8, newdirfd: c_int, newpath: [*:0]const u8) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        return state.original_renameat(olddirfd, oldpath, newdirfd, newpath);
    }

    // V7.1: Check process-specific restrictions FIRST (for both paths)
    if (getProcessRestrictions()) |restrictions| {
        if (isPathRestrictedForProcess(oldpath, restrictions, true) or
            isPathRestrictedForProcess(newpath, restrictions, true)) {
            logBlock("renameat [PROCESS-RESTRICTED]", oldpath);
            __errno_location().* = 13;
            return -1;
        }
    }

    // V7: renameat can move/rename files OR directories
    // Check if we're trying to rename a protected directory itself
    if (isProtectedDirectoryItself(oldpath) or isProtectedDirectoryItself(newpath)) {
        logBlock("renameat (Citadel protected)", oldpath);
        __errno_location().* = 13;
        return -1;
    }

    if (isProtectedForOperation(oldpath, "rename") or isProtectedForOperation(newpath, "rename")) {
        logBlock("renameat", oldpath);
        __errno_location().* = 13;
        return -1;
    }

    return state.original_renameat(olddirfd, oldpath, newdirfd, newpath);
}

// ============================================================
// V7.1: Syscall Interceptors - chmod() (Ephemeral Execution Prevention)
// ============================================================

export fn chmod(path: [*:0]const u8, mode: c_int) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        return state.original_chmod(path, mode);
    }

    // V7.1: Check process-specific restrictions
    // chmod is used to make files executable, which is part of the Ephemeral Execution Attack
    if (getProcessRestrictions()) |restrictions| {
        // Treat chmod as a "write" operation for restriction purposes
        if (isPathRestrictedForProcess(path, restrictions, true)) {
            logBlock("chmod [PROCESS-RESTRICTED]", path);
            __errno_location().* = 13;
            return -1;
        }
    }

    return state.original_chmod(path, mode);
}

// ============================================================
// V7.1: Syscall Interceptors - execve() (Ephemeral Execution Prevention)
// ============================================================

export fn execve(path: [*:0]const u8, argv: [*:null]?[*:0]const u8, envp: [*:null]?[*:0]const u8) c_int {
    const state = getState() orelse {
        __errno_location().* = 2;
        return -1;
    };

    // V7.2: Exempt trusted build tools
    if (isProcessExempt()) {
        return state.original_execve(path, argv, envp);
    }

    // V7.1: THE CRITICAL DEFENSE - Block execution from /tmp for restricted processes
    if (getProcessRestrictions()) |restrictions| {
        if (restrictions.block_tmp_execute) {
            const path_slice = std.mem.span(path);
            if (std.mem.startsWith(u8, path_slice, "/tmp/")) {
                logBlock("execve(/tmp) [PROCESS-RESTRICTED]", path);
                __errno_location().* = 13; // EACCES
                return -1;
            }
        }
    }

    return state.original_execve(path, argv, envp);
}
