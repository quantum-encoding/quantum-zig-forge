const std = @import("std");
const posix = std.posix;
const lexer = @import("lexer.zig");
const xref = @import("xref.zig");
const objects = @import("objects.zig");
const filters = @import("filters.zig");
const text_extract = @import("extract/text.zig");
const page_mod = @import("page.zig");

const Lexer = lexer.Lexer;
const XRefTable = xref.XRefTable;
const Object = objects.Object;
const ObjectRef = objects.ObjectRef;
const DictParser = objects.DictParser;
const TextExtractor = text_extract.TextExtractor;
const Page = page_mod.Page;
const PageTree = page_mod.PageTree;

/// PDF Document - zero-copy memory-mapped reader
pub const Document = struct {
    data: []align(4096) const u8,
    fd: posix.fd_t,
    size: usize,
    xref_table: XRefTable,
    version: []const u8,
    allocator: std.mem.Allocator,

    // Cache for decompressed object streams (keyed by stream object number)
    objstm_cache: std.AutoHashMap(u32, []u8),

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
        InvalidXrefStream,
        InvalidXrefStreamW,
        InvalidXrefStreamIndex,
        XrefDecompressFailed,
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
            .objstm_cache = std.AutoHashMap(u32, []u8).init(allocator),
        };
    }

    /// Close the document
    pub fn close(self: *Document) void {
        // Free cached object stream data
        var iter = self.objstm_cache.valueIterator();
        while (iter.next()) |cached_data| {
            self.allocator.free(cached_data.*);
        }
        self.objstm_cache.deinit();
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

    /// Get the Pages tree root reference
    fn getPagesRef(self: *Document) !ObjectRef {
        const catalog = try self.getCatalog();
        switch (catalog) {
            .dict => |dict_bytes| {
                var parser = DictParser.init(dict_bytes);
                const pages_obj = parser.get("Pages") orelse return error.MissingPages;
                return pages_obj.asRef() orelse error.InvalidPages;
            },
            else => return error.InvalidCatalog,
        }
    }

    /// Create a function pointer for xref lookup (used by Page/PageTree)
    fn makeXrefGetter(self: *Document) *const fn (u32) ?u64 {
        // We need to capture self in a static way for the function pointer.
        // Since Zig doesn't support closures, we use a workaround with
        // thread-local storage for the document pointer.
        const Wrapper = struct {
            threadlocal var doc: ?*Document = null;

            fn getOffset(obj_num: u32) ?u64 {
                const d = doc orelse return null;
                return d.xref_table.getOffset(obj_num);
            }
        };
        Wrapper.doc = self;
        return &Wrapper.getOffset;
    }

    /// Get a specific page by index (0-based)
    pub fn getPage(self: *Document, page_index: usize) !Page {
        // Build page tree to find the page
        const pages_ref = try self.getPagesRef();
        var tree = PageTree.init(self.allocator, self.data, self.makeXrefGetter());
        defer tree.deinit();

        try tree.buildPageList(pages_ref);

        if (tree.getPage(page_index)) |p| {
            return p;
        }
        return error.PageNotFound;
    }

    /// Extract text from a specific page (0-based index)
    pub fn extractPageText(self: *Document, page_index: usize) ![]u8 {
        // Get page dictionary reference
        const page_ref = try self.getPageRef(page_index);
        const page_obj = try self.resolveRef(page_ref);

        switch (page_obj) {
            .dict => |dict_bytes| {
                // Get content stream
                const content_data = try self.getPageContentStream(dict_bytes);
                defer self.allocator.free(content_data);

                // Extract text
                var extractor = text_extract.TextExtractor.init(self.allocator);
                return extractor.extract(content_data);
            },
            else => return error.InvalidObject,
        }
    }

    /// Get page reference by index - traverses page tree properly handling compressed objects
    fn getPageRef(self: *Document, page_index: usize) !ObjectRef {
        const pages_ref = try self.getPagesRef();

        // Build list of page refs by traversing the tree
        var page_refs = std.ArrayList(ObjectRef).empty;
        defer page_refs.deinit(self.allocator);

        try self.traversePageTree(pages_ref, &page_refs);

        if (page_index >= page_refs.items.len) return error.PageNotFound;
        return page_refs.items[page_index];
    }

    /// Error set for page tree traversal
    const PageTreeError = error{OutOfMemory};

    /// Recursively traverse the page tree collecting page references
    fn traversePageTree(self: *Document, node_ref: ObjectRef, page_refs: *std.ArrayList(ObjectRef)) PageTreeError!void {
        const node_obj = self.resolveRef(node_ref) catch return;

        switch (node_obj) {
            .dict => |dict_bytes| {
                var parser = DictParser.init(dict_bytes);

                // Check /Type
                const type_obj = parser.get("Type") orelse return;
                const type_name = type_obj.asName() orelse return;

                if (std.mem.eql(u8, type_name, "Pages")) {
                    // Intermediate node - recurse into /Kids
                    const kids_obj = parser.get("Kids") orelse return;
                    switch (kids_obj) {
                        .array => |kids_bytes| {
                            try self.traversePageKids(kids_bytes, page_refs);
                        },
                        else => {},
                    }
                } else if (std.mem.eql(u8, type_name, "Page")) {
                    // Leaf node - add to list
                    try page_refs.append(self.allocator, node_ref);
                }
            },
            else => {},
        }
    }

    /// Parse Kids array and recurse
    fn traversePageKids(self: *Document, kids_bytes: []const u8, page_refs: *std.ArrayList(ObjectRef)) !void {
        var lex = Lexer.init(kids_bytes);

        while (true) {
            const num_tok = lex.next() orelse break;
            if (num_tok.tag != .number) continue;

            const gen_tok = lex.next() orelse break;
            if (gen_tok.tag != .number) continue;

            const r_tok = lex.next() orelse break;
            if (r_tok.tag != .keyword_ref) continue;

            const ref = ObjectRef{
                .obj_num = @intCast(num_tok.asInt() orelse continue),
                .gen_num = @intCast(gen_tok.asInt() orelse continue),
            };

            try self.traversePageTree(ref, page_refs);
        }
    }

    /// Get decompressed content stream for a page dictionary
    fn getPageContentStream(self: *Document, page_dict: []const u8) ![]u8 {
        var parser = DictParser.init(page_dict);

        const contents_obj = parser.get("Contents") orelse return error.NoContents;

        switch (contents_obj) {
            .reference => |ref| {
                return self.getDecompressedStream(ref);
            },
            .array => |array_bytes| {
                return self.concatenateContentStreams(array_bytes);
            },
            else => return error.InvalidContents,
        }
    }

    /// Get decompressed stream data for a reference
    fn getDecompressedStream(self: *Document, ref: ObjectRef) ![]u8 {
        const obj = try self.resolveRef(ref);

        switch (obj) {
            .stream => |stream| {
                var stream_parser = DictParser.init(stream.dict);

                if (stream_parser.get("Filter")) |filter_obj| {
                    const filter_name = filter_obj.asName() orelse return self.allocator.dupe(u8, stream.data);

                    if (std.mem.eql(u8, filter_name, "FlateDecode")) {
                        return filters.FlateDecode.decode(self.allocator, stream.data);
                    } else if (std.mem.eql(u8, filter_name, "ASCII85Decode")) {
                        return filters.Ascii85Decode.decode(self.allocator, stream.data);
                    } else if (std.mem.eql(u8, filter_name, "ASCIIHexDecode")) {
                        return filters.AsciiHexDecode.decode(self.allocator, stream.data);
                    }
                }

                return self.allocator.dupe(u8, stream.data);
            },
            else => return error.NotAStream,
        }
    }

    /// Concatenate multiple content streams
    fn concatenateContentStreams(self: *Document, array_bytes: []const u8) ![]u8 {
        var result = std.ArrayList(u8).empty;
        errdefer result.deinit(self.allocator);

        var lex = Lexer.init(array_bytes);

        while (true) {
            const num_tok = lex.next() orelse break;
            if (num_tok.tag != .number) continue;

            const gen_tok = lex.next() orelse break;
            if (gen_tok.tag != .number) continue;

            const r_tok = lex.next() orelse break;
            if (r_tok.tag != .keyword_ref) continue;

            const ref = ObjectRef{
                .obj_num = @intCast(num_tok.asInt() orelse continue),
                .gen_num = @intCast(gen_tok.asInt() orelse continue),
            };

            const stream_data = self.getDecompressedStream(ref) catch continue;
            defer self.allocator.free(stream_data);

            try result.appendSlice(self.allocator, stream_data);
            try result.append(self.allocator, '\n');
        }

        return result.toOwnedSlice(self.allocator);
    }

    /// Extract text from all pages
    pub fn extractAllText(self: *Document) ![]u8 {
        const page_count = try self.getPageCount();
        var result = std.ArrayList(u8).empty;
        errdefer result.deinit(self.allocator);

        for (0..page_count) |i| {
            const text = self.extractPageText(i) catch |err| {
                // Skip pages that fail to extract
                std.debug.print("Warning: Failed to extract page {d}: {}\n", .{ i + 1, err });
                continue;
            };
            defer self.allocator.free(text);

            try result.appendSlice(self.allocator, text);

            // Add page separator if not last page
            if (i < page_count - 1) {
                try result.appendSlice(self.allocator, "\n\n--- Page ");
                var buf: [16]u8 = undefined;
                const num_str = std.fmt.bufPrint(&buf, "{d}", .{i + 2}) catch "?";
                try result.appendSlice(self.allocator, num_str);
                try result.appendSlice(self.allocator, " ---\n\n");
            }
        }

        return result.toOwnedSlice(self.allocator);
    }

    /// Resolve an indirect object reference
    pub fn resolveRef(self: *Document, ref: ObjectRef) !Object {
        const entry = self.xref_table.getEntry(ref.obj_num) orelse return error.ObjectNotFound;

        if (!entry.in_use) return error.ObjectNotFound;

        if (entry.compressed) {
            // Object is in an object stream - extract it
            return self.resolveCompressedObject(entry.stream_obj, entry.stream_idx);
        }

        // Regular uncompressed object
        var lex = Lexer.initAt(self.data, @intCast(entry.offset));

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

    /// Resolve an object from an object stream
    fn resolveCompressedObject(self: *Document, stream_obj_num: u32, obj_index: u16) !Object {
        // Check cache first
        const cached_data = self.objstm_cache.get(stream_obj_num) orelse blk: {
            // Not cached - decompress and cache the object stream
            const stream_entry = self.xref_table.getEntry(stream_obj_num) orelse return error.ObjectNotFound;
            if (stream_entry.compressed) return error.InvalidObject; // Object streams can't be nested

            var lex = Lexer.initAt(self.data, @intCast(stream_entry.offset));

            // Skip "obj_num gen_num obj"
            _ = lex.next(); // obj_num
            _ = lex.next(); // gen_num
            _ = lex.next(); // obj

            const stream_obj = Object.parse(&lex) catch return error.InvalidObject;

            switch (stream_obj) {
                .stream => |stream| {
                    // Decompress and cache
                    const decompressed = try self.decompressAndCacheObjStm(stream_obj_num, stream.dict, stream.data);
                    break :blk decompressed;
                },
                else => return error.InvalidObject,
            }
        };

        // Now extract the object from the cached decompressed data
        return self.extractFromCachedObjStm(cached_data, obj_index);
    }

    /// Decompress object stream and add to cache
    fn decompressAndCacheObjStm(self: *Document, stream_obj_num: u32, dict_bytes: []const u8, stream_data: []const u8) ![]u8 {
        var parser = DictParser.init(dict_bytes);

        // Decompress if filtered
        const data = blk: {
            if (parser.get("Filter")) |filter_obj| {
                const filter_name = filter_obj.asName() orelse break :blk try self.allocator.dupe(u8, stream_data);
                if (std.mem.eql(u8, filter_name, "FlateDecode")) {
                    break :blk filters.FlateDecode.decode(self.allocator, stream_data) catch return error.InvalidObject;
                }
            }
            break :blk try self.allocator.dupe(u8, stream_data);
        };

        // Store in cache
        try self.objstm_cache.put(stream_obj_num, data);
        return data;
    }

    /// Extract an object from cached object stream data
    fn extractFromCachedObjStm(self: *Document, data: []const u8, obj_index: u16) !Object {
        // Object stream format: "obj1_num obj1_off obj2_num obj2_off ... [actual objects starting at /First]"
        // The offsets in the header are relative to where objects start

        var header_lex = Lexer.init(data);
        var obj_offsets = std.ArrayList(struct { num: u32, off: usize }).empty;
        defer obj_offsets.deinit(self.allocator);

        // Read all object number/offset pairs
        // Keep track of where the header ends (after all number pairs)
        var last_valid_pos: usize = 0;

        while (true) {
            // Save position before reading
            const before_num = header_lex.getPosition();

            const num_tok = header_lex.next() orelse break;
            if (num_tok.tag != .number) {
                // We've gone past the header - backtrack
                break;
            }

            const off_tok = header_lex.next() orelse break;
            if (off_tok.tag != .number) break;

            try obj_offsets.append(self.allocator, .{
                .num = @intCast(num_tok.asInt() orelse 0),
                .off = @intCast(off_tok.asInt() orelse 0),
            });

            last_valid_pos = header_lex.getPosition();
            _ = before_num;
        }

        if (obj_index >= obj_offsets.items.len) return error.ObjectNotFound;

        // The 'first' value in the original dict tells us where objects start
        // Since we don't have it cached, we use the position after reading all header pairs
        // But the offsets in the header are already relative to /First, so we use last_valid_pos
        const first = last_valid_pos;
        const target_offset = obj_offsets.items[obj_index].off;

        const obj_start = first + target_offset;
        if (obj_start >= data.len) return error.InvalidObject;

        var obj_lex = Lexer.init(data[obj_start..]);
        return Object.parse(&obj_lex);
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
