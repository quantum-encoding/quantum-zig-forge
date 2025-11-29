const std = @import("std");
const lexer = @import("lexer.zig");
const objects = @import("objects.zig");
const filters = @import("filters.zig");
const Lexer = lexer.Lexer;
const Token = lexer.Token;
const Object = objects.Object;
const DictParser = objects.DictParser;

/// Cross-reference table entry
pub const XRefEntry = struct {
    offset: u64, // Byte offset in file (for 'n' entries)
    gen_num: u16, // Generation number
    in_use: bool, // true = 'n' (in use), false = 'f' (free)
    compressed: bool, // true if object is in an object stream
    stream_obj: u32, // If compressed: object number of containing stream
    stream_idx: u16, // If compressed: index within stream
};

/// XRef table - maps object numbers to file offsets
pub const XRefTable = struct {
    entries: std.AutoHashMap(u32, XRefEntry),
    trailer: TrailerInfo,
    allocator: std.mem.Allocator,

    pub const TrailerInfo = struct {
        size: u32, // Total number of objects
        root: objects.ObjectRef, // Catalog reference
        info: ?objects.ObjectRef, // Document info dict (optional)
        id: ?[2][]const u8, // File identifiers (optional)
        prev: ?u64, // Previous xref offset (for incremental updates)
        encrypt: ?objects.ObjectRef, // Encryption dict (optional)
    };

    pub const ParseError = error{
        UnexpectedEof,
        InvalidXref,
        InvalidNumber,
        InvalidXrefEntry,
        InvalidTrailer,
        MissingTrailerSize,
        MissingTrailerRoot,
        InvalidTrailerSize,
        InvalidTrailerRoot,
        XrefStreamNotImplemented,
        OutOfMemory,
        UnexpectedToken,
    };

    pub fn init(allocator: std.mem.Allocator) XRefTable {
        return .{
            .entries = std.AutoHashMap(u32, XRefEntry).init(allocator),
            .trailer = undefined,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *XRefTable) void {
        self.entries.deinit();
    }

    /// Get offset for an object
    pub fn getOffset(self: *const XRefTable, obj_num: u32) ?u64 {
        const entry = self.entries.get(obj_num) orelse return null;
        if (!entry.in_use or entry.compressed) return null;
        return entry.offset;
    }

    /// Get entry for an object
    pub fn getEntry(self: *const XRefTable, obj_num: u32) ?XRefEntry {
        return self.entries.get(obj_num);
    }

    /// Number of entries
    pub fn count(self: *const XRefTable) usize {
        return self.entries.count();
    }

    /// Parse xref from PDF data, starting from the end
    pub fn parse(allocator: std.mem.Allocator, data: []const u8) !XRefTable {
        var table = XRefTable.init(allocator);
        errdefer table.deinit();

        // Find startxref from end of file
        const startxref_offset = try findStartXref(data);
        const xref_offset = try parseStartXrefValue(data, startxref_offset);

        // Parse xref section(s)
        try table.parseXrefAt(data, xref_offset);

        return table;
    }

    fn parseXrefAt(self: *XRefTable, data: []const u8, offset: u64) ParseError!void {
        var lex = Lexer.initAt(data, @intCast(offset));

        const first_token = lex.next() orelse return error.UnexpectedEof;

        if (first_token.tag == .keyword_xref) {
            // Traditional xref table
            try self.parseTraditionalXref(&lex, data);
        } else if (first_token.tag == .number) {
            // Could be xref stream (PDF 1.5+)
            try self.parseXrefStream(&lex, data, first_token);
        } else {
            return error.InvalidXref;
        }
    }

    fn parseTraditionalXref(self: *XRefTable, lex: *Lexer, data: []const u8) ParseError!void {
        // Parse subsections: "start_obj count" followed by entries
        while (true) {
            const token = lex.next() orelse return error.UnexpectedEof;

            if (token.tag == .keyword_trailer) {
                // Parse trailer dictionary
                try self.parseTrailer(lex, data);
                return;
            }

            if (token.tag != .number) return error.InvalidXref;
            const start_obj = token.asInt() orelse return error.InvalidNumber;

            const count_token = lex.next() orelse return error.UnexpectedEof;
            if (count_token.tag != .number) return error.InvalidXref;
            const entry_count = count_token.asInt() orelse return error.InvalidNumber;

            // Parse entries
            var obj_num: u32 = @intCast(start_obj);
            var i: i64 = 0;
            while (i < entry_count) : (i += 1) {
                const offset_tok = lex.next() orelse return error.UnexpectedEof;
                const gen_tok = lex.next() orelse return error.UnexpectedEof;
                const type_tok = lex.next() orelse return error.UnexpectedEof;

                if (offset_tok.tag != .number or gen_tok.tag != .number) {
                    return error.InvalidXrefEntry;
                }

                const offset_val = offset_tok.asInt() orelse return error.InvalidNumber;
                const gen_val = gen_tok.asInt() orelse return error.InvalidNumber;

                const in_use = if (type_tok.tag == .name and type_tok.data.len > 0)
                    type_tok.data[type_tok.data.len - 1] == 'n'
                else if (type_tok.data.len > 0)
                    type_tok.data[0] == 'n'
                else
                    false;

                try self.entries.put(obj_num, .{
                    .offset = @intCast(offset_val),
                    .gen_num = @intCast(gen_val),
                    .in_use = in_use,
                    .compressed = false,
                    .stream_obj = 0,
                    .stream_idx = 0,
                });

                obj_num += 1;
            }
        }
    }

    fn parseXrefStream(self: *XRefTable, lex: *Lexer, data: []const u8, first_token: Token) ParseError!void {
        // xref stream: "obj_num gen_num obj << ... >> stream ... endstream endobj"
        _ = self;
        _ = first_token;
        _ = lex;
        _ = data;
        // TODO: Implement xref stream parsing for PDF 1.5+
        return error.XrefStreamNotImplemented;
    }

    fn parseTrailer(self: *XRefTable, lex: *Lexer, data: []const u8) ParseError!void {
        const obj = Object.parse(lex) catch return error.InvalidTrailer;

        switch (obj) {
            .dict => |dict_bytes| {
                var parser = DictParser.init(dict_bytes);

                // /Size (required)
                const size_obj = parser.get("Size") orelse return error.MissingTrailerSize;
                self.trailer.size = @intCast(size_obj.asInt() orelse return error.InvalidTrailerSize);

                // /Root (required)
                const root_obj = parser.get("Root") orelse return error.MissingTrailerRoot;
                self.trailer.root = root_obj.asRef() orelse return error.InvalidTrailerRoot;

                // /Info (optional)
                if (parser.get("Info")) |info_obj| {
                    self.trailer.info = info_obj.asRef();
                } else {
                    self.trailer.info = null;
                }

                // /Prev (optional - for incremental updates)
                if (parser.get("Prev")) |prev_obj| {
                    self.trailer.prev = @intCast(prev_obj.asInt() orelse 0);

                    // Parse previous xref table
                    if (self.trailer.prev) |prev_offset| {
                        try self.parseXrefAt(data, prev_offset);
                    }
                } else {
                    self.trailer.prev = null;
                }

                // /Encrypt (optional)
                if (parser.get("Encrypt")) |enc_obj| {
                    self.trailer.encrypt = enc_obj.asRef();
                } else {
                    self.trailer.encrypt = null;
                }

                // /ID (optional)
                self.trailer.id = null; // TODO: parse ID array
            },
            else => return error.InvalidTrailer,
        }
    }
};

/// Find "startxref" keyword from end of file
fn findStartXref(data: []const u8) !usize {
    // Search backwards from end (startxref is in last 1024 bytes typically)
    const search_len = @min(data.len, 1024);
    const search_start = data.len - search_len;
    const needle = "startxref";

    if (search_len < needle.len) return error.StartXrefNotFound;

    var i: usize = search_len - needle.len;
    while (true) {
        if (std.mem.eql(u8, data[search_start + i ..][0..needle.len], needle)) {
            return search_start + i;
        }
        if (i == 0) break;
        i -= 1;
    }
    return error.StartXrefNotFound;
}

/// Parse the offset value after "startxref"
fn parseStartXrefValue(data: []const u8, startxref_pos: usize) !u64 {
    var lex = Lexer.initAt(data, startxref_pos);

    // Skip "startxref" keyword
    const kw = lex.next() orelse return error.UnexpectedEof;
    if (kw.tag != .keyword_startxref) return error.InvalidStartXref;

    // Get offset
    const offset_token = lex.next() orelse return error.UnexpectedEof;
    if (offset_token.tag != .number) return error.InvalidStartXref;

    return @intCast(offset_token.asInt() orelse return error.InvalidNumber);
}

/// Find PDF version from header
pub fn findPdfVersion(data: []const u8) ?[]const u8 {
    // PDF header: %PDF-1.x
    if (data.len < 8) return null;
    if (!std.mem.startsWith(u8, data, "%PDF-")) return null;

    var end: usize = 5;
    while (end < @min(data.len, 10) and data[end] != '\n' and data[end] != '\r') {
        end += 1;
    }
    return data[5..end];
}

// === Tests ===

test "find startxref" {
    const data = "%PDF-1.4\n...content...\nstartxref\n12345\n%%EOF";
    const pos = try findStartXref(data);
    try std.testing.expect(std.mem.eql(u8, data[pos..][0..9], "startxref"));
}

test "parse startxref value" {
    const data = "startxref\n12345\n%%EOF";
    const offset = try parseStartXrefValue(data, 0);
    try std.testing.expectEqual(@as(u64, 12345), offset);
}

test "find PDF version" {
    const data = "%PDF-1.7\n";
    const version = findPdfVersion(data);
    try std.testing.expectEqualStrings("1.7", version.?);
}
