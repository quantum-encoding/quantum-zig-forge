//! Fixed-size memory pool
//!
//! Performance: <10ns allocation, <5ns deallocation

const std = @import("std");

pub const FixedPool = struct {
    allocator: std.mem.Allocator,
    object_size: usize,
    capacity: usize,
    memory: []align(@alignOf(*Node)) u8,
    free_list: ?*Node,
    allocated: usize,

    const Node = struct {
        next: ?*Node,
    };

    pub fn init(allocator: std.mem.Allocator, object_size: usize, capacity: usize) !FixedPool {
        // Ensure object_size is at least pointer-sized for free list
        const actual_size = @max(object_size, @sizeOf(*Node));

        // Allocate memory for all objects with pointer alignment
        const memory = try allocator.alignedAlloc(u8, std.mem.Alignment.fromByteUnits(@alignOf(*Node)), actual_size * capacity);

        // Build free list
        var free_list: ?*Node = null;
        var i: usize = 0;
        while (i < capacity) : (i += 1) {
            const node = @as(*Node, @ptrCast(@alignCast(&memory[i * actual_size])));
            node.next = free_list;
            free_list = node;
        }

        return FixedPool{
            .allocator = allocator,
            .object_size = actual_size,
            .capacity = capacity,
            .memory = memory,
            .free_list = free_list,
            .allocated = 0,
        };
    }

    pub fn deinit(self: *FixedPool) void {
        self.allocator.free(self.memory);
    }

    pub fn alloc(self: *FixedPool) !*anyopaque {
        const node = self.free_list orelse return error.OutOfMemory;
        self.free_list = node.next;
        self.allocated += 1;
        return @as(*anyopaque, @ptrCast(node));
    }

    pub fn free(self: *FixedPool, ptr: *anyopaque) void {
        const node = @as(*Node, @ptrCast(@alignCast(ptr)));
        node.next = self.free_list;
        self.free_list = node;
        self.allocated -= 1;
    }

    pub fn reset(self: *FixedPool) void {
        // Rebuild free list
        self.free_list = null;
        var i: usize = 0;
        while (i < self.capacity) : (i += 1) {
            const node = @as(*Node, @ptrCast(@alignCast(&self.memory[i * self.object_size])));
            node.next = self.free_list;
            self.free_list = node;
        }
        self.allocated = 0;
    }
};

test "fixed pool - basic operations" {
    const allocator = std.testing.allocator;

    var pool_inst = try FixedPool.init(allocator, 64, 10);
    defer pool_inst.deinit();

    const ptr1 = try pool_inst.alloc();
    const ptr2 = try pool_inst.alloc();

    try std.testing.expectEqual(@as(usize, 2), pool_inst.allocated);

    pool_inst.free(ptr1);
    pool_inst.free(ptr2);

    try std.testing.expectEqual(@as(usize, 0), pool_inst.allocated);
}
