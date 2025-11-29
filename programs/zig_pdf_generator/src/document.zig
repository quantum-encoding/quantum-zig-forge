//! PDF Document Builder
//!
//! Low-level PDF-1.4 document writer with support for:
//! - Pages with content streams
//! - Text rendering with built-in fonts
//! - Image embedding (JPEG, PNG via raw embedding)
//! - Vector graphics (lines, rectangles, paths)
//! - Color support (RGB, grayscale)
//!
//! PDF Structure:
//! %PDF-1.4
//! 1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj
//! 2 0 obj << /Type /Pages /Kids [...] /Count N >> endobj
//! 3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [...] /Contents X 0 R /Resources << ... >> >> endobj
//! ...
//! xref
//! trailer
//! %%EOF

const std = @import("std");

// =============================================================================
// Constants
// =============================================================================

/// A4 page dimensions in points (72 points = 1 inch)
pub const A4_WIDTH: f32 = 595.276;
pub const A4_HEIGHT: f32 = 841.890;

/// Letter page dimensions
pub const LETTER_WIDTH: f32 = 612.0;
pub const LETTER_HEIGHT: f32 = 792.0;

/// Maximum objects in a PDF document
const MAX_OBJECTS = 1024;
const MAX_PAGES = 100;
const MAX_FONTS = 16;
const MAX_IMAGES = 64;

// =============================================================================
// PDF Object Types
// =============================================================================

pub const PageSize = struct {
    width: f32,
    height: f32,

    pub const a4 = PageSize{ .width = A4_WIDTH, .height = A4_HEIGHT };
    pub const letter = PageSize{ .width = LETTER_WIDTH, .height = LETTER_HEIGHT };
};

pub const Color = struct {
    r: f32, // 0.0 - 1.0
    g: f32,
    b: f32,

    pub const black = Color{ .r = 0, .g = 0, .b = 0 };
    pub const white = Color{ .r = 1, .g = 1, .b = 1 };
    pub const red = Color{ .r = 1, .g = 0, .b = 0 };
    pub const green = Color{ .r = 0, .g = 1, .b = 0 };
    pub const blue = Color{ .r = 0, .g = 0, .b = 1 };

    /// Parse hex color string like "#b39a7d" or "b39a7d"
    pub fn fromHex(hex: []const u8) Color {
        var start: usize = 0;
        if (hex.len > 0 and hex[0] == '#') {
            start = 1;
        }

        if (hex.len - start < 6) return Color.black;

        const r = std.fmt.parseInt(u8, hex[start .. start + 2], 16) catch 0;
        const g = std.fmt.parseInt(u8, hex[start + 2 .. start + 4], 16) catch 0;
        const b_val = std.fmt.parseInt(u8, hex[start + 4 .. start + 6], 16) catch 0;

        return Color{
            .r = @as(f32, @floatFromInt(r)) / 255.0,
            .g = @as(f32, @floatFromInt(g)) / 255.0,
            .b = @as(f32, @floatFromInt(b_val)) / 255.0,
        };
    }
};

pub const Font = enum {
    helvetica,
    helvetica_bold,
    helvetica_oblique,
    helvetica_bold_oblique,
    times_roman,
    times_bold,
    times_italic,
    times_bold_italic,
    courier,
    courier_bold,
    courier_oblique,
    courier_bold_oblique,

    pub fn pdfName(self: Font) []const u8 {
        return switch (self) {
            .helvetica => "Helvetica",
            .helvetica_bold => "Helvetica-Bold",
            .helvetica_oblique => "Helvetica-Oblique",
            .helvetica_bold_oblique => "Helvetica-BoldOblique",
            .times_roman => "Times-Roman",
            .times_bold => "Times-Bold",
            .times_italic => "Times-Italic",
            .times_bold_italic => "Times-BoldItalic",
            .courier => "Courier",
            .courier_bold => "Courier-Bold",
            .courier_oblique => "Courier-Oblique",
            .courier_bold_oblique => "Courier-BoldOblique",
        };
    }

    /// Get approximate character width for basic metrics (in 1/1000 of font size)
    pub fn avgCharWidth(self: Font) f32 {
        return switch (self) {
            .helvetica, .helvetica_oblique => 0.52,
            .helvetica_bold, .helvetica_bold_oblique => 0.55,
            .times_roman, .times_italic => 0.45,
            .times_bold, .times_bold_italic => 0.48,
            .courier, .courier_bold, .courier_oblique, .courier_bold_oblique => 0.60,
        };
    }
};

pub const TextAlign = enum {
    left,
    center,
    right,
};

// =============================================================================
// Image Support
// =============================================================================

pub const ImageFormat = enum {
    jpeg,
    png_rgb,
    png_rgba,
    raw_rgb,
    raw_rgba,
};

pub const Image = struct {
    width: u32,
    height: u32,
    format: ImageFormat,
    data: []const u8,
    object_id: u32 = 0,
};

// =============================================================================
// Content Stream Builder
// =============================================================================

pub const ContentStream = struct {
    buffer: std.ArrayListUnmanaged(u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ContentStream {
        return .{
            .buffer = .empty,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *ContentStream) void {
        self.buffer.deinit(self.allocator);
    }

    // -------------------------------------------------------------------------
    // Graphics State
    // -------------------------------------------------------------------------

    pub fn saveState(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "q\n");
    }

    pub fn restoreState(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "Q\n");
    }

    // -------------------------------------------------------------------------
    // Color Operations
    // -------------------------------------------------------------------------

    pub fn setFillColor(self: *ContentStream, color: Color) !void {
        var buf: [64]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.3} {d:.3} {d:.3} rg\n", .{ color.r, color.g, color.b }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    pub fn setStrokeColor(self: *ContentStream, color: Color) !void {
        var buf: [64]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.3} {d:.3} {d:.3} RG\n", .{ color.r, color.g, color.b }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    pub fn setLineWidth(self: *ContentStream, width: f32) !void {
        var buf: [32]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.2} w\n", .{width}) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    // -------------------------------------------------------------------------
    // Path Operations
    // -------------------------------------------------------------------------

    pub fn moveTo(self: *ContentStream, x: f32, y: f32) !void {
        var buf: [64]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.2} {d:.2} m\n", .{ x, y }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    pub fn lineTo(self: *ContentStream, x: f32, y: f32) !void {
        var buf: [64]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.2} {d:.2} l\n", .{ x, y }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    pub fn rect(self: *ContentStream, x: f32, y: f32, width: f32, height: f32) !void {
        var buf: [128]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.2} {d:.2} {d:.2} {d:.2} re\n", .{ x, y, width, height }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    pub fn stroke(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "S\n");
    }

    pub fn fill(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "f\n");
    }

    pub fn fillStroke(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "B\n");
    }

    pub fn closePath(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "h\n");
    }

    // -------------------------------------------------------------------------
    // Rectangle Helpers
    // -------------------------------------------------------------------------

    pub fn drawRect(self: *ContentStream, x: f32, y: f32, width: f32, height: f32, fill_color: ?Color, stroke_color: ?Color) !void {
        try self.saveState();

        if (fill_color) |fc| {
            try self.setFillColor(fc);
        }
        if (stroke_color) |sc| {
            try self.setStrokeColor(sc);
        }

        try self.rect(x, y, width, height);

        if (fill_color != null and stroke_color != null) {
            try self.fillStroke();
        } else if (fill_color != null) {
            try self.fill();
        } else {
            try self.stroke();
        }

        try self.restoreState();
    }

    pub fn drawLine(self: *ContentStream, x1: f32, y1: f32, x2: f32, y2: f32, color: Color, width: f32) !void {
        try self.saveState();
        try self.setStrokeColor(color);
        try self.setLineWidth(width);
        try self.moveTo(x1, y1);
        try self.lineTo(x2, y2);
        try self.stroke();
        try self.restoreState();
    }

    // -------------------------------------------------------------------------
    // Text Operations
    // -------------------------------------------------------------------------

    pub fn beginText(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "BT\n");
    }

    pub fn endText(self: *ContentStream) !void {
        try self.buffer.appendSlice(self.allocator, "ET\n");
    }

    pub fn setFont(self: *ContentStream, font_id: []const u8, size: f32) !void {
        var buf: [64]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "/{s} {d:.1} Tf\n", .{ font_id, size }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    pub fn setTextPosition(self: *ContentStream, x: f32, y: f32) !void {
        var buf: [64]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.2} {d:.2} Td\n", .{ x, y }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);
    }

    pub fn showText(self: *ContentStream, text: []const u8) !void {
        try self.buffer.append(self.allocator, '(');
        // Escape special PDF characters
        for (text) |c| {
            switch (c) {
                '(' => try self.buffer.appendSlice(self.allocator, "\\("),
                ')' => try self.buffer.appendSlice(self.allocator, "\\)"),
                '\\' => try self.buffer.appendSlice(self.allocator, "\\\\"),
                else => try self.buffer.append(self.allocator, c),
            }
        }
        try self.buffer.appendSlice(self.allocator, ") Tj\n");
    }

    /// Draw text at position with font
    pub fn drawText(self: *ContentStream, text: []const u8, x: f32, y: f32, font_id: []const u8, size: f32, color: Color) !void {
        try self.saveState();
        try self.setFillColor(color);
        try self.beginText();
        try self.setFont(font_id, size);
        try self.setTextPosition(x, y);
        try self.showText(text);
        try self.endText();
        try self.restoreState();
    }

    // -------------------------------------------------------------------------
    // Image Operations
    // -------------------------------------------------------------------------

    pub fn drawImage(self: *ContentStream, image_id: []const u8, x: f32, y: f32, width: f32, height: f32) !void {
        try self.saveState();
        // Transformation matrix: scale and translate
        var buf: [128]u8 = undefined;
        const len = std.fmt.bufPrint(&buf, "{d:.2} 0 0 {d:.2} {d:.2} {d:.2} cm\n", .{ width, height, x, y }) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len);

        var buf2: [32]u8 = undefined;
        const len2 = std.fmt.bufPrint(&buf2, "/{s} Do\n", .{image_id}) catch return error.BufferTooSmall;
        try self.buffer.appendSlice(self.allocator, len2);

        try self.restoreState();
    }

    pub fn getContent(self: *const ContentStream) []const u8 {
        return self.buffer.items;
    }
};

// =============================================================================
// PDF Document
// =============================================================================

pub const PdfDocument = struct {
    allocator: std.mem.Allocator,
    page_size: PageSize,

    // Object tracking
    objects: std.ArrayListUnmanaged([]u8),
    object_offsets: [MAX_OBJECTS]u32,
    next_object_id: u32,

    // Fonts
    font_ids: [MAX_FONTS]Font,
    font_count: u8,

    // Images
    images: [MAX_IMAGES]Image,
    image_count: u8,

    // Pages
    page_content_ids: [MAX_PAGES]u32,
    page_count: u8,

    // Output buffer
    output: std.ArrayListUnmanaged(u8),

    pub fn init(allocator: std.mem.Allocator) PdfDocument {
        return .{
            .allocator = allocator,
            .page_size = PageSize.a4,
            .objects = .empty,
            .object_offsets = [_]u32{0} ** MAX_OBJECTS,
            .next_object_id = 1,
            .font_ids = undefined,
            .font_count = 0,
            .images = undefined,
            .image_count = 0,
            .page_content_ids = undefined,
            .page_count = 0,
            .output = .empty,
        };
    }

    pub fn deinit(self: *PdfDocument) void {
        for (self.objects.items) |obj| {
            self.allocator.free(obj);
        }
        self.objects.deinit(self.allocator);
        self.output.deinit(self.allocator);
    }

    pub fn setPageSize(self: *PdfDocument, size: PageSize) void {
        self.page_size = size;
    }

    // -------------------------------------------------------------------------
    // Font Management
    // -------------------------------------------------------------------------

    pub fn addFont(self: *PdfDocument, font: Font) u8 {
        // Check if already added
        for (0..self.font_count) |i| {
            if (self.font_ids[i] == font) {
                return @intCast(i);
            }
        }

        if (self.font_count >= MAX_FONTS) return 0;

        self.font_ids[self.font_count] = font;
        const id = self.font_count;
        self.font_count += 1;
        return id;
    }

    pub fn getFontId(self: *PdfDocument, font: Font) []const u8 {
        const idx = self.addFont(font);
        // Return static string based on index
        return switch (idx) {
            0 => "F0",
            1 => "F1",
            2 => "F2",
            3 => "F3",
            4 => "F4",
            5 => "F5",
            6 => "F6",
            7 => "F7",
            else => "F0",
        };
    }

    // -------------------------------------------------------------------------
    // Image Management
    // -------------------------------------------------------------------------

    pub fn addImage(self: *PdfDocument, image: Image) ![]const u8 {
        if (self.image_count >= MAX_IMAGES) return error.TooManyImages;

        self.images[self.image_count] = image;
        const id = self.image_count;
        self.image_count += 1;

        return switch (id) {
            0 => "Im0",
            1 => "Im1",
            2 => "Im2",
            3 => "Im3",
            4 => "Im4",
            5 => "Im5",
            6 => "Im6",
            7 => "Im7",
            else => "Im0",
        };
    }

    // -------------------------------------------------------------------------
    // Page Management
    // -------------------------------------------------------------------------

    pub fn addPage(self: *PdfDocument, content: *ContentStream) !void {
        if (self.page_count >= MAX_PAGES) return error.TooManyPages;

        // Store content stream data for later
        const content_copy = try self.allocator.dupe(u8, content.getContent());
        try self.objects.append(self.allocator, content_copy);

        // Track page content (will be assigned object ID during build)
        self.page_content_ids[self.page_count] = @intCast(self.objects.items.len - 1);
        self.page_count += 1;
    }

    // -------------------------------------------------------------------------
    // Build PDF
    // -------------------------------------------------------------------------

    pub fn build(self: *PdfDocument) ![]const u8 {
        self.output.clearRetainingCapacity();

        // PDF Header
        try self.output.appendSlice(self.allocator, "%PDF-1.4\n");
        try self.output.appendSlice(self.allocator, "%\xE2\xE3\xCF\xD3\n"); // Binary marker

        // Object 1: Catalog
        const catalog_id = self.next_object_id;
        self.next_object_id += 1;
        try self.writeObject(catalog_id, "<< /Type /Catalog /Pages 2 0 R >>");

        // Object 2: Pages (placeholder, will update)
        const pages_id = self.next_object_id;
        self.next_object_id += 1;
        _ = self.output.items.len; // Offset tracked for potential future use

        // Build font dictionary
        var font_dict: std.ArrayListUnmanaged(u8) = .empty;
        defer font_dict.deinit(self.allocator);
        try font_dict.appendSlice(self.allocator, "<< ");
        for (0..self.font_count) |i| {
            var buf: [128]u8 = undefined;
            const font_obj_id = self.next_object_id + @as(u32, @intCast(i));
            const len = std.fmt.bufPrint(&buf, "/F{d} {d} 0 R ", .{ i, font_obj_id }) catch continue;
            try font_dict.appendSlice(self.allocator, len);
        }
        try font_dict.appendSlice(self.allocator, ">>");

        // Reserve object IDs for fonts
        const first_font_obj = self.next_object_id;
        self.next_object_id += self.font_count;

        // Build image dictionary (if any)
        var xobject_dict: std.ArrayListUnmanaged(u8) = .empty;
        defer xobject_dict.deinit(self.allocator);
        if (self.image_count > 0) {
            try xobject_dict.appendSlice(self.allocator, "<< ");
            for (0..self.image_count) |i| {
                var buf: [128]u8 = undefined;
                const img_obj_id = self.next_object_id + @as(u32, @intCast(i));
                const len = std.fmt.bufPrint(&buf, "/Im{d} {d} 0 R ", .{ i, img_obj_id }) catch continue;
                try xobject_dict.appendSlice(self.allocator, len);
            }
            try xobject_dict.appendSlice(self.allocator, ">>");
        }

        // Reserve object IDs for images
        const first_image_obj = self.next_object_id;
        self.next_object_id += self.image_count;

        // Build page objects
        var page_refs: std.ArrayListUnmanaged(u8) = .empty;
        defer page_refs.deinit(self.allocator);

        const first_page_obj = self.next_object_id;
        for (0..self.page_count) |i| {
            var buf: [32]u8 = undefined;
            const len = std.fmt.bufPrint(&buf, "{d} 0 R ", .{first_page_obj + @as(u32, @intCast(i)) * 2}) catch continue;
            try page_refs.appendSlice(self.allocator, len);
        }

        // Write Pages object
        {
            var buf: [256]u8 = undefined;
            const len = std.fmt.bufPrint(&buf, "<< /Type /Pages /Kids [ {s}] /Count {d} >>", .{ page_refs.items, self.page_count }) catch return error.BufferTooSmall;
            try self.writeObject(pages_id, len);
        }

        // Write Font objects
        for (0..self.font_count) |i| {
            var buf: [256]u8 = undefined;
            const len = std.fmt.bufPrint(&buf, "<< /Type /Font /Subtype /Type1 /BaseFont /{s} >>", .{self.font_ids[i].pdfName()}) catch continue;
            try self.writeObject(first_font_obj + @as(u32, @intCast(i)), len);
        }

        // Write Image objects
        for (0..self.image_count) |i| {
            const img = &self.images[i];
            try self.writeImageObject(first_image_obj + @as(u32, @intCast(i)), img);
        }

        // Write Page and Content Stream objects
        for (0..self.page_count) |i| {
            const page_obj_id = first_page_obj + @as(u32, @intCast(i)) * 2;
            const content_obj_id = page_obj_id + 1;

            // Build resources dictionary
            var resources: std.ArrayListUnmanaged(u8) = .empty;
            defer resources.deinit(self.allocator);
            try resources.appendSlice(self.allocator, "<< /Font ");
            try resources.appendSlice(self.allocator, font_dict.items);
            if (self.image_count > 0) {
                try resources.appendSlice(self.allocator, " /XObject ");
                try resources.appendSlice(self.allocator, xobject_dict.items);
            }
            try resources.appendSlice(self.allocator, " >>");

            // Page object
            var page_buf: [512]u8 = undefined;
            const page_len = std.fmt.bufPrint(&page_buf, "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 {d:.3} {d:.3}] /Contents {d} 0 R /Resources {s} >>", .{
                self.page_size.width,
                self.page_size.height,
                content_obj_id,
                resources.items,
            }) catch continue;
            try self.writeObject(page_obj_id, page_len);

            // Content stream object
            const content_data = self.objects.items[self.page_content_ids[i]];
            try self.writeStreamObject(content_obj_id, content_data);
        }

        // Update next_object_id
        self.next_object_id = first_page_obj + @as(u32, @intCast(self.page_count)) * 2;

        // Cross-reference table
        const xref_offset = self.output.items.len;
        try self.output.appendSlice(self.allocator, "xref\n");
        {
            var buf: [64]u8 = undefined;
            const len = std.fmt.bufPrint(&buf, "0 {d}\n", .{self.next_object_id}) catch return error.BufferTooSmall;
            try self.output.appendSlice(self.allocator, len);
        }
        try self.output.appendSlice(self.allocator, "0000000000 65535 f \n");

        for (1..self.next_object_id) |i| {
            var buf: [32]u8 = undefined;
            const len = std.fmt.bufPrint(&buf, "{d:0>10} 00000 n \n", .{self.object_offsets[i]}) catch continue;
            try self.output.appendSlice(self.allocator, len);
        }

        // Trailer
        try self.output.appendSlice(self.allocator, "trailer\n");
        {
            var buf: [128]u8 = undefined;
            const len = std.fmt.bufPrint(&buf, "<< /Size {d} /Root 1 0 R >>\n", .{self.next_object_id}) catch return error.BufferTooSmall;
            try self.output.appendSlice(self.allocator, len);
        }
        try self.output.appendSlice(self.allocator, "startxref\n");
        {
            var buf: [32]u8 = undefined;
            const len = std.fmt.bufPrint(&buf, "{d}\n", .{xref_offset}) catch return error.BufferTooSmall;
            try self.output.appendSlice(self.allocator, len);
        }
        try self.output.appendSlice(self.allocator, "%%EOF\n");

        return self.output.items;
    }

    fn writeObject(self: *PdfDocument, obj_id: u32, content: []const u8) !void {
        self.object_offsets[obj_id] = @intCast(self.output.items.len);

        var buf: [32]u8 = undefined;
        const header = std.fmt.bufPrint(&buf, "{d} 0 obj\n", .{obj_id}) catch return error.BufferTooSmall;
        try self.output.appendSlice(self.allocator, header);
        try self.output.appendSlice(self.allocator, content);
        try self.output.appendSlice(self.allocator, "\nendobj\n");
    }

    fn writeStreamObject(self: *PdfDocument, obj_id: u32, content: []const u8) !void {
        self.object_offsets[obj_id] = @intCast(self.output.items.len);

        var header_buf: [32]u8 = undefined;
        const header = std.fmt.bufPrint(&header_buf, "{d} 0 obj\n", .{obj_id}) catch return error.BufferTooSmall;
        try self.output.appendSlice(self.allocator, header);

        var len_buf: [64]u8 = undefined;
        const len_str = std.fmt.bufPrint(&len_buf, "<< /Length {d} >>\n", .{content.len}) catch return error.BufferTooSmall;
        try self.output.appendSlice(self.allocator, len_str);

        try self.output.appendSlice(self.allocator, "stream\n");
        try self.output.appendSlice(self.allocator, content);
        try self.output.appendSlice(self.allocator, "\nendstream\nendobj\n");
    }

    fn writeImageObject(self: *PdfDocument, obj_id: u32, image: *const Image) !void {
        self.object_offsets[obj_id] = @intCast(self.output.items.len);

        var header_buf: [32]u8 = undefined;
        const header = std.fmt.bufPrint(&header_buf, "{d} 0 obj\n", .{obj_id}) catch return error.BufferTooSmall;
        try self.output.appendSlice(self.allocator, header);

        // Image dictionary
        const color_space: []const u8 = switch (image.format) {
            .jpeg, .png_rgb, .raw_rgb => "/DeviceRGB",
            .png_rgba, .raw_rgba => "/DeviceRGB", // Alpha handled separately
        };

        const filter: []const u8 = switch (image.format) {
            .jpeg => "/DCTDecode",
            else => "", // Raw data, no filter
        };

        var dict_buf: [256]u8 = undefined;
        if (filter.len > 0) {
            const dict = std.fmt.bufPrint(&dict_buf, "<< /Type /XObject /Subtype /Image /Width {d} /Height {d} /ColorSpace {s} /BitsPerComponent 8 /Filter {s} /Length {d} >>", .{
                image.width,
                image.height,
                color_space,
                filter,
                image.data.len,
            }) catch return error.BufferTooSmall;
            try self.output.appendSlice(self.allocator, dict);
        } else {
            const dict = std.fmt.bufPrint(&dict_buf, "<< /Type /XObject /Subtype /Image /Width {d} /Height {d} /ColorSpace {s} /BitsPerComponent 8 /Length {d} >>", .{
                image.width,
                image.height,
                color_space,
                image.data.len,
            }) catch return error.BufferTooSmall;
            try self.output.appendSlice(self.allocator, dict);
        }

        try self.output.appendSlice(self.allocator, "\nstream\n");
        try self.output.appendSlice(self.allocator, image.data);
        try self.output.appendSlice(self.allocator, "\nendstream\nendobj\n");
    }
};

// =============================================================================
// Tests
// =============================================================================

test "create simple PDF" {
    const allocator = std.testing.allocator;

    var doc = PdfDocument.init(allocator);
    defer doc.deinit();

    _ = doc.addFont(.helvetica);
    _ = doc.addFont(.helvetica_bold);

    var content = ContentStream.init(allocator);
    defer content.deinit();

    try content.drawText("Hello, PDF!", 72, 750, "F0", 24, Color.black);
    try content.drawText("Generated with Zig", 72, 720, "F1", 14, Color.blue);
    try content.drawRect(72, 680, 200, 30, Color.fromHex("#f0f0f0"), Color.black);
    try content.drawLine(72, 650, 272, 650, Color.red, 1);

    try doc.addPage(&content);

    const pdf_bytes = try doc.build();
    try std.testing.expect(pdf_bytes.len > 100);
    try std.testing.expect(std.mem.startsWith(u8, pdf_bytes, "%PDF-1.4"));
}

test "color from hex" {
    const color = Color.fromHex("#b39a7d");
    try std.testing.expectApproxEqAbs(@as(f32, 0.702), color.r, 0.01);
    try std.testing.expectApproxEqAbs(@as(f32, 0.604), color.g, 0.01);
    try std.testing.expectApproxEqAbs(@as(f32, 0.490), color.b, 0.01);
}
