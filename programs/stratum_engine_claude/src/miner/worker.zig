//! Mining Worker Thread
//! Each worker continuously hashes nonces looking for valid shares
//! Uses SIMD batching (AVX2/AVX-512) for maximum performance

const std = @import("std");
const types = @import("../stratum/types.zig");
const dispatch = @import("../crypto/dispatch.zig");

pub const WorkerStats = struct {
    hashes: std.atomic.Value(u64),
    shares_found: std.atomic.Value(u32),
    shares_accepted: std.atomic.Value(u32),
    shares_rejected: std.atomic.Value(u32),

    pub fn init() WorkerStats {
        return .{
            .hashes = std.atomic.Value(u64).init(0),
            .shares_found = std.atomic.Value(u32).init(0),
            .shares_accepted = std.atomic.Value(u32).init(0),
            .shares_rejected = std.atomic.Value(u32).init(0),
        };
    }

    pub fn recordHash(self: *WorkerStats) void {
        _ = self.hashes.fetchAdd(1, .monotonic);
    }

    pub fn recordHashes(self: *WorkerStats, count: u64) void {
        _ = self.hashes.fetchAdd(count, .monotonic);
    }

    pub fn recordShare(self: *WorkerStats) void {
        _ = self.shares_found.fetchAdd(1, .monotonic);
    }

    pub fn getHashrate(self: *WorkerStats, duration_ns: u64) f64 {
        const hashes = self.hashes.load(.monotonic);
        const duration_s = @as(f64, @floatFromInt(duration_ns)) / 1_000_000_000.0;
        return @as(f64, @floatFromInt(hashes)) / duration_s;
    }
};

pub const Worker = struct {
    id: u32,
    stats: *WorkerStats,
    job: ?types.Job,
    target: types.Target,
    running: std.atomic.Value(bool),
    hasher: dispatch.Hasher,

    const Self = @This();

    pub fn init(id: u32, stats: *WorkerStats) Self {
        return .{
            .id = id,
            .stats = stats,
            .job = null,
            .target = types.Target.fromNBits(0x1d00ffff), // Default difficulty
            .running = std.atomic.Value(bool).init(false),
            .hasher = dispatch.Hasher.init(),
        };
    }

    /// Main mining loop - runs in dedicated thread with SIMD batching
    pub fn run(self: *Self) void {
        self.running.store(true, .release);

        var nonce: u32 = self.id * 1_000_000; // Offset based on worker ID
        const batch_size = self.hasher.getBatchSize();

        while (self.running.load(.acquire)) {
            // Wait for job
            if (self.job == null) {
                std.posix.nanosleep(0, 10_000_000); // Sleep 10ms
                continue;
            }

            // Process batch based on SIMD capability
            if (batch_size == 16) {
                self.runBatch16(&nonce);
            } else if (batch_size == 8) {
                self.runBatch8(&nonce);
            } else {
                self.runBatchScalar(&nonce);
            }

            // Check for new work every batch
            if (nonce % 1_000_000 == 0) {
                std.Thread.yield() catch {};
            }
        }
    }

    /// Process 16 nonces at once (AVX-512)
    fn runBatch16(self: *Self, nonce: *u32) void {
        var headers: [16][80]u8 = undefined;
        var hashes: [16][32]u8 = undefined;

        // Build 16 headers with consecutive nonces
        for (0..16) |i| {
            headers[i] = self.buildHeader(nonce.* +% @as(u32, @intCast(i)));
        }

        // Hash all 16 in parallel
        self.hasher.hash16(&headers, &hashes);
        self.stats.recordHashes(16);

        // Check all 16 results
        for (0..16) |i| {
            if (self.target.meetsTarget(&hashes[i])) {
                self.stats.recordShare();
                // TODO: Submit share to pool
            }
        }

        nonce.* +%= 16;
    }

    /// Process 8 nonces at once (AVX2)
    fn runBatch8(self: *Self, nonce: *u32) void {
        var headers: [8][80]u8 = undefined;
        var hashes: [8][32]u8 = undefined;

        // Build 8 headers with consecutive nonces
        for (0..8) |i| {
            headers[i] = self.buildHeader(nonce.* +% @as(u32, @intCast(i)));
        }

        // Hash all 8 in parallel
        self.hasher.hash8(&headers, &hashes);
        self.stats.recordHashes(8);

        // Check all 8 results
        for (0..8) |i| {
            if (self.target.meetsTarget(&hashes[i])) {
                self.stats.recordShare();
                // TODO: Submit share to pool
            }
        }

        nonce.* +%= 8;
    }

    /// Process single nonce (scalar fallback)
    fn runBatchScalar(self: *Self, nonce: *u32) void {
        var header = self.buildHeader(nonce.*);
        var hash: [32]u8 = undefined;

        self.hasher.hashOne(&header, &hash);
        self.stats.recordHash();

        if (self.target.meetsTarget(&hash)) {
            self.stats.recordShare();
            // TODO: Submit share to pool
        }

        nonce.* +%= 1;
    }

    pub fn stop(self: *Self) void {
        self.running.store(false, .release);
    }

    pub fn updateJob(self: *Self, job: types.Job, target: types.Target) void {
        self.job = job;
        self.target = target;
    }

    /// Build 80-byte block header from job and nonce
    fn buildHeader(self: *Self, nonce: u32) [80]u8 {
        var header = [_]u8{0} ** 80;

        const job = self.job orelse return header;

        // Version (bytes 0-3, little-endian)
        header[0] = @intCast(job.version & 0xFF);
        header[1] = @intCast((job.version >> 8) & 0xFF);
        header[2] = @intCast((job.version >> 16) & 0xFF);
        header[3] = @intCast((job.version >> 24) & 0xFF);

        // Previous block hash (bytes 4-35, already in correct order)
        @memcpy(header[4..36], &job.prevhash);

        // Merkle root (bytes 36-67) - simplified, just zeros for now
        // Real implementation would compute from coinbase + merkle branches

        // Time (bytes 68-71, little-endian)
        header[68] = @intCast(job.ntime & 0xFF);
        header[69] = @intCast((job.ntime >> 8) & 0xFF);
        header[70] = @intCast((job.ntime >> 16) & 0xFF);
        header[71] = @intCast((job.ntime >> 24) & 0xFF);

        // Bits (bytes 72-75, little-endian)
        header[72] = @intCast(job.nbits & 0xFF);
        header[73] = @intCast((job.nbits >> 8) & 0xFF);
        header[74] = @intCast((job.nbits >> 16) & 0xFF);
        header[75] = @intCast((job.nbits >> 24) & 0xFF);

        // Nonce (bytes 76-79, little-endian)
        header[76] = @intCast(nonce & 0xFF);
        header[77] = @intCast((nonce >> 8) & 0xFF);
        header[78] = @intCast((nonce >> 16) & 0xFF);
        header[79] = @intCast((nonce >> 24) & 0xFF);

        return header;
    }
};

test "worker stats" {
    var stats = WorkerStats.init();
    stats.recordHash();
    stats.recordHash();
    stats.recordShare();

    try std.testing.expectEqual(@as(u64, 2), stats.hashes.load(.monotonic));
    try std.testing.expectEqual(@as(u32, 1), stats.shares_found.load(.monotonic));
}
