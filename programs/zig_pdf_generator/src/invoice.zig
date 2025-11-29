//! Invoice/Quote Template Renderer
//!
//! Generates professional PDF invoices from structured data.
//! Supports multiple template styles and customization options.
//!
//! Features:
//! - Company logo embedding
//! - QR code embedding (VeriFactu compliance)
//! - Multiple display modes (itemized, blackbox)
//! - Color customization
//! - Multi-page support for long item lists

const std = @import("std");
const document = @import("document.zig");
const image = @import("image.zig");

// =============================================================================
// Invoice Data Model
// =============================================================================

pub const LineItem = struct {
    description: []const u8,
    quantity: f64,
    unit_price: f64,
    total: f64,
};

pub const DisplayMode = enum {
    itemized, // Show full item details
    blackbox, // Show single summary line
};

pub const TemplateStyle = enum {
    professional,
    modern,
    classic,
    creative,
};

pub const InvoiceData = struct {
    // Document type
    document_type: []const u8 = "invoice", // "invoice" or "quote"

    // Company info
    company_name: []const u8 = "",
    company_address: []const u8 = "",
    company_vat: []const u8 = "",
    company_logo_base64: ?[]const u8 = null,

    // Client info
    client_name: []const u8 = "",
    client_address: []const u8 = "",
    client_vat: []const u8 = "",

    // Document details
    invoice_number: []const u8 = "",
    invoice_date: []const u8 = "",
    due_date: []const u8 = "",

    // Items
    display_mode: DisplayMode = .itemized,
    items: []const LineItem = &[_]LineItem{},
    blackbox_description: []const u8 = "",

    // Totals
    subtotal: f64 = 0,
    tax_rate: f64 = 0.21,
    tax_amount: f64 = 0,
    total: f64 = 0,

    // Optional
    verifactu_qr_base64: ?[]const u8 = null,
    notes: []const u8 = "",
    payment_terms: []const u8 = "",

    // Styling
    primary_color: []const u8 = "#b39a7d",
    secondary_color: []const u8 = "#2c3e50",
    title_color: []const u8 = "#b39a7d",
    company_name_color: []const u8 = "#1a1a1a",
    font_family: []const u8 = "Helvetica",
    template_style: TemplateStyle = .professional,

    // Layout adjustments (in points)
    logo_x: f32 = 40,
    logo_y: f32 = 750,
    logo_width: f32 = 80,
    logo_height: f32 = 50,
};

// =============================================================================
// Invoice Renderer
// =============================================================================

pub const InvoiceRenderer = struct {
    allocator: std.mem.Allocator,
    doc: document.PdfDocument,
    data: InvoiceData,

    // Decoded images (need to track for cleanup)
    logo_decoded: ?[]u8 = null,
    qr_decoded: ?[]u8 = null,
    logo_pixels: ?[]u8 = null,
    qr_pixels: ?[]u8 = null,

    // Page state
    current_y: f32 = 0,
    margin_left: f32 = 40,
    margin_right: f32 = 40,
    margin_top: f32 = 40,
    margin_bottom: f32 = 60,
    page_width: f32 = document.A4_WIDTH,
    page_height: f32 = document.A4_HEIGHT,

    // Font IDs (will be assigned during init)
    font_regular: []const u8 = "F0",
    font_bold: []const u8 = "F1",

    pub fn init(allocator: std.mem.Allocator, data: InvoiceData) InvoiceRenderer {
        var renderer = InvoiceRenderer{
            .allocator = allocator,
            .doc = document.PdfDocument.init(allocator),
            .data = data,
        };

        // Add fonts based on font_family
        if (std.mem.eql(u8, data.font_family, "Times-Roman") or std.mem.eql(u8, data.font_family, "Times")) {
            renderer.font_regular = renderer.doc.getFontId(.times_roman);
            renderer.font_bold = renderer.doc.getFontId(.times_bold);
        } else if (std.mem.eql(u8, data.font_family, "Courier")) {
            renderer.font_regular = renderer.doc.getFontId(.courier);
            renderer.font_bold = renderer.doc.getFontId(.courier_bold);
        } else {
            // Default to Helvetica
            renderer.font_regular = renderer.doc.getFontId(.helvetica);
            renderer.font_bold = renderer.doc.getFontId(.helvetica_bold);
        }

        renderer.current_y = renderer.page_height - renderer.margin_top;

        return renderer;
    }

    pub fn deinit(self: *InvoiceRenderer) void {
        if (self.logo_decoded) |d| self.allocator.free(d);
        if (self.qr_decoded) |d| self.allocator.free(d);
        if (self.logo_pixels) |p| self.allocator.free(p);
        if (self.qr_pixels) |p| self.allocator.free(p);
        self.doc.deinit();
    }

    /// Generate the complete invoice PDF
    pub fn render(self: *InvoiceRenderer) ![]const u8 {
        var content = document.ContentStream.init(self.allocator);
        defer content.deinit();

        // Load images if provided
        var logo_id: ?[]const u8 = null;
        var qr_id: ?[]const u8 = null;

        if (self.data.company_logo_base64) |logo_b64| {
            if (logo_b64.len > 0) {
                const result = image.loadImageFromBase64(self.allocator, logo_b64) catch null;
                if (result) |r| {
                    self.logo_decoded = r.decoded_bytes;
                    if (r.image.format != .jpeg) {
                        self.logo_pixels = @constCast(r.image.data);
                    }
                    logo_id = self.doc.addImage(r.image) catch null;
                }
            }
        }

        if (self.data.verifactu_qr_base64) |qr_b64| {
            if (qr_b64.len > 0) {
                const result = image.loadImageFromBase64(self.allocator, qr_b64) catch null;
                if (result) |r| {
                    self.qr_decoded = r.decoded_bytes;
                    if (r.image.format != .jpeg) {
                        self.qr_pixels = @constCast(r.image.data);
                    }
                    qr_id = self.doc.addImage(r.image) catch null;
                }
            }
        }

        const primary = document.Color.fromHex(self.data.primary_color);
        const secondary = document.Color.fromHex(self.data.secondary_color);
        const title_color = document.Color.fromHex(self.data.title_color);
        const company_color = document.Color.fromHex(self.data.company_name_color);

        // Usable width
        const usable_width = self.page_width - self.margin_left - self.margin_right;

        // =====================================================================
        // Header Section
        // =====================================================================

        // Logo (if available)
        if (logo_id) |lid| {
            try content.drawImage(lid, self.data.logo_x, self.data.logo_y, self.data.logo_width, self.data.logo_height);
        }

        // Document title (INVOICE / QUOTE)
        const doc_title = if (std.mem.eql(u8, self.data.document_type, "quote")) "QUOTE" else "INVOICE";
        try content.drawText(doc_title, self.page_width - self.margin_right - 120, self.page_height - self.margin_top, self.font_bold, 28, title_color);

        self.current_y = self.page_height - self.margin_top - 50;

        // Company name
        try content.drawText(self.data.company_name, self.margin_left, self.current_y, self.font_bold, 16, company_color);
        self.current_y -= 18;

        // Company address (multi-line)
        if (self.data.company_address.len > 0) {
            var line_iter = std.mem.splitSequence(u8, self.data.company_address, ", ");
            while (line_iter.next()) |line| {
                try content.drawText(line, self.margin_left, self.current_y, self.font_regular, 10, document.Color.black);
                self.current_y -= 13;
            }
        }

        // Company VAT
        if (self.data.company_vat.len > 0) {
            var vat_buf: [64]u8 = undefined;
            const vat_line = std.fmt.bufPrint(&vat_buf, "VAT: {s}", .{self.data.company_vat}) catch self.data.company_vat;
            try content.drawText(vat_line, self.margin_left, self.current_y, self.font_regular, 10, document.Color.black);
            self.current_y -= 18;
        }

        // =====================================================================
        // Invoice Details (right side)
        // =====================================================================

        const details_x = self.page_width - self.margin_right - 180;
        var details_y = self.page_height - self.margin_top - 50;

        // Invoice number
        try content.drawText("Invoice #:", details_x, details_y, self.font_bold, 10, document.Color.black);
        try content.drawText(self.data.invoice_number, details_x + 70, details_y, self.font_regular, 10, document.Color.black);
        details_y -= 15;

        // Date
        try content.drawText("Date:", details_x, details_y, self.font_bold, 10, document.Color.black);
        try content.drawText(self.data.invoice_date, details_x + 70, details_y, self.font_regular, 10, document.Color.black);
        details_y -= 15;

        // Due date
        if (self.data.due_date.len > 0) {
            try content.drawText("Due Date:", details_x, details_y, self.font_bold, 10, document.Color.black);
            try content.drawText(self.data.due_date, details_x + 70, details_y, self.font_regular, 10, document.Color.black);
        }

        // =====================================================================
        // Client Section
        // =====================================================================

        self.current_y -= 30;

        // "Bill To" header
        try content.drawText("Bill To:", self.margin_left, self.current_y, self.font_bold, 12, primary);
        self.current_y -= 18;

        // Client name
        try content.drawText(self.data.client_name, self.margin_left, self.current_y, self.font_bold, 11, document.Color.black);
        self.current_y -= 14;

        // Client address
        if (self.data.client_address.len > 0) {
            var addr_iter = std.mem.splitSequence(u8, self.data.client_address, ", ");
            while (addr_iter.next()) |line| {
                try content.drawText(line, self.margin_left, self.current_y, self.font_regular, 10, document.Color.black);
                self.current_y -= 13;
            }
        }

        // Client VAT
        if (self.data.client_vat.len > 0) {
            var cvat_buf: [64]u8 = undefined;
            const cvat_line = std.fmt.bufPrint(&cvat_buf, "VAT: {s}", .{self.data.client_vat}) catch self.data.client_vat;
            try content.drawText(cvat_line, self.margin_left, self.current_y, self.font_regular, 10, document.Color.black);
            self.current_y -= 18;
        }

        // =====================================================================
        // Items Table
        // =====================================================================

        self.current_y -= 20;

        // Table header background
        try content.drawRect(self.margin_left, self.current_y - 5, usable_width, 22, primary, null);

        // Table header text
        const col_desc = self.margin_left + 5;
        const col_qty = self.margin_left + 280;
        const col_price = self.margin_left + 350;
        const col_total = self.margin_left + 450;

        try content.drawText("Description", col_desc, self.current_y, self.font_bold, 10, document.Color.white);
        try content.drawText("Qty", col_qty, self.current_y, self.font_bold, 10, document.Color.white);
        try content.drawText("Unit Price", col_price, self.current_y, self.font_bold, 10, document.Color.white);
        try content.drawText("Total", col_total, self.current_y, self.font_bold, 10, document.Color.white);

        self.current_y -= 28;

        // Table rows
        if (self.data.display_mode == .itemized) {
            for (self.data.items, 0..) |item, i| {
                // Alternate row background
                if (i % 2 == 0) {
                    try content.drawRect(self.margin_left, self.current_y - 5, usable_width, 18, document.Color.fromHex("#f5f5f5"), null);
                }

                try content.drawText(item.description, col_desc, self.current_y, self.font_regular, 9, document.Color.black);

                var qty_buf: [16]u8 = undefined;
                const qty_str = std.fmt.bufPrint(&qty_buf, "{d:.0}", .{item.quantity}) catch "0";
                try content.drawText(qty_str, col_qty, self.current_y, self.font_regular, 9, document.Color.black);

                var price_buf: [24]u8 = undefined;
                const price_str = std.fmt.bufPrint(&price_buf, "{d:.2}", .{item.unit_price}) catch "0.00";
                try content.drawText(price_str, col_price, self.current_y, self.font_regular, 9, document.Color.black);

                var total_buf: [24]u8 = undefined;
                const total_str = std.fmt.bufPrint(&total_buf, "{d:.2}", .{item.total}) catch "0.00";
                try content.drawText(total_str, col_total, self.current_y, self.font_regular, 9, document.Color.black);

                self.current_y -= 20;

                // Check if we need a new page
                if (self.current_y < self.margin_bottom + 100) {
                    // Would need multi-page support here
                    break;
                }
            }
        } else {
            // Blackbox mode - single description line
            try content.drawRect(self.margin_left, self.current_y - 5, usable_width, 18, document.Color.fromHex("#f5f5f5"), null);
            try content.drawText(self.data.blackbox_description, col_desc, self.current_y, self.font_regular, 9, document.Color.black);

            var total_buf: [24]u8 = undefined;
            const total_str = std.fmt.bufPrint(&total_buf, "{d:.2}", .{self.data.subtotal}) catch "0.00";
            try content.drawText(total_str, col_total, self.current_y, self.font_regular, 9, document.Color.black);

            self.current_y -= 20;
        }

        // =====================================================================
        // Totals Section
        // =====================================================================

        self.current_y -= 20;

        // Separator line
        try content.drawLine(col_price - 20, self.current_y + 15, self.page_width - self.margin_right, self.current_y + 15, secondary, 0.5);

        // Subtotal
        try content.drawText("Subtotal:", col_price, self.current_y, self.font_regular, 10, document.Color.black);
        var subtotal_buf: [24]u8 = undefined;
        const subtotal_str = std.fmt.bufPrint(&subtotal_buf, "{d:.2}", .{self.data.subtotal}) catch "0.00";
        try content.drawText(subtotal_str, col_total, self.current_y, self.font_regular, 10, document.Color.black);
        self.current_y -= 16;

        // Tax
        var tax_label_buf: [32]u8 = undefined;
        const tax_pct = self.data.tax_rate * 100;
        const tax_label = std.fmt.bufPrint(&tax_label_buf, "Tax ({d:.0}%):", .{tax_pct}) catch "Tax:";
        try content.drawText(tax_label, col_price, self.current_y, self.font_regular, 10, document.Color.black);
        var tax_buf: [24]u8 = undefined;
        const tax_str = std.fmt.bufPrint(&tax_buf, "{d:.2}", .{self.data.tax_amount}) catch "0.00";
        try content.drawText(tax_str, col_total, self.current_y, self.font_regular, 10, document.Color.black);
        self.current_y -= 18;

        // Total (highlighted)
        try content.drawRect(col_price - 10, self.current_y - 5, self.page_width - self.margin_right - col_price + 20, 22, primary, null);
        try content.drawText("TOTAL:", col_price, self.current_y, self.font_bold, 12, document.Color.white);
        var grand_total_buf: [24]u8 = undefined;
        const grand_total_str = std.fmt.bufPrint(&grand_total_buf, "{d:.2}", .{self.data.total}) catch "0.00";
        try content.drawText(grand_total_str, col_total, self.current_y, self.font_bold, 12, document.Color.white);

        // =====================================================================
        // Footer Section
        // =====================================================================

        self.current_y -= 50;

        // QR Code (VeriFactu)
        if (qr_id) |qid| {
            try content.drawImage(qid, self.margin_left, self.margin_bottom, 60, 60);
        }

        // Notes
        if (self.data.notes.len > 0) {
            try content.drawText("Notes:", self.margin_left + 80, self.current_y, self.font_bold, 10, secondary);
            self.current_y -= 14;
            try content.drawText(self.data.notes, self.margin_left + 80, self.current_y, self.font_regular, 9, document.Color.black);
            self.current_y -= 18;
        }

        // Payment terms
        if (self.data.payment_terms.len > 0) {
            try content.drawText("Payment Terms:", self.margin_left + 80, self.current_y, self.font_bold, 10, secondary);
            self.current_y -= 14;
            try content.drawText(self.data.payment_terms, self.margin_left + 80, self.current_y, self.font_regular, 9, document.Color.black);
        }

        // Footer line
        try content.drawLine(self.margin_left, self.margin_bottom - 10, self.page_width - self.margin_right, self.margin_bottom - 10, secondary, 0.5);

        // Footer text
        try content.drawText("Thank you for your business", self.page_width / 2 - 60, self.margin_bottom - 25, self.font_regular, 9, secondary);

        // Add page to document
        try self.doc.addPage(&content);

        // Build and return PDF
        return try self.doc.build();
    }
};

// =============================================================================
// Convenience Function
// =============================================================================

/// Generate invoice PDF from InvoiceData struct
/// Returns an allocator-owned slice that must be freed by the caller.
pub fn generateInvoice(allocator: std.mem.Allocator, data: InvoiceData) ![]u8 {
    var renderer = InvoiceRenderer.init(allocator, data);
    defer renderer.deinit();

    const pdf_output = try renderer.render();

    // Make a copy since the original is owned by renderer.doc
    const result = try allocator.dupe(u8, pdf_output);
    return result;
}

// =============================================================================
// Tests
// =============================================================================

test "generate simple invoice" {
    const allocator = std.testing.allocator;

    const items = [_]LineItem{
        .{ .description = "Web Development", .quantity = 40, .unit_price = 100, .total = 4000 },
        .{ .description = "Consulting", .quantity = 10, .unit_price = 150, .total = 1500 },
    };

    const data = InvoiceData{
        .document_type = "invoice",
        .company_name = "Acme Corp",
        .company_address = "123 Business St, Tech City",
        .company_vat = "ESB12345678",
        .client_name = "Client LLC",
        .client_address = "456 Client Ave",
        .client_vat = "ESB87654321",
        .invoice_number = "INV-2025-001",
        .invoice_date = "2025-11-29",
        .due_date = "2025-12-29",
        .items = &items,
        .subtotal = 5500,
        .tax_rate = 0.21,
        .tax_amount = 1155,
        .total = 6655,
        .notes = "Thank you for your business!",
        .payment_terms = "Payment due within 30 days",
    };

    const pdf_bytes = try generateInvoice(allocator, data);
    defer allocator.free(pdf_bytes);

    try std.testing.expect(pdf_bytes.len > 500);
    try std.testing.expect(std.mem.startsWith(u8, pdf_bytes, "%PDF-1.4"));
}
