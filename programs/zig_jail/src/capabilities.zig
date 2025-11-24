// capabilities.zig - Linux capability management for zig-jail
// Purpose: Drop/grant process capabilities for fine-grained privilege control
//
// CRITICAL TIMING: Must be applied AFTER fork() and bind mounts, BEFORE seccomp filter

const std = @import("std");
const profile_mod = @import("profile.zig");
const CapabilityConfig = profile_mod.CapabilityConfig;

// ============================================================
// Linux Capability Constants (from linux/capability.h)
// ============================================================

pub const CAP_CHOWN: u32 = 0;
pub const CAP_DAC_OVERRIDE: u32 = 1;
pub const CAP_DAC_READ_SEARCH: u32 = 2;
pub const CAP_FOWNER: u32 = 3;
pub const CAP_FSETID: u32 = 4;
pub const CAP_KILL: u32 = 5;
pub const CAP_SETGID: u32 = 6;
pub const CAP_SETUID: u32 = 7;
pub const CAP_SETPCAP: u32 = 8;
pub const CAP_LINUX_IMMUTABLE: u32 = 9;
pub const CAP_NET_BIND_SERVICE: u32 = 10;
pub const CAP_NET_BROADCAST: u32 = 11;
pub const CAP_NET_ADMIN: u32 = 12;
pub const CAP_NET_RAW: u32 = 13;
pub const CAP_IPC_LOCK: u32 = 14;
pub const CAP_IPC_OWNER: u32 = 15;
pub const CAP_SYS_MODULE: u32 = 16;
pub const CAP_SYS_RAWIO: u32 = 17;
pub const CAP_SYS_CHROOT: u32 = 18;
pub const CAP_SYS_PTRACE: u32 = 19;
pub const CAP_SYS_PACCT: u32 = 20;
pub const CAP_SYS_ADMIN: u32 = 21;
pub const CAP_SYS_BOOT: u32 = 22;
pub const CAP_SYS_NICE: u32 = 23;
pub const CAP_SYS_RESOURCE: u32 = 24;
pub const CAP_SYS_TIME: u32 = 25;
pub const CAP_SYS_TTY_CONFIG: u32 = 26;
pub const CAP_MKNOD: u32 = 27;
pub const CAP_LEASE: u32 = 28;
pub const CAP_AUDIT_WRITE: u32 = 29;
pub const CAP_AUDIT_CONTROL: u32 = 30;
pub const CAP_SETFCAP: u32 = 31;
pub const CAP_MAC_OVERRIDE: u32 = 32;
pub const CAP_MAC_ADMIN: u32 = 33;
pub const CAP_SYSLOG: u32 = 34;
pub const CAP_WAKE_ALARM: u32 = 35;
pub const CAP_BLOCK_SUSPEND: u32 = 36;
pub const CAP_AUDIT_READ: u32 = 37;

// prctl() constants for capability management
const PR_CAP_AMBIENT: i32 = 47;
const PR_CAP_AMBIENT_RAISE: i32 = 2;
const PR_CAP_AMBIENT_CLEAR_ALL: i32 = 4;
const PR_CAP_AMBIENT_IS_SET: i32 = 1;

// ============================================================
// Capability Name to Constant Mapping
// ============================================================
//
// NOTE: CapabilityConfig struct is defined in profile.zig

pub fn capabilityNameToValue(name: []const u8) ?u32 {
    const capability_map = std.StaticStringMap(u32).initComptime(.{
        .{ "CAP_CHOWN", CAP_CHOWN },
        .{ "CAP_DAC_OVERRIDE", CAP_DAC_OVERRIDE },
        .{ "CAP_DAC_READ_SEARCH", CAP_DAC_READ_SEARCH },
        .{ "CAP_FOWNER", CAP_FOWNER },
        .{ "CAP_FSETID", CAP_FSETID },
        .{ "CAP_KILL", CAP_KILL },
        .{ "CAP_SETGID", CAP_SETGID },
        .{ "CAP_SETUID", CAP_SETUID },
        .{ "CAP_SETPCAP", CAP_SETPCAP },
        .{ "CAP_LINUX_IMMUTABLE", CAP_LINUX_IMMUTABLE },
        .{ "CAP_NET_BIND_SERVICE", CAP_NET_BIND_SERVICE },
        .{ "CAP_NET_BROADCAST", CAP_NET_BROADCAST },
        .{ "CAP_NET_ADMIN", CAP_NET_ADMIN },
        .{ "CAP_NET_RAW", CAP_NET_RAW },
        .{ "CAP_IPC_LOCK", CAP_IPC_LOCK },
        .{ "CAP_IPC_OWNER", CAP_IPC_OWNER },
        .{ "CAP_SYS_MODULE", CAP_SYS_MODULE },
        .{ "CAP_SYS_RAWIO", CAP_SYS_RAWIO },
        .{ "CAP_SYS_CHROOT", CAP_SYS_CHROOT },
        .{ "CAP_SYS_PTRACE", CAP_SYS_PTRACE },
        .{ "CAP_SYS_PACCT", CAP_SYS_PACCT },
        .{ "CAP_SYS_ADMIN", CAP_SYS_ADMIN },
        .{ "CAP_SYS_BOOT", CAP_SYS_BOOT },
        .{ "CAP_SYS_NICE", CAP_SYS_NICE },
        .{ "CAP_SYS_RESOURCE", CAP_SYS_RESOURCE },
        .{ "CAP_SYS_TIME", CAP_SYS_TIME },
        .{ "CAP_SYS_TTY_CONFIG", CAP_SYS_TTY_CONFIG },
        .{ "CAP_MKNOD", CAP_MKNOD },
        .{ "CAP_LEASE", CAP_LEASE },
        .{ "CAP_AUDIT_WRITE", CAP_AUDIT_WRITE },
        .{ "CAP_AUDIT_CONTROL", CAP_AUDIT_CONTROL },
        .{ "CAP_SETFCAP", CAP_SETFCAP },
        .{ "CAP_MAC_OVERRIDE", CAP_MAC_OVERRIDE },
        .{ "CAP_MAC_ADMIN", CAP_MAC_ADMIN },
        .{ "CAP_SYSLOG", CAP_SYSLOG },
        .{ "CAP_WAKE_ALARM", CAP_WAKE_ALARM },
        .{ "CAP_BLOCK_SUSPEND", CAP_BLOCK_SUSPEND },
        .{ "CAP_AUDIT_READ", CAP_AUDIT_READ },
    });

    return capability_map.get(name);
}

// ============================================================
// Capability Application (called in child process)
// ============================================================

/// Apply capability configuration to the current process
/// MUST be called in child process after fork() and before execve()
pub fn applyCapabilities(config: *const CapabilityConfig, allocator: std.mem.Allocator) !void {
    // Check if we're running with sufficient privileges or file capabilities
    const euid = std.os.linux.geteuid();
    if (euid != 0) {
        if (config.keep.len > 0) {
            std.debug.print("[zig-jail]   Running as non-root user (EUID: {d})\n", .{euid});
            std.debug.print("[zig-jail]   Attempting to use file capabilities (setcap)...\n", .{});
            // Continue - file capabilities (setcap) may allow us to manage caps even as non-root
            // If this fails, the prctl/capset syscalls will return errors below
        }
    }

    // Convert capability names to values
    var caps_to_keep = std.ArrayList(u32).empty;
    defer caps_to_keep.deinit(allocator);

    for (config.keep) |cap_name| {
        if (capabilityNameToValue(cap_name)) |cap_value| {
            try caps_to_keep.append(allocator, cap_value);
            std.debug.print("[zig-jail]   Granting capability: {s} ({d})\n", .{cap_name, cap_value});
        } else {
            std.debug.print("[zig-jail] ⚠️  Unknown capability: {s} (skipping)\n", .{cap_name});
        }
    }

    // Step 1: Check current capability sets
    // File capabilities are loaded at exec() time, so parent should have them
    // After fork(), child inherits them
    std.debug.print("[zig-jail]   DEBUG: Checking current capability sets...\n", .{});

    // Read current capabilities using /proc/self/status
    const status_file = std.fs.openFileAbsolute("/proc/self/status", .{}) catch |err| {
        std.debug.print("[zig-jail] ⚠️  Cannot read /proc/self/status: {}\n", .{err});
        return;
    };
    defer status_file.close();

    var buf: [4096]u8 = undefined;
    const bytes_read = status_file.read(&buf) catch 0;
    if (bytes_read > 0) {
        const status_content = buf[0..bytes_read];

        // Find CapPrm (permitted) and CapInh (inheritable) lines
        var lines = std.mem.splitScalar(u8, status_content, '\n');
        while (lines.next()) |line| {
            if (std.mem.startsWith(u8, line, "CapPrm:") or
                std.mem.startsWith(u8, line, "CapInh:") or
                std.mem.startsWith(u8, line, "CapEff:")) {
                std.debug.print("[zig-jail]   DEBUG: {s}\n", .{line});
            }
        }
    }

    // Step 2: Move capabilities from permitted to inheritable set
    // This is required before we can raise them to ambient
    // Build the capability bitmask for our caps
    var cap_mask: u64 = 0;
    for (caps_to_keep.items) |cap| {
        cap_mask |= (@as(u64, 1) << @intCast(cap));
    }

    std.debug.print("[zig-jail]   Setting inheritable capabilities (mask: 0x{x})\n", .{cap_mask});

    // Use capset() to set inheritable set = permitted set
    const cap_header = extern struct {
        version: u32,
        pid: i32,
    }{ .version = 0x20080522, .pid = 0 }; // LINUX_CAPABILITY_VERSION_3

    // First, get current caps
    var cap_data = [2]extern struct {
        effective: u32,
        permitted: u32,
        inheritable: u32,
    }{ .{ .effective = 0, .permitted = 0, .inheritable = 0 }, .{ .effective = 0, .permitted = 0, .inheritable = 0 } };

    const SYS_capget = std.os.linux.SYS.capget;
    _ = std.os.linux.syscall2(SYS_capget, @intFromPtr(&cap_header), @intFromPtr(&cap_data));

    // Now modify inheritable to match permitted
    cap_data[0].inheritable = cap_data[0].permitted;
    cap_data[1].inheritable = cap_data[1].permitted;

    const SYS_capset = std.os.linux.SYS.capset;
    const capset_result = std.os.linux.syscall2(SYS_capset, @intFromPtr(&cap_header), @intFromPtr(&cap_data));
    if (capset_result != 0) {
        // Convert syscall result to errno
        const errno_val = @as(u32, @intCast(-@as(i64, @bitCast(capset_result))));
        std.debug.print("[zig-jail] ⚠️  capset() failed to set inheritable: errno={d} (raw={d})\n", .{ errno_val, capset_result });
        std.debug.print("[zig-jail]      Common causes: insufficient privileges, invalid capability values\n", .{});
        return error.CapsetFailed;
    }

    // Step 3: Clear all ambient capabilities if requested
    if (config.drop_all) {
        std.debug.print("[zig-jail]   Dropping all ambient capabilities\n", .{});
        const result = std.os.linux.prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_CLEAR_ALL, 0, 0, 0);
        if (result != 0) {
            std.debug.print("[zig-jail] ⚠️  Failed to clear ambient capabilities: {d}\n", .{result});
            return error.CapabilityClearFailed;
        }
    }

    // Step 4: Raise specific ambient capabilities
    // Ambient capabilities are preserved across execve() for non-root processes
    for (caps_to_keep.items) |cap_value| {
        const result = std.os.linux.prctl(PR_CAP_AMBIENT, PR_CAP_AMBIENT_RAISE, cap_value, 0, 0);
        if (result != 0) {
            std.debug.print("[zig-jail] ⚠️  Failed to raise ambient capability {d}\n", .{cap_value});
            return error.CapabilityRaiseFailed;
        }
    }

    std.debug.print("[zig-jail] ✓ Capabilities configured successfully\n", .{});
}

// ============================================================
// NOTE: setCapabilitySets() removed - not needed with file capabilities
// File capabilities (setcap) handle permitted/effective/inheritable sets
// We only need prctl(PR_CAP_AMBIENT_RAISE) to make them ambient
// ============================================================
