//! Query engine for time-range queries

const std = @import("std");

pub const QueryEngine = struct {
    pub fn init() QueryEngine {
        return .{};
    }

    pub fn executeRange(self: *QueryEngine, start: i64, end: i64) ![]const u8 {
        _ = self;
        _ = start;
        _ = end;
        return error.NotImplemented;
    }
};
