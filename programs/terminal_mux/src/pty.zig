//! PTY (Pseudo-Terminal) Management
//!
//! Handles creation and management of pseudo-terminals on Linux.
//! Uses the Unix98 PTY interface (/dev/ptmx).

const std = @import("std");
const posix = std.posix;

/// Linux-specific ioctl constants for PTY operations
pub const pty_ioctl = struct {
    /// Get the PTY slave number
    pub const TIOCGPTN: u32 = 0x80045430; // _IOR('T', 0x30, unsigned int)
    /// Unlock the PTY slave
    pub const TIOCSPTLCK: u32 = 0x40045431; // _IOW('T', 0x31, int)
    /// Set controlling terminal
    pub const TIOCSCTTY: u32 = 0x540E;
    /// Give up controlling terminal
    pub const TIOCNOTTY: u32 = 0x5422;
    /// Get window size
    pub const TIOCGWINSZ: u32 = 0x5413;
    /// Set window size
    pub const TIOCSWINSZ: u32 = 0x5414;
};

/// Window size structure
pub const Winsize = extern struct {
    ws_row: u16,
    ws_col: u16,
    ws_xpixel: u16,
    ws_ypixel: u16,
};

/// PTY pair (master + slave)
pub const Pty = struct {
    master_fd: posix.fd_t,
    slave_fd: posix.fd_t,
    slave_path: [32]u8,
    slave_path_len: usize,
    child_pid: ?posix.pid_t,

    rows: u16,
    cols: u16,

    const Self = @This();

    /// Create a new PTY pair
    pub fn create() !Self {
        // Open the PTY master device
        const master_fd = try posix.open("/dev/ptmx", .{
            .ACCMODE = .RDWR,
            .NOCTTY = true,
        }, 0);
        errdefer posix.close(master_fd);

        // Unlock the slave
        var unlock: c_int = 0;
        _ = ioctl(master_fd, pty_ioctl.TIOCSPTLCK, &unlock) catch {
            return error.PtyUnlockFailed;
        };

        // Get the slave number
        var pts_num: c_uint = 0;
        _ = ioctl(master_fd, pty_ioctl.TIOCGPTN, &pts_num) catch {
            return error.PtyGetSlaveNumFailed;
        };

        // Construct slave path
        var slave_path: [32]u8 = undefined;
        const path_slice = std.fmt.bufPrint(&slave_path, "/dev/pts/{d}", .{pts_num}) catch {
            return error.PathTooLong;
        };
        const path_len = path_slice.len;

        // Open the slave device
        const slave_fd = try posix.open(slave_path[0..path_len :0], .{
            .ACCMODE = .RDWR,
            .NOCTTY = true,
        }, 0);
        errdefer posix.close(slave_fd);

        return Self{
            .master_fd = master_fd,
            .slave_fd = slave_fd,
            .slave_path = slave_path,
            .slave_path_len = path_len,
            .child_pid = null,
            .rows = 24,
            .cols = 80,
        };
    }

    /// Close the PTY
    pub fn close(self: *Self) void {
        if (self.child_pid) |pid| {
            // Try to kill the child process
            _ = posix.kill(pid, posix.SIG.TERM) catch {};
        }

        posix.close(self.slave_fd);
        posix.close(self.master_fd);
    }

    /// Get slave path as a slice
    pub fn getSlavePath(self: *const Self) []const u8 {
        return self.slave_path[0..self.slave_path_len];
    }

    /// Spawn a child process in the PTY
    pub fn spawn(self: *Self, argv: []const [*:0]const u8, envp: [*:null]const ?[*:0]const u8) !void {
        const pid = try posix.fork();

        if (pid == 0) {
            // Child process
            self.setupChild() catch {
                posix.exit(1);
            };

            // Execute the command using libc execvpe via execvpeZ
            // execvpeZ doesn't return on success
            posix.execvpeZ(argv[0], @ptrCast(argv.ptr), envp) catch {};
            // If we reach here, exec failed
            posix.exit(127);
        } else {
            // Parent process
            self.child_pid = pid;

            // Close slave fd in parent - we only use master
            posix.close(self.slave_fd);
            self.slave_fd = -1;
        }
    }

    /// Setup child process (called after fork in child)
    fn setupChild(self: *Self) !void {
        // Close master fd in child
        posix.close(self.master_fd);

        // Create a new session
        _ = try posix.setsid();

        // Set the slave as the controlling terminal
        _ = ioctl(self.slave_fd, pty_ioctl.TIOCSCTTY, @as(*const c_int, &0)) catch {
            return error.SetControllingTerminalFailed;
        };

        // Duplicate slave to stdin/stdout/stderr
        try posix.dup2(self.slave_fd, 0);
        try posix.dup2(self.slave_fd, 1);
        try posix.dup2(self.slave_fd, 2);

        // Close original slave fd if it's not 0, 1, or 2
        if (self.slave_fd > 2) {
            posix.close(self.slave_fd);
        }
    }

    /// Set the window size of the PTY
    pub fn setSize(self: *Self, rows: u16, cols: u16) !void {
        const ws = Winsize{
            .ws_row = rows,
            .ws_col = cols,
            .ws_xpixel = 0,
            .ws_ypixel = 0,
        };

        _ = try ioctl(self.master_fd, pty_ioctl.TIOCSWINSZ, &ws);

        self.rows = rows;
        self.cols = cols;

        // Send SIGWINCH to the child process group
        if (self.child_pid) |pid| {
            _ = posix.kill(-pid, posix.SIG.WINCH) catch {};
        }
    }

    /// Get the current window size
    pub fn getSize(self: *const Self) !Winsize {
        var ws: Winsize = undefined;
        _ = try ioctl(self.master_fd, pty_ioctl.TIOCGWINSZ, &ws);
        return ws;
    }

    /// Read data from the PTY master
    pub fn read(self: *Self, buf: []u8) !usize {
        return posix.read(self.master_fd, buf);
    }

    /// Write data to the PTY master (sends to shell)
    pub fn write(self: *Self, data: []const u8) !usize {
        return posix.write(self.master_fd, data);
    }

    /// Check if child process is still alive
    pub fn isAlive(self: *const Self) bool {
        if (self.child_pid) |pid| {
            var status: u32 = 0;
            const result = posix.waitpid(pid, &status, posix.W.NOHANG);
            return result.pid == 0; // Returns 0 if still running
        }
        return false;
    }

    /// Wait for child process to exit
    pub fn wait(self: *Self) !u32 {
        if (self.child_pid) |pid| {
            var status: u32 = 0;
            _ = posix.waitpid(pid, &status, 0);
            self.child_pid = null;
            return status;
        }
        return 0;
    }
};

/// Generic ioctl wrapper
fn ioctl(fd: posix.fd_t, request: u32, arg: anytype) !usize {
    const ArgType = @TypeOf(arg);
    const arg_ptr = switch (@typeInfo(ArgType)) {
        .pointer => @intFromPtr(arg),
        else => @compileError("ioctl arg must be a pointer"),
    };

    const rc = std.os.linux.syscall3(
        .ioctl,
        @as(usize, @bitCast(@as(isize, fd))),
        request,
        arg_ptr,
    );

    if (rc > std.math.maxInt(isize)) {
        const err: posix.E = @enumFromInt(@as(u16, @truncate(0 -% rc)));
        return posix.unexpectedErrno(err);
    }

    return rc;
}

/// Raw terminal mode utilities
pub const RawMode = struct {
    original: posix.termios,
    fd: posix.fd_t,

    const Self = @This();

    /// Enter raw mode on a terminal
    pub fn enter(fd: posix.fd_t) !Self {
        const original = try posix.tcgetattr(fd);

        var raw = original;

        // Input modes: no break, no CR to NL, no parity check, no strip char,
        // no start/stop output control
        raw.iflag.BRKINT = false;
        raw.iflag.ICRNL = false;
        raw.iflag.INPCK = false;
        raw.iflag.ISTRIP = false;
        raw.iflag.IXON = false;

        // Output modes: disable post processing
        raw.oflag.OPOST = false;

        // Control modes: set 8 bit chars
        raw.cflag.CSIZE = .CS8;

        // Local modes: echo off, canonical off, no extended functions,
        // no signal chars
        raw.lflag.ECHO = false;
        raw.lflag.ICANON = false;
        raw.lflag.IEXTEN = false;
        raw.lflag.ISIG = false;

        // Control chars: set read timeout
        raw.cc[@intFromEnum(posix.V.MIN)] = 0;
        raw.cc[@intFromEnum(posix.V.TIME)] = 1; // 100ms timeout

        try posix.tcsetattr(fd, .FLUSH, raw);

        return Self{
            .original = original,
            .fd = fd,
        };
    }

    /// Exit raw mode, restoring original terminal settings
    pub fn exit(self: *Self) void {
        posix.tcsetattr(self.fd, .FLUSH, self.original) catch {};
    }
};

/// Get the current terminal size
pub fn getTerminalSize(fd: posix.fd_t) !Winsize {
    var ws: Winsize = undefined;
    _ = try ioctl(fd, pty_ioctl.TIOCGWINSZ, &ws);
    return ws;
}

// =============================================================================
// Tests
// =============================================================================

test "pty create and close" {
    // This test requires /dev/ptmx to be available
    const pty = Pty.create() catch |err| {
        if (err == error.FileNotFound or err == error.AccessDenied) {
            // Skip test if /dev/ptmx not available (e.g., in container)
            return;
        }
        return err;
    };

    var pty_var = pty;
    defer pty_var.close();

    try std.testing.expect(pty_var.master_fd >= 0);
    try std.testing.expect(pty_var.slave_fd >= 0);
    try std.testing.expect(std.mem.startsWith(u8, pty_var.getSlavePath(), "/dev/pts/"));
}

test "winsize struct size" {
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(Winsize));
}
