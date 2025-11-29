const std = @import("std");
const posix = std.posix;
const lexer = @import("lexer.zig");
const xref = @import("xref.zig");
const objects = @import("objects.zig");
const filters = @import("filters.zig");

const Lexer = lexer.Lexer;
const XRefTable = xref.XRefTable;
const Object = objects.Object;
const ObjectRef = objects.ObjectRef;
const DictParser = objects.DictParser;

/// PDF Document - zero-copy memory-mapped reader
pub const Document = struct {
    data: []align(4096) const u8,
    fd: posix.fd_t,
    size: usize,
    xref_table: XRefTable,
    version: []const u8,
    allocator: std.mem.Allocator,

    pub const OpenError = error{
        FileNotFound,
        AccessDenied,
        MmapFailed,
        InvalidPdf,
        StartXrefNotFound,
        InvalidStartXref,
        InvalidXref,
        InvalidTrailer,
        MissingTrailerSize,
        MissingTrailerRoot,
        InvalidTrailerSize,
        InvalidTrailerRoot,
        UnexpectedEof,
        InvalidNumber,
        InvalidXrefEntry,
        XrefStreamNotImplemented,
        OutOfMemory,
        Streaming,
        UnexpectedToken,
    } || posix.OpenError || posix.MMapError || posix.FStatError;

    /// Open a PDF file (memory-mapped)
    pub fn open(allocator: std.mem.Allocator, path: []const u8) OpenError!Document {
        // Open file
        const fd = try posix.open(path, .{ .ACCMODE = .RDONLY }, 0);
        errdefer posix.close(fd);

        // Get file size
        const stat = try posix.fstat(fd);
        const size: usize = @intCast(stat.size);

        if (size < 8) return error.InvalidPdf;

        // Memory map the file (read-only, private mapping)
        const linux = std.os.linux;
        const data = try posix.mmap(
            null,
            size,
            linux.PROT.READ,
            .{ .TYPE = .PRIVATE },
            fd,
            0,
        );

        errdefer posix.munmap(data);

        // Verify PDF header
        if (!std.mem.startsWith(u8, data, "%PDF-")) {
            return error.InvalidPdf;
        }

        // Get version
        const version = xref.findPdfVersion(data) orelse "1.0";

        // Parse xref table
        var xref_table = try XRefTable.parse(allocator, data);
        errdefer xref_table.deinit();

        return Document{
            .data = data,
            .fd = fd,
            .size = size,
            .xref_table = xref_table,
            .version = version,
            .allocator = allocator,
        };
    }

    /// Close the document
    pub fn close(self: *Document) void {
        self.xref_table.deinit();
        posix.munmap(self.data);
        posix.close(self.fd);
    }

    /// Get PDF version string (e.g., "1.7")
    pub fn getVersion(self: *const Document) []const u8 {
        return self.version;
    }

    /// Get file size in bytes
    pub fn getFileSize(self: *const Document) usize {
        return self.size;
    }

    /// Get number of objects in xref
    pub fn getObjectCount(self: *const Document) usize {
        return self.xref_table.count();
    }

    /// Get the catalog (root) object
    pub fn getCatalog(self: *Document) !Object {
        return self.resolveRef(self.xref_table.trailer.root);
    }

    /// Get document info dictionary (if present)
    pub fn getInfo(self: *Document) !?DocumentInfo {
        const info_ref = self.xref_table.trailer.info orelse return null;
        const obj = try self.resolveRef(info_ref);

        switch (obj) {
            .dict => |dict_bytes| {
                var parser = DictParser.init(dict_bytes);
                return DocumentInfo{
                    .title = getStringValue(&parser, "Title"),
                    .author = getStringValue(&parser, "Author"),
                    .subject = getStringValue(&parser, "Subject"),
                    .keywords = getStringValue(&parser, "Keywords"),
                    .creator = getStringValue(&parser, "Creator"),
                    .producer = getStringValue(&parser, "Producer"),
                    .creation_date = getStringValue(&parser, "CreationDate"),
                    .mod_date = getStringValue(&parser, "ModDate"),
                };
            },
            else => return null,
        }
    }

    /// Get number of pages
    pub fn getPageCount(self: *Document) !u32 {
        const catalog = try self.getCatalog();

        switch (catalog) {
            .dict => |dict_bytes| {
                var parser = DictParser.init(dict_bytes);

                // Get /Pages reference
                const pages_obj = parser.get("Pages") orelse return error.MissingPages;
                const pages_ref = pages_obj.asRef() orelse return error.InvalidPages;

                // Resolve Pages object
                const pages = try self.resolveRef(pages_ref);

                switch (pages) {
                    .dict => |pages_bytes| {
                        var pages_parser = DictParser.init(pages_bytes);
                        const count_obj = pages_parser.get("Count") orelse return error.MissingPageCount;
                        return @intCast(count_obj.asInt() orelse return error.InvalidPageCount);
                    },
                    else => return error.InvalidPages,
                }
            },
            else => return error.InvalidCatalog,
        }
    }

    /// Check if document is encrypted
    pub fn isEncrypted(self: *const Document) bool {
        return self.xref_table.trailer.encrypt != null;
    }

    /// Resolve an indirect object reference
    pub fn resolveRef(self: *Document, ref: ObjectRef) !Object {
        const offset = self.xref_table.getOffset(ref.obj_num) orelse return error.ObjectNotFound;

        var lex = Lexer.initAt(self.data, @intCast(offset));

        // Parse "obj_num gen_num obj"
        const obj_num_tok = lex.next() orelse return error.UnexpectedEof;
        if (obj_num_tok.tag != .number) return error.InvalidObject;

        const gen_tok = lex.next() orelse return error.UnexpectedEof;
        if (gen_tok.tag != .number) return error.InvalidObject;

        const obj_tok = lex.next() orelse return error.UnexpectedEof;
        if (obj_tok.tag != .keyword_obj) return error.InvalidObject;

        // Parse the actual object
        return Object.parse(&lex);
    }

    /// Get raw stream data for an object (decompressed if needed)
    pub fn getStreamData(self: *Document, ref: ObjectRef) ![]u8 {
        const obj = try self.resolveRef(ref);

        switch (obj) {
            .stream => |stream| {
                // Check for filters
                var parser = DictParser.init(stream.dict);

                if (parser.get("Filter")) |filter_obj| {
                    const filter_name = filter_obj.asName() orelse return error.InvalidFilter;

                    if (std.mem.eql(u8, filter_name, "FlateDecode")) {
                        return filters.FlateDecode.decode(self.allocator, stream.data);
                    } else if (std.mem.eql(u8, filter_name, "ASCII85Decode")) {
                        return filters.Ascii85Decode.decode(self.allocator, stream.data);
                    } else if (std.mem.eql(u8, filter_name, "ASCIIHexDecode")) {
                        return filters.AsciiHexDecode.decode(self.allocator, stream.data);
                    } else {
                        return error.UnsupportedFilter;
                    }
                }

                // No filter - return copy of raw data
                const copy = try self.allocator.alloc(u8, stream.data.len);
                @memcpy(copy, stream.data);
                return copy;
            },
            else => return error.NotAStream,
        }
    }

    fn getStringValue(parser: *DictParser, key: []const u8) ?[]const u8 {
        const obj = parser.get(key) orelse return null;
        return obj.asString();
    }
};

/// Document metadata from /Info dictionary
pub const DocumentInfo = struct {
    title: ?[]const u8,
    author: ?[]const u8,
    subject: ?[]const u8,
    keywords: ?[]const u8,
    creator: ?[]const u8,
    producer: ?[]const u8,
    creation_date: ?[]const u8,
    mod_date: ?[]const u8,

    pub fn format(self: DocumentInfo, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        if (self.title) |t| try writer.print("Title: {s}\n", .{t});
        if (self.author) |a| try writer.print("Author: {s}\n", .{a});
        if (self.subject) |s| try writer.print("Subject: {s}\n", .{s});
        if (self.keywords) |k| try writer.print("Keywords: {s}\n", .{k});
        if (self.creator) |c| try writer.print("Creator: {s}\n", .{c});
        if (self.producer) |p| try writer.print("Producer: {s}\n", .{p});
        if (self.creation_date) |d| try writer.print("Created: {s}\n", .{formatPdfDate(d)});
        if (self.mod_date) |d| try writer.print("Modified: {s}\n", .{formatPdfDate(d)});
    }
};

/// Format PDF date string (D:YYYYMMDDHHmmSS) to human readable
fn formatPdfDate(date: []const u8) []const u8 {
    // TODO: Parse and reformat D:YYYYMMDDHHmmSSOHH'mm' format
    // For now just strip the D: prefix if present
    if (std.mem.startsWith(u8, date, "D:")) {
        return date[2..];
    }
    return date;
}

/// Utility to print human-readable file size
pub fn formatFileSize(size: usize) struct { value: f64, unit: []const u8 } {
    if (size >= 1024 * 1024 * 1024) {
        return .{ .value = @as(f64, @floatFromInt(size)) / (1024 * 1024 * 1024), .unit = "GB" };
    } else if (size >= 1024 * 1024) {
        return .{ .value = @as(f64, @floatFromInt(size)) / (1024 * 1024), .unit = "MB" };
    } else if (size >= 1024) {
        return .{ .value = @as(f64, @floatFromInt(size)) / 1024, .unit = "KB" };
    } else {
        return .{ .value = @as(f64, @floatFromInt(size)), .unit = "bytes" };
    }
}
