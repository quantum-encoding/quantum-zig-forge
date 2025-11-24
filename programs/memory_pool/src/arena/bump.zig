//! Arena allocator (bump pointer)
//!
//! Performance: <3ns allocation

const std = @import("std");

pub const ArenaAllocator = struct {
    allocator: std.mem.Allocator,
    buffer: []u8,
    offset: usize,

    pub fn init(allocator: std.mem.Allocator, size: usize) !ArenaAllocator {
        const buffer = try allocator.alloc(u8, size);
        return ArenaAllocator{
            .allocator = allocator,
            .buffer = buffer,
            .offset = 0,
        };
    }

    pub fn deinit(self: *ArenaAllocator) void {
        self.allocator.free(self.buffer);
    }

    pub fn alloc(self: *ArenaAllocator, size: usize, alignment: usize) ![]u8 {
        const aligned_offset = std.mem.alignForward(usize, self.offset, alignment);
        const new_offset = aligned_offset + size;

        if (new_offset > self.buffer.len) {
            return error.OutOfMemory;
        }

        self.offset = new_offset;
        return self.buffer[aligned_offset..new_offset];
    }

    pub fn reset(self: *ArenaAllocator) void {
        self.offset = 0;
    }
};
