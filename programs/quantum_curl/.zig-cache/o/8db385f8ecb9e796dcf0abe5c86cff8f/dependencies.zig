pub const packages = struct {
    pub const @"../http_sentinel" = struct {
        pub const build_root = "/home/founder/.quantum-forge/workspaces/quantum-zig-forge/programs/quantum_curl/../http_sentinel";
        pub const build_zig = @import("../http_sentinel");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "http_sentinel", "../http_sentinel" },
};
