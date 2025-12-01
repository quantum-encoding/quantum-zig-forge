//! Slab allocator for multiple object sizes

const std = @import("std");

pub const SlabAllocator = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) SlabAllocator {
        return SlabAllocator{
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *SlabAllocator) void {
        _ = self;
        // TODO: Free all slabs
    }

    pub fn alloc(self: *SlabAllocator, size: usize) !*anyopaque {
        _ = self;
        _ = size;
        // TODO: Find appropriate slab and allocate
        return error.NotImplemented;
    }

    pub fn free(self: *SlabAllocator, ptr: *anyopaque) void {
        _ = self;
        _ = ptr;
        // TODO: Return to appropriate slab
    }
};
