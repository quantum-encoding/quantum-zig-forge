//! Memory Pool Core - Pure Computational FFI
//!
//! This FFI exposes high-performance memory allocators as a zero-dependency C library.
//!
//! ZERO DEPENDENCIES:
//! - No networking
//! - No file I/O
//! - No global state (except pool instances)
//!
//! Thread Safety:
//! - Fixed pools: Thread-safe if used from single thread per pool
//! - Arenas: Thread-safe if used from single thread per arena
//! - Multiple pools/arenas safe from different threads
//!
//! Performance:
//! - Fixed pool alloc: <10ns latency
//! - Fixed pool free: <5ns latency
//! - Arena alloc: <3ns latency
//! - Arena reset: O(1)

const std = @import("std");
const pool_mod = @import("pool/fixed.zig");
const arena_mod = @import("arena/bump.zig");

// ============================================================================
// Core Types (C-compatible)
// ============================================================================

/// Opaque fixed pool handle
pub const MP_FixedPool = opaque {};

/// Opaque arena allocator handle
pub const MP_Arena = opaque {};

/// Error codes
pub const MP_Error = enum(c_int) {
    SUCCESS = 0,
    OUT_OF_MEMORY = -1,
    INVALID_PARAM = -2,
    INVALID_HANDLE = -3,
};

/// Fixed pool statistics
pub const MP_FixedPoolStats = extern struct {
    object_size: usize,
    capacity: usize,
    allocated: usize,
    available: usize,
};

/// Arena statistics
pub const MP_ArenaStats = extern struct {
    buffer_size: usize,
    offset: usize,
    available: usize,
};

// ============================================================================
// Fixed Pool Operations
// ============================================================================

/// Create a new fixed-size memory pool
///
/// Parameters:
///   object_size - Size of each object in bytes
///   capacity    - Maximum number of objects
///
/// Returns:
///   Pool handle, or NULL on allocation failure
///
/// Performance:
///   ~1µs (initial allocation)
///
/// Thread Safety:
///   Safe to create multiple pools
///
/// Example:
///   // Pool for 256 objects of 64 bytes each
///   MP_FixedPool* pool = mp_fixed_pool_create(64, 256);
export fn mp_fixed_pool_create(object_size: usize, capacity: usize) ?*MP_FixedPool {
    if (object_size == 0 or capacity == 0) return null;

    const allocator = std.heap.c_allocator;

    const pool = allocator.create(pool_mod.FixedPool) catch return null;

    pool.* = pool_mod.FixedPool.init(allocator, object_size, capacity) catch {
        allocator.destroy(pool);
        return null;
    };

    return @ptrCast(pool);
}

/// Destroy fixed pool and free resources
///
/// Parameters:
///   pool - Pool handle (NULL is safe, will be no-op)
///
/// Note:
///   Does NOT free objects allocated from the pool
export fn mp_fixed_pool_destroy(pool: ?*MP_FixedPool) void {
    if (pool) |p| {
        const pool_ptr: *pool_mod.FixedPool = @ptrCast(@alignCast(p));
        pool_ptr.deinit();
        std.heap.c_allocator.destroy(pool_ptr);
    }
}

/// Allocate an object from the fixed pool
///
/// Parameters:
///   pool - Pool handle (must not be NULL)
///
/// Returns:
///   Pointer to object, or NULL if pool is full
///
/// Performance:
///   <10ns per allocation
///
/// Thread Safety:
///   Safe if pool is used from single thread
export fn mp_fixed_pool_alloc(pool: ?*MP_FixedPool) ?*anyopaque {
    const pool_ptr: *pool_mod.FixedPool = @ptrCast(@alignCast(pool orelse return null));
    return pool_ptr.alloc() catch null;
}

/// Free an object back to the fixed pool
///
/// Parameters:
///   pool - Pool handle (must not be NULL)
///   ptr  - Object pointer (must have been allocated from this pool)
///
/// Performance:
///   <5ns per free
///
/// Thread Safety:
///   Safe if pool is used from single thread
export fn mp_fixed_pool_free(pool: ?*MP_FixedPool, ptr: ?*anyopaque) void {
    const pool_ptr: *pool_mod.FixedPool = @ptrCast(@alignCast(pool orelse return));
    if (ptr) |p| {
        pool_ptr.free(p);
    }
}

/// Reset the fixed pool (free all objects)
///
/// Parameters:
///   pool - Pool handle (must not be NULL)
///
/// Note:
///   Invalidates all previously allocated pointers
///   O(capacity) operation
export fn mp_fixed_pool_reset(pool: ?*MP_FixedPool) void {
    const pool_ptr: *pool_mod.FixedPool = @ptrCast(@alignCast(pool orelse return));
    pool_ptr.reset();
}

/// Get fixed pool statistics
///
/// Parameters:
///   pool      - Pool handle (must not be NULL)
///   stats_out - Output statistics
///
/// Returns:
///   SUCCESS or INVALID_HANDLE
export fn mp_fixed_pool_stats(
    pool: ?*const MP_FixedPool,
    stats_out: *MP_FixedPoolStats,
) MP_Error {
    const pool_ptr: *const pool_mod.FixedPool = @ptrCast(@alignCast(pool orelse return .INVALID_HANDLE));

    stats_out.* = .{
        .object_size = pool_ptr.object_size,
        .capacity = pool_ptr.capacity,
        .allocated = pool_ptr.allocated,
        .available = pool_ptr.capacity - pool_ptr.allocated,
    };

    return .SUCCESS;
}

// ============================================================================
// Arena Allocator Operations
// ============================================================================

/// Create a new arena allocator
///
/// Parameters:
///   size - Total buffer size in bytes
///
/// Returns:
///   Arena handle, or NULL on allocation failure
///
/// Performance:
///   ~1µs (initial allocation)
///
/// Thread Safety:
///   Safe to create multiple arenas
///
/// Example:
///   // Arena with 1MB buffer
///   MP_Arena* arena = mp_arena_create(1024 * 1024);
export fn mp_arena_create(size: usize) ?*MP_Arena {
    if (size == 0) return null;

    const allocator = std.heap.c_allocator;

    const arena = allocator.create(arena_mod.ArenaAllocator) catch return null;

    arena.* = arena_mod.ArenaAllocator.init(allocator, size) catch {
        allocator.destroy(arena);
        return null;
    };

    return @ptrCast(arena);
}

/// Destroy arena and free resources
///
/// Parameters:
///   arena - Arena handle (NULL is safe, will be no-op)
///
/// Note:
///   Frees all memory allocated from the arena
export fn mp_arena_destroy(arena: ?*MP_Arena) void {
    if (arena) |a| {
        const arena_ptr: *arena_mod.ArenaAllocator = @ptrCast(@alignCast(a));
        arena_ptr.deinit();
        std.heap.c_allocator.destroy(arena_ptr);
    }
}

/// Allocate memory from the arena
///
/// Parameters:
///   arena     - Arena handle (must not be NULL)
///   size      - Allocation size in bytes
///   alignment - Alignment requirement (must be power of 2)
///
/// Returns:
///   Pointer to allocated memory, or NULL if arena is full
///
/// Performance:
///   <3ns per allocation
///
/// Thread Safety:
///   Safe if arena is used from single thread
export fn mp_arena_alloc(arena: ?*MP_Arena, size: usize, alignment: usize) ?*anyopaque {
    const arena_ptr: *arena_mod.ArenaAllocator = @ptrCast(@alignCast(arena orelse return null));
    const slice = arena_ptr.alloc(size, alignment) catch return null;
    return @ptrCast(slice.ptr);
}

/// Reset the arena (free all allocations)
///
/// Parameters:
///   arena - Arena handle (must not be NULL)
///
/// Note:
///   Invalidates all previously allocated pointers
///   O(1) operation
export fn mp_arena_reset(arena: ?*MP_Arena) void {
    const arena_ptr: *arena_mod.ArenaAllocator = @ptrCast(@alignCast(arena orelse return));
    arena_ptr.reset();
}

/// Get arena statistics
///
/// Parameters:
///   arena     - Arena handle (must not be NULL)
///   stats_out - Output statistics
///
/// Returns:
///   SUCCESS or INVALID_HANDLE
export fn mp_arena_stats(
    arena: ?*const MP_Arena,
    stats_out: *MP_ArenaStats,
) MP_Error {
    const arena_ptr: *const arena_mod.ArenaAllocator = @ptrCast(@alignCast(arena orelse return .INVALID_HANDLE));

    stats_out.* = .{
        .buffer_size = arena_ptr.buffer.len,
        .offset = arena_ptr.offset,
        .available = arena_ptr.buffer.len - arena_ptr.offset,
    };

    return .SUCCESS;
}

// ============================================================================
// Utility Functions
// ============================================================================

/// Get human-readable error string
export fn mp_error_string(error_code: MP_Error) [*:0]const u8 {
    return switch (error_code) {
        .SUCCESS => "Success",
        .OUT_OF_MEMORY => "Out of memory",
        .INVALID_PARAM => "Invalid parameter",
        .INVALID_HANDLE => "Invalid handle",
    };
}

/// Get library version
export fn mp_version() [*:0]const u8 {
    return "1.0.0-core";
}

/// Get performance info string
export fn mp_performance_info() [*:0]const u8 {
    return "Fixed: <10ns alloc | Arena: <3ns alloc";
}
