//! Mining Engine - Main coordinator
//! Connects Stratum client with worker threads for live mining

const std = @import("std");
const types = @import("stratum/types.zig");
const StratumClient = @import("stratum/client.zig").StratumClient;
const Dispatcher = @import("miner/dispatcher.zig").Dispatcher;
const MiningStats = @import("metrics/stats.zig").MiningStats;

pub const EngineConfig = struct {
    pool_url: []const u8,
    username: []const u8,
    password: []const u8,
    num_threads: u32,
};

pub const MiningEngine = struct {
    allocator: std.mem.Allocator,
    config: EngineConfig,

    stratum: StratumClient,
    dispatcher: Dispatcher,
    stats: MiningStats,

    running: std.atomic.Value(bool),
    stats_thread: ?std.Thread,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, config: EngineConfig) !Self {
        const credentials = types.Credentials{
            .url = config.pool_url,
            .username = config.username,
            .password = config.password,
        };

        return .{
            .allocator = allocator,
            .config = config,
            .stratum = try StratumClient.init(allocator, credentials),
            .dispatcher = try Dispatcher.init(allocator, config.num_threads),
            .stats = MiningStats.init(),
            .running = std.atomic.Value(bool).init(false),
            .stats_thread = null,
        };
    }

    pub fn deinit(self: *Self) void {
        self.stratum.deinit();
        self.dispatcher.deinit();
    }

    /// Main mining loop - connects to pool and starts mining
    pub fn run(self: *Self) !void {
        self.running.store(true, .release);

        // io_uring client connects during init
        const stdout_file = std.fs.File.stdout();
        var stdout_buf: [4096]u8 = undefined;
        var stdout_writer = stdout_file.writer(&stdout_buf);
        const stdout = &stdout_writer.interface;

        try stdout.print("✅ Connected via io_uring!\n", .{});

        // Step 2: Subscribe
        try stdout.print("📝 Subscribing to mining...\n", .{});

        self.stratum.subscribe() catch |err| {
            try stdout.print("❌ Subscribe failed: {}\n", .{err});
            return err;
        };

        try stdout.print("✅ Subscribed!\n", .{});

        // Step 3: Authorize
        try stdout.print("🔐 Authorizing worker: {s}\n", .{self.config.username});

        self.stratum.authorize() catch |err| {
            try stdout.print("❌ Authorization failed: {}\n", .{err});
            return err;
        };

        try stdout.print("✅ Authorized!\n\n", .{});

        // Step 4: Start mining threads
        try stdout.print("⛏️  Starting {} mining threads...\n", .{self.config.num_threads});
        try self.dispatcher.start();
        try stdout.print("✅ Mining started!\n\n", .{});

        // Step 5: Start statistics thread
        self.stats_thread = try std.Thread.spawn(.{}, statsLoop, .{self});

        // Flush output
        try std.Io.Writer.flush(&stdout_writer.interface);

        // Main loop: receive jobs and distribute to workers
        while (self.running.load(.acquire)) {
            // Try to receive a job from pool
            if (try self.stratum.receiveJob()) |job| {
                const target = types.Target.fromNBits(job.nbits);
                self.dispatcher.updateJob(job, target);

                // Job updated - workers will start hashing new work
            }

            // Small sleep to avoid busy loop
            std.posix.nanosleep(0, 100_000_000); // 100ms
        }
    }

    pub fn stop(self: *Self) void {
        self.running.store(false, .release);
        self.dispatcher.stop();

        if (self.stats_thread) |thread| {
            thread.join();
        }
    }

    /// Background thread for printing statistics
    fn statsLoop(self: *Self) void {
        const stdout_file = std.fs.File.stdout();
        var stdout_buf: [4096]u8 = undefined;
        var stdout_writer = stdout_file.writer(&stdout_buf);
        const stdout = &stdout_writer.interface;

        var last_hashes: u64 = 0;
        var timer = std.time.Timer.start() catch return;

        while (self.running.load(.acquire)) {
            // Sleep for 10 seconds
            std.posix.nanosleep(10, 0);

            // Calculate hashrate
            const current_hashes = self.dispatcher.global_stats.hashes.load(.monotonic);
            const elapsed_ns = timer.read();
            const hashes_delta = current_hashes - last_hashes;

            const hashrate = if (elapsed_ns > 0)
                @as(f64, @floatFromInt(hashes_delta)) / (@as(f64, @floatFromInt(elapsed_ns)) / 1_000_000_000.0)
            else
                0.0;

            // Print stats
            const shares = self.dispatcher.getSharesFound();

            // Get latency metrics
            const avg_latency = self.stratum.getAverageLatencyUs(10);

            stdout.print(
                \\
                \\📊 Hashrate: {d:.2} MH/s | Shares: {} | Threads: {} | Latency: {d:.2}µs
                \\
            , .{
                hashrate / 1_000_000.0,
                shares,
                self.config.num_threads,
                avg_latency,
            }) catch {};

            std.Io.Writer.flush(&stdout_writer.interface) catch {};

            last_hashes = current_hashes;
            timer.reset();
        }
    }
};
