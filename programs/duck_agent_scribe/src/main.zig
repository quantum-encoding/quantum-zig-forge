const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const time = std.time;

const VERSION = "0.1.0";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try printUsage();
        return;
    }

    const command = args[1];

    if (mem.eql(u8, command, "init")) {
        try handleInit(allocator, args);
    } else if (mem.eql(u8, command, "log")) {
        try handleLog(allocator, args);
    } else if (mem.eql(u8, command, "complete")) {
        try handleComplete(allocator, args);
    } else if (mem.eql(u8, command, "batch-complete")) {
        try handleBatchComplete(allocator, args);
    } else if (mem.eql(u8, command, "query")) {
        try handleQuery(allocator, args);
    } else if (mem.eql(u8, command, "lineage")) {
        try handleLineage(allocator, args);
    } else if (mem.eql(u8, command, "version")) {
        std.debug.print("duck-agent-scribe v{s}\n", .{VERSION});
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
        try printUsage();
    }
}

fn printUsage() !void {
    std.debug.print(
        \\duck-agent-scribe - Eternal accountability for spawned agents
        \\
        \\USAGE:
        \\  duckagent-scribe <COMMAND> [OPTIONS]
        \\
        \\COMMANDS:
        \\  init              Initialize eternal log for new agent
        \\  log               Log agent turn/action
        \\  complete          Mark agent completion
        \\  batch-complete    Finalize batch manifest
        \\  query             Query agent logs
        \\  lineage           Show retry lineage for agent
        \\  version           Print version
        \\
        \\INIT OPTIONS:
        \\  --agent-id <ID>        Agent ID (e.g., 001)
        \\  --batch-id <ID>        Batch ID
        \\  --task <DESCRIPTION>   Task description
        \\  --provider <NAME>      Provider (grok/claude)
        \\  --max-turns <N>        Maximum turns
        \\  --output-file <PATH>   Expected output file
        \\  --retry-number <N>     Retry attempt (0 for first)
        \\  --crucible-path <PATH> Crucible workspace path
        \\  --pid <PID>            Process ID
        \\
        \\COMPLETE OPTIONS:
        \\  --agent-id <ID>        Agent ID
        \\  --batch-id <ID>        Batch ID
        \\  --status <STATUS>      SUCCESS or FAILED
        \\  --turns-taken <N>      Actual turns taken
        \\  --tokens-used <N>      Tokens consumed
        \\  --result-path <PATH>   Result JSON path
        \\
        \\EXAMPLES:
        \\  duckagent-scribe init --agent-id 001 --batch-id batch-20251024-140812 \
        \\    --task "Write blog post" --provider grok --max-turns 50 \
        \\    --retry-number 0 --crucible-path /home/founder/crucible/grok-... --pid 12345
        \\
        \\  duckagent-scribe complete --agent-id 001 --batch-id batch-20251024-140812 \
        \\    --status SUCCESS --turns-taken 1 --tokens-used 3986
        \\
        \\  duckagent-scribe query --batch-id batch-20251024-140812 --status FAILED
        \\
    , .{});
}

fn handleInit(allocator: mem.Allocator, args: []const []const u8) !void {
    var agent_id: ?[]const u8 = null;
    var batch_id: ?[]const u8 = null;
    var task: ?[]const u8 = null;
    var provider: []const u8 = "grok";
    var max_turns: u32 = 50;
    var output_file: ?[]const u8 = null;
    var retry_number: u32 = 0;
    var crucible_path: ?[]const u8 = null;
    var pid: ?u32 = null;

    // Parse arguments
    var i: usize = 2;
    while (i < args.len) : (i += 2) {
        if (i + 1 >= args.len) break;

        if (mem.eql(u8, args[i], "--agent-id")) {
            agent_id = args[i + 1];
        } else if (mem.eql(u8, args[i], "--batch-id")) {
            batch_id = args[i + 1];
        } else if (mem.eql(u8, args[i], "--task")) {
            task = args[i + 1];
        } else if (mem.eql(u8, args[i], "--provider")) {
            provider = args[i + 1];
        } else if (mem.eql(u8, args[i], "--max-turns")) {
            max_turns = try std.fmt.parseInt(u32, args[i + 1], 10);
        } else if (mem.eql(u8, args[i], "--output-file")) {
            output_file = args[i + 1];
        } else if (mem.eql(u8, args[i], "--retry-number")) {
            retry_number = try std.fmt.parseInt(u32, args[i + 1], 10);
        } else if (mem.eql(u8, args[i], "--crucible-path")) {
            crucible_path = args[i + 1];
        } else if (mem.eql(u8, args[i], "--pid")) {
            pid = try std.fmt.parseInt(u32, args[i + 1], 10);
        }
    }

    if (agent_id == null or batch_id == null or task == null) {
        std.debug.print("Error: --agent-id, --batch-id, and --task are required\n", .{});
        return error.MissingArguments;
    }

    // Get chronos tick and timestamp
    const tick = try getChronosTick(allocator);
    defer allocator.free(tick);

    const timestamp = try getChronosTimestamp(allocator);
    defer allocator.free(timestamp);

    // Create log directory
    const home = std.posix.getenv("HOME") orelse return error.HomeNotSet;

    const retry_suffix = if (retry_number > 0)
        try std.fmt.allocPrint(allocator, "-RETRY-{d}", .{retry_number})
    else
        try allocator.dupe(u8, "");
    defer allocator.free(retry_suffix);

    const log_dir = try std.fmt.allocPrint(
        allocator,
        "{s}/eternal-logs/agents-crucible/{s}/agent-{s}-{s}{s}",
        .{ home, batch_id.?, agent_id.?, tick, retry_suffix },
    );
    defer allocator.free(log_dir);

    // Create parent directories recursively
    const eternal_logs_path = try std.fmt.allocPrint(allocator, "{s}/eternal-logs", .{home});
    defer allocator.free(eternal_logs_path);
    fs.makeDirAbsolute(eternal_logs_path) catch {};

    const agents_crucible_path = try std.fmt.allocPrint(allocator, "{s}/eternal-logs/agents-crucible", .{home});
    defer allocator.free(agents_crucible_path);
    fs.makeDirAbsolute(agents_crucible_path) catch {};

    const batch_dir_path = try std.fmt.allocPrint(
        allocator,
        "{s}/eternal-logs/agents-crucible/{s}",
        .{ home, batch_id.? },
    );
    defer allocator.free(batch_dir_path);
    fs.makeDirAbsolute(batch_dir_path) catch {};

    try fs.makeDirAbsolute(log_dir);

    // Create manifest.json
    const manifest_path = try std.fmt.allocPrint(allocator, "{s}/manifest.json", .{log_dir});
    defer allocator.free(manifest_path);

    const manifest = try std.fmt.allocPrint(
        allocator,
        \\{{
        \\  "agent": {{
        \\    "id": "{s}",
        \\    "chronos_tick": "{s}",
        \\    "timestamp_iso": "{s}",
        \\    "provider": "{s}"
        \\  }},
        \\  "batch": {{
        \\    "id": "{s}",
        \\    "is_retry": {s},
        \\    "retry_number": {d}
        \\  }},
        \\  "task": {{
        \\    "description": "{s}",
        \\    "max_turns": {d},
        \\    "output_file": "{s}"
        \\  }},
        \\  "crucible": {{
        \\    "path": "{s}"
        \\  }},
        \\  "execution": {{
        \\    "pid": {?d},
        \\    "started_at": "{s}",
        \\    "status": "RUNNING"
        \\  }}
        \\}}
        \\
    ,
        .{
            agent_id.?,
            tick,
            timestamp,
            provider,
            batch_id.?,
            if (retry_number > 0) "true" else "false",
            retry_number,
            task.?,
            max_turns,
            output_file orelse "",
            crucible_path orelse "",
            pid,
            timestamp,
        },
    );
    defer allocator.free(manifest);

    try writeFile(manifest_path, manifest);

    // Create init.log
    const init_log_path = try std.fmt.allocPrint(allocator, "{s}/init.log", .{log_dir});
    defer allocator.free(init_log_path);

    const init_log = try std.fmt.allocPrint(
        allocator,
        "[{s}] Agent {s} initialized{s}\nTask: {s}\nProvider: {s}\nCrucible: {s}\nPID: {?d}\n",
        .{
            timestamp,
            agent_id.?,
            if (retry_number > 0) try std.fmt.allocPrint(allocator, " (RETRY-{d})", .{retry_number}) else "",
            task.?,
            provider,
            crucible_path orelse "N/A",
            pid,
        },
    );
    defer allocator.free(init_log);

    try writeFile(init_log_path, init_log);

    std.debug.print("✅ Agent log initialized: {s}\n", .{log_dir});
}

fn handleLog(allocator: mem.Allocator, args: []const []const u8) !void {
    var agent_id: ?[]const u8 = null;
    var batch_id: ?[]const u8 = null;
    var turn: u32 = 0;
    var message: ?[]const u8 = null;

    // Parse arguments
    var i: usize = 2;
    while (i < args.len) : (i += 2) {
        if (i + 1 >= args.len) break;

        if (mem.eql(u8, args[i], "--agent-id")) {
            agent_id = args[i + 1];
        } else if (mem.eql(u8, args[i], "--batch-id")) {
            batch_id = args[i + 1];
        } else if (mem.eql(u8, args[i], "--turn")) {
            turn = try std.fmt.parseInt(u32, args[i + 1], 10);
        } else if (mem.eql(u8, args[i], "--message")) {
            message = args[i + 1];
        }
    }

    if (agent_id == null or batch_id == null or message == null) {
        std.debug.print("Error: --agent-id, --batch-id, and --message are required\n", .{});
        return error.MissingArguments;
    }

    // Find agent log directory (latest one for this agent/batch)
    const log_dir = try findAgentLogDir(allocator, batch_id.?, agent_id.?);
    defer allocator.free(log_dir);

    const turn_log_path = try std.fmt.allocPrint(allocator, "{s}/turn-{d:0>3}.log", .{ log_dir, turn });
    defer allocator.free(turn_log_path);

    const timestamp = try getChronosTimestamp(allocator);
    defer allocator.free(timestamp);

    const turn_log = try std.fmt.allocPrint(
        allocator,
        "[{s}] Turn {d}: {s}\n",
        .{ timestamp, turn, message.? },
    );
    defer allocator.free(turn_log);

    try appendFile(turn_log_path, turn_log);
    std.debug.print("📝 Logged turn {d} for agent {s}\n", .{ turn, agent_id.? });
}

fn handleComplete(allocator: mem.Allocator, args: []const []const u8) !void {
    var agent_id: ?[]const u8 = null;
    var batch_id: ?[]const u8 = null;
    var status: []const u8 = "SUCCESS";
    var turns_taken: u32 = 0;
    var tokens_used: u32 = 0;
    var result_path: ?[]const u8 = null;

    // Parse arguments
    var i: usize = 2;
    while (i < args.len) : (i += 2) {
        if (i + 1 >= args.len) break;

        if (mem.eql(u8, args[i], "--agent-id")) {
            agent_id = args[i + 1];
        } else if (mem.eql(u8, args[i], "--batch-id")) {
            batch_id = args[i + 1];
        } else if (mem.eql(u8, args[i], "--status")) {
            status = args[i + 1];
        } else if (mem.eql(u8, args[i], "--turns-taken")) {
            turns_taken = try std.fmt.parseInt(u32, args[i + 1], 10);
        } else if (mem.eql(u8, args[i], "--tokens-used")) {
            tokens_used = try std.fmt.parseInt(u32, args[i + 1], 10);
        } else if (mem.eql(u8, args[i], "--result-path")) {
            result_path = args[i + 1];
        }
    }

    if (agent_id == null or batch_id == null) {
        std.debug.print("Error: --agent-id and --batch-id are required\n", .{});
        return error.MissingArguments;
    }

    // Find agent log directory
    const log_dir = try findAgentLogDir(allocator, batch_id.?, agent_id.?);
    defer allocator.free(log_dir);

    // Write result.log
    const result_log_path = try std.fmt.allocPrint(allocator, "{s}/result.log", .{log_dir});
    defer allocator.free(result_log_path);

    const timestamp = try getChronosTimestamp(allocator);
    defer allocator.free(timestamp);

    const result_log = try std.fmt.allocPrint(
        allocator,
        \\[{s}] Agent {s} completed
        \\Status: {s}
        \\Turns taken: {d}
        \\Tokens used: {d}
        \\Result path: {s}
        \\
    ,
        .{
            timestamp,
            agent_id.?,
            status,
            turns_taken,
            tokens_used,
            result_path orelse "N/A",
        },
    );
    defer allocator.free(result_log);

    try writeFile(result_log_path, result_log);

    // Update manifest.json with final status
    const manifest_path = try std.fmt.allocPrint(allocator, "{s}/manifest.json", .{log_dir});
    defer allocator.free(manifest_path);

    // Read existing manifest
    const manifest_content = try readFile(allocator, manifest_path);
    defer allocator.free(manifest_content);

    // Parse JSON
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, manifest_content, .{});
    defer parsed.deinit();

    // Update execution.status field
    if (parsed.value.object.getPtr("execution")) |execution_ptr| {
        if (execution_ptr.* == .object) {
            try execution_ptr.object.put("status", std.json.Value{ .string = status });
            try execution_ptr.object.put("completed_at", std.json.Value{ .string = timestamp });
        }
    }

    // Write updated manifest back
    var out: std.Io.Writer.Allocating = .init(allocator);
    defer out.deinit();
    var stringify: std.json.Stringify = .{
        .writer = &out.writer,
        .options = .{ .whitespace = .indent_2 },
    };
    try stringify.write(parsed.value);
    try writeFile(manifest_path, out.written());

    const status_marker = mem.eql(u8, status, "SUCCESS");
    std.debug.print("{s} Agent {s} marked as {s} in manifest.json\n", .{
        if (status_marker) "✅" else "❌",
        agent_id.?,
        status,
    });
}

fn handleBatchComplete(allocator: mem.Allocator, args: []const []const u8) !void {
    var batch_id: ?[]const u8 = null;
    var total: u32 = 0;
    var succeeded: u32 = 0;
    var failed: u32 = 0;

    // Parse arguments
    var i: usize = 2;
    while (i < args.len) : (i += 2) {
        if (i + 1 >= args.len) break;

        if (mem.eql(u8, args[i], "--batch-id")) {
            batch_id = args[i + 1];
        } else if (mem.eql(u8, args[i], "--total")) {
            total = try std.fmt.parseInt(u32, args[i + 1], 10);
        } else if (mem.eql(u8, args[i], "--succeeded")) {
            succeeded = try std.fmt.parseInt(u32, args[i + 1], 10);
        } else if (mem.eql(u8, args[i], "--failed")) {
            failed = try std.fmt.parseInt(u32, args[i + 1], 10);
        }
    }

    if (batch_id == null) {
        std.debug.print("Error: --batch-id is required\n", .{});
        return error.MissingArguments;
    }

    const home = std.posix.getenv("HOME") orelse return error.HomeNotSet;
    const batch_dir = try std.fmt.allocPrint(
        allocator,
        "{s}/eternal-logs/agents-crucible/{s}",
        .{ home, batch_id.? },
    );
    defer allocator.free(batch_dir);

    const manifest_path = try std.fmt.allocPrint(allocator, "{s}/manifest.json", .{batch_dir});
    defer allocator.free(manifest_path);

    const timestamp = try getChronosTimestamp(allocator);
    defer allocator.free(timestamp);

    const success_rate = if (total > 0)
        @as(f64, @floatFromInt(succeeded)) / @as(f64, @floatFromInt(total))
    else
        0.0;

    const manifest = try std.fmt.allocPrint(
        allocator,
        \\{{
        \\  "batch": {{
        \\    "id": "{s}",
        \\    "completed_at": "{s}"
        \\  }},
        \\  "results": {{
        \\    "total_agents": {d},
        \\    "succeeded": {d},
        \\    "failed": {d},
        \\    "success_rate": {d:.2}
        \\  }}
        \\}}
        \\
    ,
        .{ batch_id.?, timestamp, total, succeeded, failed, success_rate },
    );
    defer allocator.free(manifest);

    try writeFile(manifest_path, manifest);
    std.debug.print("📊 Batch manifest completed: {s}\n", .{batch_id.?});
}

fn handleQuery(allocator: mem.Allocator, args: []const []const u8) !void {
    _ = allocator;
    _ = args;
    std.debug.print("🔍 Query feature coming soon...\n", .{});
}

fn handleLineage(allocator: mem.Allocator, args: []const []const u8) !void {
    _ = allocator;
    _ = args;
    std.debug.print("📜 Lineage feature coming soon...\n", .{});
}

// Helper functions

fn getChronosTick(allocator: mem.Allocator) ![]u8 {
    // Zig 0.16: Use std.posix.clock_gettime for wall clock time
    const ts = try std.posix.clock_gettime(std.posix.CLOCK.REALTIME);
    const now = @as(i128, ts.sec) * std.time.ns_per_s + ts.nsec;
    const tick_num = @abs(@mod(now, 10000000000));
    return try std.fmt.allocPrint(allocator, "TICK-{d:0>10}", .{tick_num});
}

fn getChronosTimestamp(allocator: mem.Allocator) ![]u8 {
    // Zig 0.16: Use std.posix.clock_gettime for wall clock time
    const ts = try std.posix.clock_gettime(std.posix.CLOCK.REALTIME);
    const timestamp_ms = @divFloor(ts.sec * 1000 + @divFloor(ts.nsec, std.time.ns_per_ms), 1);
    const seconds = @divFloor(timestamp_ms, 1000);
    const millis = @mod(timestamp_ms, 1000);

    // Calculate days since Unix epoch
    const days_since_epoch = @divFloor(seconds, 86400);
    const day_seconds = @mod(seconds, 86400);

    const hours = @divFloor(day_seconds, 3600);
    const minutes = @divFloor(@mod(day_seconds, 3600), 60);
    const secs = @mod(day_seconds, 60);

    // Calculate year, month, day from days_since_epoch
    // Simplified calculation (assumes 365.25 days per year)
    const epoch_year: i64 = 1970;
    const approx_year = epoch_year + @divFloor(days_since_epoch * 4, 1461);
    const year_start_day = @divFloor((approx_year - epoch_year) * 1461, 4);
    const day_of_year = days_since_epoch - year_start_day;

    // Simplified month/day (good enough for logging)
    const month = @min(12, @divFloor(day_of_year * 12, 365) + 1);
    const day = @min(31, @mod(day_of_year, 31) + 1);

    return try std.fmt.allocPrint(
        allocator,
        "{d:0>4}-{d:0>2}-{d:0>2}T{d:0>2}:{d:0>2}:{d:0>2}.{d:0>9}Z",
        .{ approx_year, month, day, hours, minutes, secs, millis * 1000000 },
    );
}

fn findAgentLogDir(allocator: mem.Allocator, batch_id: []const u8, agent_id: []const u8) ![]u8 {
    const home = std.posix.getenv("HOME") orelse return error.HomeNotSet;
    const batch_dir = try std.fmt.allocPrint(
        allocator,
        "{s}/eternal-logs/agents-crucible/{s}",
        .{ home, batch_id },
    );
    defer allocator.free(batch_dir);

    // Find directory matching agent-{agent_id}-*
    var dir = try fs.openDirAbsolute(batch_dir, .{ .iterate = true });
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .directory) {
            const prefix = try std.fmt.allocPrint(allocator, "agent-{s}-", .{agent_id});
            defer allocator.free(prefix);

            if (mem.startsWith(u8, entry.name, prefix)) {
                return try std.fmt.allocPrint(allocator, "{s}/{s}", .{ batch_dir, entry.name });
            }
        }
    }

    return error.AgentLogNotFound;
}

fn readFile(allocator: mem.Allocator, path: []const u8) ![]u8 {
    const file = try fs.openFileAbsolute(path, .{});
    defer file.close();
    const stat = try file.stat();
    const buffer = try allocator.alloc(u8, stat.size);
    const bytes_read = try file.read(buffer);
    return buffer[0..bytes_read];
}

fn writeFile(path: []const u8, content: []const u8) !void {
    const file = try fs.createFileAbsolute(path, .{});
    defer file.close();
    try file.writeAll(content);
}

fn appendFile(path: []const u8, content: []const u8) !void {
    const file = try fs.openFileAbsolute(path, .{ .mode = .write_only });
    defer file.close();
    try file.seekFromEnd(0);
    try file.writeAll(content);
}
