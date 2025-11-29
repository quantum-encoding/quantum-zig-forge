//! Request Router
//!
//! Routes incoming requests to backends or edge functions based on:
//! - Path matching (prefix, exact, regex)
//! - Host matching
//! - Method matching
//! - Header matching

const std = @import("std");
const http = @import("../http/parser.zig");
const Backend = @import("backend.zig").Backend;
const BackendPool = @import("backend.zig").BackendPool;

// =============================================================================
// Route Types
// =============================================================================

pub const RouteTarget = union(enum) {
    /// Proxy to a backend pool
    backend: *BackendPool,
    /// Execute WASM edge function
    wasm: WasmHandler,
    /// Return static response
    static: StaticResponse,
    /// Redirect to another URL
    redirect: RedirectConfig,
};

pub const WasmHandler = struct {
    /// Path to WASM module
    module_path: []const u8,
    /// Function to call
    function_name: []const u8 = "handle",
    /// Timeout in milliseconds
    timeout_ms: u32 = 30000,
    /// Memory limit in bytes
    memory_limit: u32 = 64 * 1024 * 1024,
};

pub const StaticResponse = struct {
    status: u16 = 200,
    content_type: []const u8 = "text/plain",
    body: []const u8 = "",
};

pub const RedirectConfig = struct {
    url: []const u8,
    permanent: bool = false,
};

// =============================================================================
// Route Matching
// =============================================================================

pub const MatchType = enum {
    exact,
    prefix,
    suffix,
    contains,
    regex,
};

pub const RouteMatcher = struct {
    /// Path pattern
    path: ?PathMatcher = null,
    /// Host pattern
    host: ?[]const u8 = null,
    /// HTTP methods (empty = all)
    methods: []const http.Method = &.{},
    /// Required headers
    headers: []const HeaderMatcher = &.{},
    /// Priority (higher = matched first)
    priority: u16 = 100,

    pub fn matches(self: *const RouteMatcher, request: *const http.Request) bool {
        // Check path
        if (self.path) |path_matcher| {
            if (!path_matcher.matches(request.path)) return false;
        }

        // Check host
        if (self.host) |host_pattern| {
            if (!matchPattern(host_pattern, request.host)) return false;
        }

        // Check methods
        if (self.methods.len > 0) {
            var found = false;
            for (self.methods) |m| {
                if (m == request.method) {
                    found = true;
                    break;
                }
            }
            if (!found) return false;
        }

        // Check headers
        for (self.headers) |h| {
            const value = request.getHeader(h.name) orelse {
                if (h.required) return false;
                continue;
            };
            if (!matchPattern(h.pattern, value)) return false;
        }

        return true;
    }
};

pub const PathMatcher = struct {
    pattern: []const u8,
    match_type: MatchType = .prefix,

    pub fn matches(self: *const PathMatcher, path: []const u8) bool {
        return switch (self.match_type) {
            .exact => std.mem.eql(u8, path, self.pattern),
            .prefix => std.mem.startsWith(u8, path, self.pattern),
            .suffix => std.mem.endsWith(u8, path, self.pattern),
            .contains => std.mem.indexOf(u8, path, self.pattern) != null,
            .regex => false, // TODO: regex support
        };
    }
};

pub const HeaderMatcher = struct {
    name: []const u8,
    pattern: []const u8,
    required: bool = false,
};

// =============================================================================
// Route
// =============================================================================

pub const Route = struct {
    /// Route name for logging/metrics
    name: []const u8,
    /// Match conditions
    matcher: RouteMatcher,
    /// Target for matched requests
    target: RouteTarget,
    /// Enable request/response logging
    log_requests: bool = false,
    /// Rate limit (requests per second, 0 = unlimited)
    rate_limit: u32 = 0,
    /// Request timeout override (0 = use default)
    timeout_ms: u32 = 0,
};

// =============================================================================
// Router
// =============================================================================

pub const Router = struct {
    allocator: std.mem.Allocator,
    routes: std.ArrayListUnmanaged(Route) = .empty,
    default_backend: ?*BackendPool = null,

    pub fn init(allocator: std.mem.Allocator) Router {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *Router) void {
        self.routes.deinit(self.allocator);
    }

    /// Add a route
    pub fn addRoute(self: *Router, route: Route) !void {
        try self.routes.append(self.allocator, route);
        // Sort by priority (descending)
        std.mem.sort(Route, self.routes.items, {}, struct {
            fn lessThan(_: void, a: Route, b: Route) bool {
                return a.matcher.priority > b.matcher.priority;
            }
        }.lessThan);
    }

    /// Add a simple path prefix route to a backend
    pub fn addPrefix(self: *Router, path: []const u8, pool: *BackendPool) !void {
        try self.addRoute(.{
            .name = path,
            .matcher = .{
                .path = .{ .pattern = path, .match_type = .prefix },
            },
            .target = .{ .backend = pool },
        });
    }

    /// Add a WASM edge function route
    pub fn addWasm(self: *Router, path: []const u8, module_path: []const u8) !void {
        try self.addRoute(.{
            .name = path,
            .matcher = .{
                .path = .{ .pattern = path, .match_type = .prefix },
            },
            .target = .{ .wasm = .{ .module_path = module_path } },
        });
    }

    /// Set default backend for unmatched requests
    pub fn setDefault(self: *Router, pool: *BackendPool) void {
        self.default_backend = pool;
    }

    /// Match a request to a route
    pub fn match(self: *const Router, request: *const http.Request) ?*const Route {
        for (self.routes.items) |*route| {
            if (route.matcher.matches(request)) {
                return route;
            }
        }
        return null;
    }

    /// Get route target for a request
    pub fn getTarget(self: *const Router, request: *const http.Request) ?RouteTarget {
        if (self.match(request)) |route| {
            return route.target;
        }

        // Return default backend if set
        if (self.default_backend) |pool| {
            return .{ .backend = pool };
        }

        return null;
    }
};

// =============================================================================
// Helper Functions
// =============================================================================

fn matchPattern(pattern: []const u8, value: []const u8) bool {
    // Simple wildcard matching
    if (std.mem.eql(u8, pattern, "*")) return true;

    if (std.mem.indexOf(u8, pattern, "*")) |star_pos| {
        const prefix = pattern[0..star_pos];
        const suffix = pattern[star_pos + 1 ..];

        if (!std.mem.startsWith(u8, value, prefix)) return false;
        if (!std.mem.endsWith(u8, value, suffix)) return false;
        return true;
    }

    return std.mem.eql(u8, pattern, value);
}

// =============================================================================
// Tests
// =============================================================================

test "route matching - path prefix" {
    const allocator = std.testing.allocator;

    var router = Router.init(allocator);
    defer router.deinit();

    // Create a dummy pool
    var pool = BackendPool.init(allocator);
    defer pool.deinit();

    try router.addPrefix("/api/", &pool);

    const request_match = http.Request{
        .method = .GET,
        .path = "/api/users",
        .host = "example.com",
    };

    const request_no_match = http.Request{
        .method = .GET,
        .path = "/other/path",
        .host = "example.com",
    };

    try std.testing.expect(router.match(&request_match) != null);
    try std.testing.expect(router.match(&request_no_match) == null);
}

test "route matching - method filter" {
    const allocator = std.testing.allocator;

    var router = Router.init(allocator);
    defer router.deinit();

    var pool = BackendPool.init(allocator);
    defer pool.deinit();

    try router.addRoute(.{
        .name = "post-only",
        .matcher = .{
            .path = .{ .pattern = "/submit", .match_type = .exact },
            .methods = &.{ .POST, .PUT },
        },
        .target = .{ .backend = &pool },
    });

    const get_request = http.Request{ .method = .GET, .path = "/submit" };
    const post_request = http.Request{ .method = .POST, .path = "/submit" };

    try std.testing.expect(router.match(&get_request) == null);
    try std.testing.expect(router.match(&post_request) != null);
}

test "pattern matching" {
    try std.testing.expect(matchPattern("*", "anything"));
    try std.testing.expect(matchPattern("api.*", "api.example.com"));
    try std.testing.expect(matchPattern("*.example.com", "www.example.com"));
    try std.testing.expect(!matchPattern("api.*", "www.example.com"));
}
