const std = @import("std");
const json = std.json;
const fs = std.fs;
const mem = std.mem;
const posix = std.posix;
const time = std.time;
const time_compat = @import("time_compat.zig");

// Retry configuration
const RetryConfig = struct {
    max_attempts: u32 = 3,
    base_delay_ms: u64 = 1000,
    max_delay_ms: u64 = 30000,
};

// The Scribe's Mind: Configuration Structure
const Config = struct {
    repo_path: []const u8,
    remote_name: []const u8,
    branch_name: []const u8,
    chronos_stamp_path: []const u8,
    agent_id: []const u8,
    debounce_ms: u64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Handle --help before config load
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    for (args[1..]) |arg| {
        if (mem.eql(u8, arg, "--help") or mem.eql(u8, arg, "-h")) {
            const help_msg =
                \\duckcache-scribe - Automated git commit/push daemon
                \\
                \\Usage: duckcache-scribe [options]
                \\
                \\Options:
                \\  -h, --help    Show this help message
                \\
                \\Configuration:
                \\  Place duckcache-scribe-config.json or config.json in current directory.
                \\  Required fields: repo_path, remote_name, branch_name, chronos_stamp_path, agent_id
                \\
            ;
            _ = posix.write(posix.STDOUT_FILENO, help_msg) catch {};
            return;
        }
    }

    std.log.info("The Sovereign Scribe awakens.", .{});

    // 1. Load the Mind
    const config = try loadConfig(allocator);
    defer {
        allocator.free(config.repo_path);
        allocator.free(config.remote_name);
        allocator.free(config.branch_name);
        allocator.free(config.chronos_stamp_path);
        allocator.free(config.agent_id);
    }

    // Validate configuration
    try validateConfig(config);

    var last_push_time: i64 = 0;
    var commit_count: u32 = 0;

    // 2. The Eternal Loop
    while (true) {
        // 3. The Unwavering Vigil (inotify)
        try watchForChanges(config.repo_path);
        std.log.info("A new memory has been transcribed. The Scribe takes note.", .{});

        // 4. The Debounce: Prevent a storm of commits
        const now = time_compat.timestamp();
        const debounce_seconds: i64 = @intCast(config.debounce_ms / 1000);
        if (now - last_push_time < debounce_seconds) {
            std.log.info("Patience. The ink is not yet dry.", .{});
            continue;
        }

        // 5. The Sacred Rite of Committal
        performGitCommit(allocator, config) catch |err| {
            std.log.err("Failed to commit changes: {s}", .{@errorName(err)});
            continue; // Don't crash on commit failures
        };
        commit_count += 1;

        // 6. The Chain Preservation: Push every 5 commits to preserve the chain
        if (commit_count >= 5) {
            std.log.info("The chain grows long. Preserving the Chronicle with a push.", .{});
            performGitPush(allocator, config) catch |err| {
                std.log.err("Failed to push changes: {s}", .{@errorName(err)});
                // Don't reset commit_count on push failure - we'll retry next time
                continue;
            };
            commit_count = 0;
            last_push_time = time_compat.timestamp();
        }
    }
}

fn watchForChanges(repo_path: []const u8) !void {
    const inotify_fd = try posix.inotify_init1(0);
    defer posix.close(inotify_fd);

    // Watch the entire repository for changes, not just the entries directory
    const IN_CLOSE_WRITE = 0x00000008;
    const IN_MODIFY = 0x00000002;
    const IN_CREATE = 0x00000100;
    const IN_DELETE = 0x00000200;
    const IN_MOVED_FROM = 0x00000400;
    const IN_MOVED_TO = 0x00000800;

    const watch_mask = IN_CLOSE_WRITE | IN_MODIFY | IN_CREATE | IN_DELETE | IN_MOVED_FROM | IN_MOVED_TO;
    _ = try posix.inotify_add_watch(inotify_fd, repo_path, watch_mask);

    // This will block until an event occurs. The heart of our efficiency.
    var event_buf: [1024]u8 = undefined;
    _ = try posix.read(inotify_fd, &event_buf);
}

fn performGitCommit(allocator: mem.Allocator, config: Config) !void {
    std.log.info("Committing the new scripture to the Immutable Chronicle.", .{});

    // Invoke chronos-stamp to get the 4th-dimensional timestamp
    const commit_message = try executeChronosStamp(allocator, config);
    defer allocator.free(commit_message);

    std.log.info("Chronicle signature: {s}", .{commit_message});

    // Stage and commit changes in the target repository with retry
    const retry_config = RetryConfig{ .max_attempts = 3, .base_delay_ms = 1000, .max_delay_ms = 10000 };
    try executeCommandWithRetry(allocator, config.repo_path, &.{ "git", "add", "." }, retry_config);
    try executeCommandWithRetry(allocator, config.repo_path, &.{ "git", "commit", "-m", commit_message }, retry_config);

    std.log.info("The Chronicle entry is committed locally.", .{});
}

fn performGitPush(allocator: mem.Allocator, config: Config) !void {
    std.log.info("Pushing the Chronicle to the remote repository.", .{});

    // Push to remote repository with retry
    const retry_config = RetryConfig{ .max_attempts = 5, .base_delay_ms = 2000, .max_delay_ms = 30000 };
    try executeCommandWithRetry(allocator, config.repo_path, &.{ "git", "push", config.remote_name, config.branch_name }, retry_config);

    std.log.info("The Chronicle is updated in the remote repository.", .{});
}

fn executeChronosStamp(allocator: mem.Allocator, config: Config) ![]u8 {
    // Call chronos-stamp to get the 4th-dimensional timestamp
    // NOTE: chronos-stamp writes its output to stderr, not stdout
    var child = std.process.Child.init(&.{ config.chronos_stamp_path, config.agent_id, "git-commit" }, allocator);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Pipe;

    try child.spawn();

    // Read the chronos-stamp output from stderr
    var stderr_list = std.ArrayList(u8).empty;
    defer stderr_list.deinit(allocator);

    var buffer: [512]u8 = undefined;
    while (true) {
        const n = try child.stderr.?.read(&buffer);
        if (n == 0) break;
        try stderr_list.appendSlice(allocator, buffer[0..n]);
    }

    // Wait for the process to finish
    const term = try child.wait();

    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                std.log.err("chronos-stamp failed with exit code: {d}", .{code});
                return error.ChronosStampFailed;
            }
        },
        else => {
            return error.ChronosStampFailed;
        },
    }

    // Filter out libwarden output and extract only the CHRONOS line
    const full_output = stderr_list.items;
    var lines = mem.splitScalar(u8, full_output, '\n');

    while (lines.next()) |line| {
        const trimmed_line = mem.trim(u8, line, &std.ascii.whitespace);
        if (mem.startsWith(u8, trimmed_line, "[CHRONOS]")) {
            return try allocator.dupe(u8, trimmed_line);
        }
    }

    // If no CHRONOS line found, return error
    std.log.err("No CHRONOS output found from chronos-stamp", .{});
    return error.ChronosStampFailed;
}

fn executeCommand(allocator: mem.Allocator, cwd: []const u8, args: []const []const u8) !void {
    var child = std.process.Child.init(args, allocator);
    child.cwd = cwd;
    const term = try child.spawnAndWait();

    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                std.log.err("Command failed with exit code: {d}", .{code});
                std.log.err("Command was: {s}", .{args[0]});
                return error.CommandFailed;
            }
        },
        else => {
            std.log.err("Command terminated abnormally", .{});
            return error.CommandFailed;
        },
    }
}

fn executeCommandWithRetry(allocator: mem.Allocator, cwd: []const u8, args: []const []const u8, retry_config: RetryConfig) !void {
    var attempt: u32 = 0;
    var delay_ms: u64 = retry_config.base_delay_ms;

    while (attempt < retry_config.max_attempts) : (attempt += 1) {
        if (attempt > 0) {
            std.log.info("Retry attempt {d}/{d} for command: {s}", .{attempt + 1, retry_config.max_attempts, args[0]});
            std.log.info("Waiting {d}ms before retry...", .{delay_ms});
            std.posix.nanosleep(0, delay_ms * std.time.ns_per_ms);

            // Exponential backoff with jitter
            delay_ms = @min(delay_ms * 2, retry_config.max_delay_ms);
        }

        var child = std.process.Child.init(args, allocator);
        child.cwd = cwd;
        const term = child.spawnAndWait() catch |err| {
            std.log.err("Failed to execute command on attempt {d}: {s}", .{attempt + 1, @errorName(err)});
            continue;
        };

        switch (term) {
            .Exited => |code| {
                if (code == 0) {
                    return; // Success!
                }
                std.log.err("Command failed with exit code: {d} on attempt {d}", .{code, attempt + 1});
            },
            else => {
                std.log.err("Command terminated abnormally on attempt {d}", .{attempt + 1});
            },
        }
    }

    std.log.err("All {d} attempts failed for command: {s}", .{retry_config.max_attempts, args[0]});
    return error.AllRetriesFailed;
}

fn loadConfig(allocator: mem.Allocator) !Config {
    // Try to open config files in current directory
    const config_paths = [_][]const u8{
        "duckcache-scribe-config.json",
        "config.json",
    };

    var config_file: ?fs.File = null;
    var used_path: []const u8 = undefined;

    for (config_paths) |path| {
        if (fs.cwd().openFile(path, .{})) |file| {
            config_file = file;
            used_path = path;
            break;
        } else |_| {
            continue;
        }
    }

    const file = config_file orelse {
        std.log.err("No configuration file found. Tried: duckcache-scribe-config.json, config.json", .{});
        return error.ConfigNotFound;
    };
    defer file.close();

    std.log.info("Using configuration file: {s}", .{used_path});

    // Read file contents (Zig 0.16 compatible)
    const stat = try file.stat();
    const contents = try allocator.alloc(u8, @intCast(stat.size));
    defer allocator.free(contents);
    const bytes_read = try file.read(contents);
    const file_contents = contents[0..bytes_read];

    // Parse JSON
    const parsed = try json.parseFromSlice(
        json.Value,
        allocator,
        file_contents,
        .{}
    );
    defer parsed.deinit();

    const root = parsed.value.object;

    // Extract fields and duplicate strings
    const repo_path = try allocator.dupe(u8, root.get("repo_path").?.string);
    const remote_name = try allocator.dupe(u8, root.get("remote_name").?.string);
    const branch_name = try allocator.dupe(u8, root.get("branch_name").?.string);
    const chronos_stamp_path = try allocator.dupe(u8, root.get("chronos_stamp_path").?.string);
    const agent_id = try allocator.dupe(u8, root.get("agent_id").?.string);
    const debounce_ms: u64 = @intCast(root.get("debounce_ms").?.integer);

    return Config{
        .repo_path = repo_path,
        .remote_name = remote_name,
        .branch_name = branch_name,
        .chronos_stamp_path = chronos_stamp_path,
        .agent_id = agent_id,
        .debounce_ms = debounce_ms,
    };
}

fn validateConfig(config: Config) !void {
    std.log.info("Validating configuration...", .{});

    // Check if repository path exists and is a git repository
    var repo_dir = fs.cwd().openDir(config.repo_path, .{}) catch |err| {
        std.log.err("Repository path does not exist or is not accessible: {s}", .{config.repo_path});
        std.log.err("Error: {s}", .{@errorName(err)});
        return error.InvalidRepoPath;
    };
    defer repo_dir.close();

    // Check if .git directory exists
    _ = repo_dir.openDir(".git", .{}) catch |err| {
        std.log.err("Repository path is not a git repository: {s}", .{config.repo_path});
        std.log.err("Error: {s}", .{@errorName(err)});
        return error.NotGitRepository;
    };

    // Check if chronos-stamp executable exists and is executable
    fs.accessAbsolute(config.chronos_stamp_path, .{}) catch |err| {
        std.log.err("chronos-stamp executable not found or not accessible: {s}", .{config.chronos_stamp_path});
        std.log.err("Error: {s}", .{@errorName(err)});
        return error.ChronosStampNotFound;
    };

    // Validate debounce time is reasonable
    if (config.debounce_ms < 1000) {
        std.log.warn("Debounce time is very short ({d}ms), may cause excessive commits", .{config.debounce_ms});
    }
    if (config.debounce_ms > 60000) {
        std.log.warn("Debounce time is very long ({d}ms), may miss rapid changes", .{config.debounce_ms});
    }

    std.log.info("Configuration validation passed.", .{});
}
