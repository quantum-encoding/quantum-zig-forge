//! Write-Ahead Log (WAL) Implementation
//!
//! Provides durable storage for Raft log entries with crash recovery:
//! - Append-only log file with CRC32 checksums
//! - Vote persistence for leader election
//! - Segment-based rotation for efficient truncation
//! - Recovery on startup from persisted state
//!
//! File format:
//!   Header: magic(4) + version(2) + node_id(8) = 14 bytes
//!   Record: type(1) + len(4) + crc32(4) + data(len)
//!
//! Record types:
//!   0x01 = Log entry
//!   0x02 = Vote record
//!   0x03 = Snapshot marker
//!   0x04 = Term update

const std = @import("std");
const raft = @import("raft.zig");

// =============================================================================
// Constants
// =============================================================================

/// WAL file magic number: "DKWL" (Distributed KV WAL)
const WAL_MAGIC: [4]u8 = .{ 'D', 'K', 'W', 'L' };

/// Current WAL format version
const WAL_VERSION: u16 = 1;

/// Maximum segment size before rotation (64MB)
const MAX_SEGMENT_SIZE: u64 = 64 * 1024 * 1024;

/// Record type markers
const RecordType = enum(u8) {
    log_entry = 0x01,
    vote = 0x02,
    snapshot_marker = 0x03,
    term_update = 0x04,
};

/// Header size
const HEADER_SIZE: usize = 14;

/// Record header size: type(1) + len(4) + crc32(4)
const RECORD_HEADER_SIZE: usize = 9;

// =============================================================================
// Errors
// =============================================================================

pub const WalError = error{
    InvalidMagic,
    UnsupportedVersion,
    CorruptedRecord,
    ChecksumMismatch,
    UnexpectedEof,
    SegmentFull,
    FileNotFound,
    PermissionDenied,
    IoError,
    OutOfMemory,
};

// =============================================================================
// WAL Writer
// =============================================================================

/// Write-ahead log writer for durably persisting Raft state
pub const WalWriter = struct {
    allocator: std.mem.Allocator,
    dir_path: []const u8,
    node_id: raft.NodeId,
    current_segment: ?std.fs.File,
    segment_index: u32,
    bytes_written: u64,

    pub fn init(allocator: std.mem.Allocator, dir_path: []const u8, node_id: raft.NodeId) !WalWriter {
        // Ensure directory exists
        std.fs.cwd().makePath(dir_path) catch |err| {
            if (err != error.PathAlreadyExists) return WalError.IoError;
        };

        var writer = WalWriter{
            .allocator = allocator,
            .dir_path = try allocator.dupe(u8, dir_path),
            .node_id = node_id,
            .current_segment = null,
            .segment_index = 0,
            .bytes_written = 0,
        };

        // Find latest segment or create new one
        try writer.openOrCreateSegment();

        return writer;
    }

    pub fn deinit(self: *WalWriter) void {
        if (self.current_segment) |*f| {
            f.close();
        }
        self.allocator.free(self.dir_path);
    }

    /// Write a log entry to the WAL
    pub fn writeEntry(self: *WalWriter, entry_data: []const u8) !void {
        try self.writeRecord(.log_entry, entry_data);
    }

    /// Write a vote record to the WAL
    pub fn writeVote(self: *WalWriter, term: raft.Term, voted_for: raft.NodeId) !void {
        var buf: [16]u8 = undefined;
        std.mem.writeInt(u64, buf[0..8], term, .little);
        std.mem.writeInt(u64, buf[8..16], voted_for, .little);
        try self.writeRecord(.vote, &buf);
    }

    /// Write a term update
    pub fn writeTerm(self: *WalWriter, term: raft.Term) !void {
        var buf: [8]u8 = undefined;
        std.mem.writeInt(u64, buf[0..8], term, .little);
        try self.writeRecord(.term_update, &buf);
    }

    /// Sync WAL to disk
    pub fn sync(self: *WalWriter) !void {
        if (self.current_segment) |f| {
            f.sync() catch return WalError.IoError;
        }
    }

    /// Write a record with checksum
    fn writeRecord(self: *WalWriter, record_type: RecordType, data: []const u8) !void {
        // Check if rotation needed
        if (self.bytes_written + RECORD_HEADER_SIZE + data.len > MAX_SEGMENT_SIZE) {
            try self.rotateSegment();
        }

        const file = self.current_segment orelse return WalError.IoError;

        // Compute CRC32
        const crc = std.hash.Crc32.hash(data);

        // Write record header
        var header: [RECORD_HEADER_SIZE]u8 = undefined;
        header[0] = @intFromEnum(record_type);
        std.mem.writeInt(u32, header[1..5], @intCast(data.len), .little);
        std.mem.writeInt(u32, header[5..9], crc, .little);

        file.writeAll(&header) catch return WalError.IoError;
        file.writeAll(data) catch return WalError.IoError;

        self.bytes_written += RECORD_HEADER_SIZE + data.len;
    }

    /// Open existing segment or create new one
    fn openOrCreateSegment(self: *WalWriter) !void {
        // Find highest segment index
        var highest: u32 = 0;
        var found = false;

        var dir = std.fs.cwd().openDir(self.dir_path, .{ .iterate = true }) catch |err| {
            if (err == error.FileNotFound) {
                // Directory doesn't exist yet, create first segment
                return self.createNewSegment(0);
            }
            return WalError.IoError;
        };
        defer dir.close();

        var iter = dir.iterate();
        while (iter.next() catch return WalError.IoError) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.startsWith(u8, entry.name, "wal-")) continue;
            if (!std.mem.endsWith(u8, entry.name, ".log")) continue;

            // Parse segment index from filename: wal-XXXXXXXX.log
            const idx_str = entry.name[4..12];
            const idx = std.fmt.parseInt(u32, idx_str, 16) catch continue;
            if (idx >= highest) {
                highest = idx;
                found = true;
            }
        }

        if (found) {
            // Open existing segment
            try self.openSegment(highest);
        } else {
            // Create first segment
            try self.createNewSegment(0);
        }
    }

    /// Create a new segment file
    fn createNewSegment(self: *WalWriter, index: u32) !void {
        const path = try self.segmentPath(index);
        defer self.allocator.free(path);

        const file = std.fs.cwd().createFile(path, .{}) catch return WalError.IoError;

        // Write header
        var header: [HEADER_SIZE]u8 = undefined;
        @memcpy(header[0..4], &WAL_MAGIC);
        std.mem.writeInt(u16, header[4..6], WAL_VERSION, .little);
        std.mem.writeInt(u64, header[6..14], self.node_id, .little);

        file.writeAll(&header) catch {
            file.close();
            return WalError.IoError;
        };

        self.current_segment = file;
        self.segment_index = index;
        self.bytes_written = HEADER_SIZE;
    }

    /// Open existing segment file
    fn openSegment(self: *WalWriter, index: u32) !void {
        const path = try self.segmentPath(index);
        defer self.allocator.free(path);

        const file = std.fs.cwd().openFile(path, .{ .mode = .read_write }) catch return WalError.FileNotFound;

        // Verify header
        var header: [HEADER_SIZE]u8 = undefined;
        const read = file.read(&header) catch {
            file.close();
            return WalError.IoError;
        };

        if (read < HEADER_SIZE) {
            file.close();
            return WalError.UnexpectedEof;
        }

        if (!std.mem.eql(u8, header[0..4], &WAL_MAGIC)) {
            file.close();
            return WalError.InvalidMagic;
        }

        const version = std.mem.readInt(u16, header[4..6], .little);
        if (version > WAL_VERSION) {
            file.close();
            return WalError.UnsupportedVersion;
        }

        // Seek to end for appending
        const size = file.getEndPos() catch {
            file.close();
            return WalError.IoError;
        };
        file.seekTo(size) catch {
            file.close();
            return WalError.IoError;
        };

        self.current_segment = file;
        self.segment_index = index;
        self.bytes_written = size;
    }

    /// Rotate to a new segment
    fn rotateSegment(self: *WalWriter) !void {
        // Close current segment
        if (self.current_segment) |*f| {
            f.sync() catch {};
            f.close();
        }

        // Create new segment
        try self.createNewSegment(self.segment_index + 1);
    }

    /// Generate segment file path
    fn segmentPath(self: *WalWriter, index: u32) ![]u8 {
        return std.fmt.allocPrint(self.allocator, "{s}/wal-{x:0>8}.log", .{ self.dir_path, index });
    }
};

// =============================================================================
// WAL Reader
// =============================================================================

/// Record read from WAL
pub const WalRecord = struct {
    record_type: RecordType,
    data: []u8,

    pub fn deinit(self: *WalRecord, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }
};

/// WAL reader for crash recovery
pub const WalReader = struct {
    allocator: std.mem.Allocator,
    dir_path: []const u8,
    segments: std.ArrayListUnmanaged(u32),
    current_segment_idx: usize,
    current_file: ?std.fs.File,

    pub fn init(allocator: std.mem.Allocator, dir_path: []const u8) !WalReader {
        var reader = WalReader{
            .allocator = allocator,
            .dir_path = try allocator.dupe(u8, dir_path),
            .segments = .empty,
            .current_segment_idx = 0,
            .current_file = null,
        };

        // Discover all segments
        try reader.discoverSegments();

        return reader;
    }

    pub fn deinit(self: *WalReader) void {
        if (self.current_file) |*f| {
            f.close();
        }
        self.segments.deinit(self.allocator);
        self.allocator.free(self.dir_path);
    }

    /// Read next record from WAL
    pub fn readNext(self: *WalReader) !?WalRecord {
        while (true) {
            // Open next segment if needed
            if (self.current_file == null) {
                if (self.current_segment_idx >= self.segments.items.len) {
                    return null; // No more segments
                }
                try self.openSegmentForRead(self.segments.items[self.current_segment_idx]);
            }

            const file = self.current_file.?;

            // Read record header
            var header: [RECORD_HEADER_SIZE]u8 = undefined;
            const read = file.read(&header) catch return WalError.IoError;

            if (read == 0) {
                // End of segment, move to next
                file.close();
                self.current_file = null;
                self.current_segment_idx += 1;
                continue;
            }

            if (read < RECORD_HEADER_SIZE) {
                return WalError.UnexpectedEof;
            }

            const record_type_byte = header[0];
            const record_type: RecordType = switch (record_type_byte) {
                0x01 => .log_entry,
                0x02 => .vote,
                0x03 => .snapshot_marker,
                0x04 => .term_update,
                else => return WalError.CorruptedRecord,
            };

            const data_len = std.mem.readInt(u32, header[1..5], .little);
            const expected_crc = std.mem.readInt(u32, header[5..9], .little);

            // Read data
            const data = try self.allocator.alloc(u8, data_len);
            errdefer self.allocator.free(data);

            var total_read: usize = 0;
            while (total_read < data_len) {
                const bytes = file.read(data[total_read..]) catch return WalError.IoError;
                if (bytes == 0) return WalError.UnexpectedEof;
                total_read += bytes;
            }

            // Verify checksum
            const actual_crc = std.hash.Crc32.hash(data);
            if (actual_crc != expected_crc) {
                self.allocator.free(data);
                return WalError.ChecksumMismatch;
            }

            return WalRecord{
                .record_type = record_type,
                .data = data,
            };
        }
    }

    /// Discover all WAL segments in directory
    fn discoverSegments(self: *WalReader) !void {
        var dir = std.fs.cwd().openDir(self.dir_path, .{ .iterate = true }) catch |err| {
            if (err == error.FileNotFound) return;
            return WalError.IoError;
        };
        defer dir.close();

        var iter = dir.iterate();
        while (iter.next() catch return WalError.IoError) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.startsWith(u8, entry.name, "wal-")) continue;
            if (!std.mem.endsWith(u8, entry.name, ".log")) continue;

            const idx_str = entry.name[4..12];
            const idx = std.fmt.parseInt(u32, idx_str, 16) catch continue;
            try self.segments.append(self.allocator, idx);
        }

        // Sort segments by index
        std.mem.sort(u32, self.segments.items, {}, std.sort.asc(u32));
    }

    /// Open a segment for reading
    fn openSegmentForRead(self: *WalReader, index: u32) !void {
        const path = try std.fmt.allocPrint(self.allocator, "{s}/wal-{x:0>8}.log", .{ self.dir_path, index });
        defer self.allocator.free(path);

        const file = std.fs.cwd().openFile(path, .{}) catch return WalError.FileNotFound;

        // Read and verify header
        var header: [HEADER_SIZE]u8 = undefined;
        const read = file.read(&header) catch {
            file.close();
            return WalError.IoError;
        };

        if (read < HEADER_SIZE) {
            file.close();
            return WalError.UnexpectedEof;
        }

        if (!std.mem.eql(u8, header[0..4], &WAL_MAGIC)) {
            file.close();
            return WalError.InvalidMagic;
        }

        self.current_file = file;
    }
};

// =============================================================================
// Recovery
// =============================================================================

/// Recovered state from WAL
pub const RecoveredState = struct {
    current_term: raft.Term,
    voted_for: ?raft.NodeId,
    log_entries: std.ArrayListUnmanaged(raft.LogEntry),

    pub fn deinit(self: *RecoveredState, allocator: std.mem.Allocator) void {
        for (self.log_entries.items) |*entry| {
            entry.deinit(allocator);
        }
        self.log_entries.deinit(allocator);
    }
};

/// Recover Raft state from WAL
pub fn recover(allocator: std.mem.Allocator, dir_path: []const u8) !RecoveredState {
    var state = RecoveredState{
        .current_term = 0,
        .voted_for = null,
        .log_entries = .empty,
    };

    var reader = WalReader.init(allocator, dir_path) catch |err| {
        if (err == WalError.FileNotFound or err == error.FileNotFound) {
            return state; // No WAL exists, return empty state
        }
        return err;
    };
    defer reader.deinit();

    // Replay all records
    while (try reader.readNext()) |*record| {
        defer record.deinit(allocator);

        switch (record.record_type) {
            .log_entry => {
                const entry = try raft.LogEntry.decode(allocator, record.data);
                try state.log_entries.append(allocator, entry);
            },
            .vote => {
                if (record.data.len >= 16) {
                    state.current_term = std.mem.readInt(u64, record.data[0..8], .little);
                    state.voted_for = std.mem.readInt(u64, record.data[8..16], .little);
                }
            },
            .term_update => {
                if (record.data.len >= 8) {
                    state.current_term = std.mem.readInt(u64, record.data[0..8], .little);
                    state.voted_for = null; // Vote resets on term change
                }
            },
            .snapshot_marker => {
                // TODO: Handle snapshot recovery
            },
        }
    }

    return state;
}

// =============================================================================
// Tests
// =============================================================================

test "wal write and read" {
    const allocator = std.testing.allocator;

    // Create temp directory
    const dir = "/tmp/test-wal-1";
    defer {
        std.fs.cwd().deleteTree(dir) catch {};
    }

    // Write records
    {
        var writer = try WalWriter.init(allocator, dir, 1);
        defer writer.deinit();

        try writer.writeEntry("entry1");
        try writer.writeEntry("entry2");
        try writer.writeVote(5, 2);
        try writer.sync();
    }

    // Read records back
    {
        var reader = try WalReader.init(allocator, dir);
        defer reader.deinit();

        var record1 = (try reader.readNext()).?;
        defer record1.deinit(allocator);
        try std.testing.expectEqual(RecordType.log_entry, record1.record_type);
        try std.testing.expectEqualStrings("entry1", record1.data);

        var record2 = (try reader.readNext()).?;
        defer record2.deinit(allocator);
        try std.testing.expectEqual(RecordType.log_entry, record2.record_type);
        try std.testing.expectEqualStrings("entry2", record2.data);

        var record3 = (try reader.readNext()).?;
        defer record3.deinit(allocator);
        try std.testing.expectEqual(RecordType.vote, record3.record_type);

        const record4 = try reader.readNext();
        try std.testing.expect(record4 == null);
    }
}

test "wal checksum verification" {
    const data = "test data";
    const crc = std.hash.Crc32.hash(data);
    try std.testing.expect(crc != 0);
}

test "wal recovery" {
    const allocator = std.testing.allocator;

    const dir = "/tmp/test-wal-recovery";
    defer {
        std.fs.cwd().deleteTree(dir) catch {};
    }

    // Write some state
    {
        var writer = try WalWriter.init(allocator, dir, 1);
        defer writer.deinit();

        // Write a log entry
        const entry = raft.LogEntry{
            .term = 3,
            .index = 1,
            .command_type = .set,
            .data = "key=value",
        };
        const encoded = try entry.encode(allocator);
        defer allocator.free(encoded);

        try writer.writeEntry(encoded);
        try writer.writeVote(3, 2);
        try writer.sync();
    }

    // Recover state
    {
        var state = try recover(allocator, dir);
        defer state.deinit(allocator);

        try std.testing.expectEqual(@as(raft.Term, 3), state.current_term);
        try std.testing.expectEqual(@as(?raft.NodeId, 2), state.voted_for);
        try std.testing.expectEqual(@as(usize, 1), state.log_entries.items.len);
    }
}
