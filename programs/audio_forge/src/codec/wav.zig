//! WAV File Decoder
//!
//! Pure Zig implementation of RIFF WAVE format decoder.
//! Supports:
//! - PCM 8-bit unsigned
//! - PCM 16-bit signed little-endian
//! - PCM 24-bit signed little-endian
//! - PCM 32-bit signed little-endian
//! - IEEE float 32-bit
//! - IEEE float 64-bit

const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const posix = std.posix;

/// WAV format codes
const FormatTag = enum(u16) {
    pcm = 0x0001,
    ieee_float = 0x0003,
    extensible = 0xFFFE,
    _,
};

/// WAV file decoder
pub const WavDecoder = struct {
    file: fs.File,

    // Format info from header
    format_tag: FormatTag,
    channels: u16,
    sample_rate: u32,
    bits_per_sample: u16,
    block_align: u16,

    // Data chunk info
    data_offset: u64,
    data_size: u64,

    // Current position
    bytes_read: u64,
    total_frames: u64,

    const Self = @This();

    /// Read bytes from file
    fn readBytes(self: *Self, buf: []u8) !usize {
        return self.file.read(buf);
    }

    /// Read all bytes
    fn readAll(self: *Self, buf: []u8) !usize {
        var total: usize = 0;
        while (total < buf.len) {
            const n = try self.file.read(buf[total..]);
            if (n == 0) break;
            total += n;
        }
        return total;
    }

    /// Read u16 little-endian
    fn readU16(self: *Self) !u16 {
        var buf: [2]u8 = undefined;
        const n = try self.readAll(&buf);
        if (n < 2) return error.UnexpectedEndOfFile;
        return mem.readInt(u16, &buf, .little);
    }

    /// Read u32 little-endian
    fn readU32(self: *Self) !u32 {
        var buf: [4]u8 = undefined;
        const n = try self.readAll(&buf);
        if (n < 4) return error.UnexpectedEndOfFile;
        return mem.readInt(u32, &buf, .little);
    }

    /// Open a WAV file for decoding
    pub fn open(path: []const u8) !Self {
        const file = try fs.cwd().openFile(path, .{});
        errdefer file.close();

        var self = Self{
            .file = file,
            .format_tag = .pcm,
            .channels = 0,
            .sample_rate = 0,
            .bits_per_sample = 0,
            .block_align = 0,
            .data_offset = 0,
            .data_size = 0,
            .bytes_read = 0,
            .total_frames = 0,
        };

        try self.parseHeader();

        return self;
    }

    /// Parse WAV header and locate data chunk
    fn parseHeader(self: *Self) !void {
        // RIFF header
        var riff_id: [4]u8 = undefined;
        _ = try self.readAll(&riff_id);
        if (!mem.eql(u8, &riff_id, "RIFF")) {
            return error.InvalidWavFile;
        }

        _ = try self.readU32(); // file size - 8

        var wave_id: [4]u8 = undefined;
        _ = try self.readAll(&wave_id);
        if (!mem.eql(u8, &wave_id, "WAVE")) {
            return error.InvalidWavFile;
        }

        // Parse chunks until we find 'data'
        var found_fmt = false;
        var found_data = false;

        while (!found_data) {
            var chunk_id: [4]u8 = undefined;
            const bytes_count = try self.readAll(&chunk_id);
            if (bytes_count < 4) {
                return error.UnexpectedEndOfFile;
            }

            const chunk_size = try self.readU32();

            if (mem.eql(u8, &chunk_id, "fmt ")) {
                try self.parseFmtChunk(chunk_size);
                found_fmt = true;
            } else if (mem.eql(u8, &chunk_id, "data")) {
                if (!found_fmt) {
                    return error.MissingFmtChunk;
                }
                self.data_offset = try self.file.getPos();
                self.data_size = chunk_size;
                self.total_frames = chunk_size / self.block_align;
                found_data = true;
            } else {
                // Skip unknown chunk (pad to word boundary)
                const skip_size = (chunk_size + 1) & ~@as(u32, 1);
                try self.file.seekBy(@intCast(skip_size));
            }
        }
    }

    /// Parse fmt chunk
    fn parseFmtChunk(self: *Self, chunk_size: u32) !void {
        if (chunk_size < 16) {
            return error.InvalidFmtChunk;
        }

        self.format_tag = @enumFromInt(try self.readU16());
        self.channels = try self.readU16();
        self.sample_rate = try self.readU32();
        _ = try self.readU32(); // byte rate
        self.block_align = try self.readU16();
        self.bits_per_sample = try self.readU16();

        // Skip any extra format bytes
        if (chunk_size > 16) {
            const extra = chunk_size - 16;
            const skip_size = (extra + 1) & ~@as(u32, 1);
            try self.file.seekBy(@intCast(skip_size));
        }

        // Validate format
        switch (self.format_tag) {
            .pcm => {
                if (self.bits_per_sample != 8 and
                    self.bits_per_sample != 16 and
                    self.bits_per_sample != 24 and
                    self.bits_per_sample != 32)
                {
                    return error.UnsupportedBitDepth;
                }
            },
            .ieee_float => {
                if (self.bits_per_sample != 32 and self.bits_per_sample != 64) {
                    return error.UnsupportedBitDepth;
                }
            },
            else => return error.UnsupportedFormat,
        }

        if (self.channels == 0 or self.channels > 8) {
            return error.InvalidChannelCount;
        }

        if (self.sample_rate == 0 or self.sample_rate > 384000) {
            return error.InvalidSampleRate;
        }
    }

    /// Decode frames to float32 output buffer
    /// Returns number of frames decoded
    pub fn decode(self: *Self, out: []f32) !usize {
        const channels: usize = self.channels;
        const frame_capacity = out.len / channels;
        const bytes_per_frame: usize = self.block_align;
        const remaining_frames = (self.data_size - self.bytes_read) / bytes_per_frame;
        const frames_to_read = @min(frame_capacity, remaining_frames);

        if (frames_to_read == 0) return 0;

        const bytes_to_read = frames_to_read * bytes_per_frame;

        // Temporary buffer for raw bytes (stack allocated for small reads)
        var stack_buf: [4096]u8 = undefined;
        var heap_buf: ?[]u8 = null;
        defer if (heap_buf) |buf| std.heap.page_allocator.free(buf);

        const raw_buf = if (bytes_to_read <= stack_buf.len)
            stack_buf[0..bytes_to_read]
        else blk: {
            heap_buf = try std.heap.page_allocator.alloc(u8, bytes_to_read);
            break :blk heap_buf.?;
        };

        const actual_bytes = try self.readAll(raw_buf);
        if (actual_bytes == 0) return 0;

        const actual_frames = actual_bytes / bytes_per_frame;
        self.bytes_read += actual_bytes;

        // Convert to float32 based on format
        switch (self.format_tag) {
            .pcm => switch (self.bits_per_sample) {
                8 => self.convertPcm8(raw_buf, out, actual_frames),
                16 => self.convertPcm16(raw_buf, out, actual_frames),
                24 => self.convertPcm24(raw_buf, out, actual_frames),
                32 => self.convertPcm32(raw_buf, out, actual_frames),
                else => return error.UnsupportedBitDepth,
            },
            .ieee_float => switch (self.bits_per_sample) {
                32 => self.convertFloat32(raw_buf, out, actual_frames),
                64 => self.convertFloat64(raw_buf, out, actual_frames),
                else => return error.UnsupportedBitDepth,
            },
            else => return error.UnsupportedFormat,
        }

        return actual_frames;
    }

    /// Convert 8-bit unsigned PCM to float32
    fn convertPcm8(self: *Self, raw: []const u8, out: []f32, frames: usize) void {
        const channels: usize = self.channels;
        const total_samples = frames * channels;

        for (0..total_samples) |i| {
            // 8-bit WAV is unsigned: 0-255, 128 = silence
            const sample_u8 = raw[i];
            const sample_i = @as(i16, sample_u8) - 128;
            out[i] = @as(f32, @floatFromInt(sample_i)) / 128.0;
        }
    }

    /// Convert 16-bit signed PCM to float32
    fn convertPcm16(self: *Self, raw: []const u8, out: []f32, frames: usize) void {
        const channels: usize = self.channels;
        const total_samples = frames * channels;

        for (0..total_samples) |i| {
            const offset = i * 2;
            const sample_i16 = mem.readInt(i16, raw[offset..][0..2], .little);
            out[i] = @as(f32, @floatFromInt(sample_i16)) / 32768.0;
        }
    }

    /// Convert 24-bit signed PCM to float32
    fn convertPcm24(self: *Self, raw: []const u8, out: []f32, frames: usize) void {
        const channels: usize = self.channels;
        const total_samples = frames * channels;

        for (0..total_samples) |i| {
            const offset = i * 3;
            // Read 3 bytes and sign-extend to i32
            const b0: u32 = raw[offset];
            const b1: u32 = raw[offset + 1];
            const b2: u32 = raw[offset + 2];

            var sample_u32 = b0 | (b1 << 8) | (b2 << 16);
            // Sign extend from 24 to 32 bits
            if (sample_u32 & 0x800000 != 0) {
                sample_u32 |= 0xFF000000;
            }
            const sample_i32: i32 = @bitCast(sample_u32);
            out[i] = @as(f32, @floatFromInt(sample_i32)) / 8388608.0;
        }
    }

    /// Convert 32-bit signed PCM to float32
    fn convertPcm32(self: *Self, raw: []const u8, out: []f32, frames: usize) void {
        const channels: usize = self.channels;
        const total_samples = frames * channels;

        for (0..total_samples) |i| {
            const offset = i * 4;
            const sample_i32 = mem.readInt(i32, raw[offset..][0..4], .little);
            out[i] = @as(f32, @floatFromInt(sample_i32)) / 2147483648.0;
        }
    }

    /// Convert 32-bit float to float32 (just copy)
    fn convertFloat32(self: *Self, raw: []const u8, out: []f32, frames: usize) void {
        const channels: usize = self.channels;
        const total_samples = frames * channels;

        for (0..total_samples) |i| {
            const offset = i * 4;
            out[i] = @bitCast(mem.readInt(u32, raw[offset..][0..4], .little));
        }
    }

    /// Convert 64-bit float to float32
    fn convertFloat64(self: *Self, raw: []const u8, out: []f32, frames: usize) void {
        const channels: usize = self.channels;
        const total_samples = frames * channels;

        for (0..total_samples) |i| {
            const offset = i * 8;
            const sample_f64: f64 = @bitCast(mem.readInt(u64, raw[offset..][0..8], .little));
            out[i] = @floatCast(sample_f64);
        }
    }

    /// Seek to a specific frame
    pub fn seek(self: *Self, frame: u64) !void {
        if (frame >= self.total_frames) {
            return error.SeekOutOfRange;
        }

        const byte_offset = frame * self.block_align;
        try self.file.seekTo(self.data_offset + byte_offset);
        self.bytes_read = byte_offset;
    }

    /// Get current position in frames
    pub fn position(self: *const Self) u64 {
        return self.bytes_read / self.block_align;
    }

    /// Get total duration in seconds
    pub fn durationSeconds(self: *const Self) f64 {
        return @as(f64, @floatFromInt(self.total_frames)) / @as(f64, @floatFromInt(self.sample_rate));
    }

    /// Check if decoder has reached end of file
    pub fn isEof(self: *const Self) bool {
        return self.bytes_read >= self.data_size;
    }

    /// Close the decoder
    pub fn close(self: *Self) void {
        self.file.close();
    }

    /// Get sample rate
    pub fn getSampleRate(self: *const Self) u32 {
        return self.sample_rate;
    }

    /// Get number of channels
    pub fn getChannels(self: *const Self) u16 {
        return self.channels;
    }

    /// Get total number of frames
    pub fn getTotalFrames(self: *const Self) u64 {
        return self.total_frames;
    }
};

// =============================================================================
// Tests
// =============================================================================

test "wav decoder structure size" {
    // Ensure reasonable struct size
    try std.testing.expect(@sizeOf(WavDecoder) < 256);
}

test "format tag enum" {
    try std.testing.expectEqual(@as(u16, 1), @intFromEnum(FormatTag.pcm));
    try std.testing.expectEqual(@as(u16, 3), @intFromEnum(FormatTag.ieee_float));
}
