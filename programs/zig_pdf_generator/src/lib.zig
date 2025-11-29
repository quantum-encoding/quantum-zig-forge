//! Zig PDF Generator Library
//!
//! High-performance PDF generation library with C FFI for cross-platform use.
//!
//! Features:
//! - Professional invoice/quote templates
//! - Image embedding (PNG, JPEG, Base64)
//! - Color customization
//! - Multiple template styles
//! - Zero-copy where possible
//!
//! Usage (Zig):
//! ```zig
//! const invoice = @import("zigpdf").invoice;
//!
//! const data = invoice.InvoiceData{
//!     .company_name = "Acme Corp",
//!     .invoice_number = "INV-001",
//!     // ...
//! };
//!
//! const pdf_bytes = try invoice.generateInvoice(allocator, data);
//! defer allocator.free(pdf_bytes);
//! ```
//!
//! Usage (C/FFI):
//! ```c
//! #include "zigpdf.h"
//!
//! size_t len;
//! uint8_t* pdf = zigpdf_generate_invoice(json_str, &len);
//! if (pdf) {
//!     // Use pdf bytes...
//!     zigpdf_free(pdf, len);
//! }
//! ```

pub const document = @import("document.zig");
pub const invoice = @import("invoice.zig");
pub const image = @import("image.zig");
pub const json = @import("json.zig");
pub const ffi = @import("ffi.zig");

// Re-export key types
pub const PdfDocument = document.PdfDocument;
pub const ContentStream = document.ContentStream;
pub const Color = document.Color;
pub const Font = document.Font;
pub const PageSize = document.PageSize;
pub const Image = document.Image;

pub const InvoiceData = invoice.InvoiceData;
pub const LineItem = invoice.LineItem;
pub const InvoiceRenderer = invoice.InvoiceRenderer;
pub const generateInvoice = invoice.generateInvoice;

// FFI exports (for shared library)
pub const zigpdf_generate_invoice = ffi.zigpdf_generate_invoice;
pub const zigpdf_generate_simple = ffi.zigpdf_generate_simple;
pub const zigpdf_generate_invoice_to_file = ffi.zigpdf_generate_invoice_to_file;
pub const zigpdf_generate_invoice_jni = ffi.zigpdf_generate_invoice_jni;
pub const zigpdf_free = ffi.zigpdf_free;
pub const zigpdf_get_error = ffi.zigpdf_get_error;
pub const zigpdf_version = ffi.zigpdf_version;

// =============================================================================
// Tests
// =============================================================================

test {
    // Run all module tests
    _ = document;
    _ = invoice;
    _ = image;
    _ = json;
    _ = ffi;
}

test "library integration" {
    const std = @import("std");
    const allocator = std.testing.allocator;

    // Create invoice data
    const items = [_]LineItem{
        .{ .description = "Consulting", .quantity = 8, .unit_price = 150, .total = 1200 },
    };

    const data = InvoiceData{
        .company_name = "Quantum Zig Labs",
        .company_address = "123 Code Street, Zig City",
        .company_vat = "US123456789",
        .client_name = "Happy Customer",
        .client_address = "456 Client Road",
        .invoice_number = "QZL-2025-001",
        .invoice_date = "2025-11-29",
        .items = &items,
        .subtotal = 1200,
        .tax_rate = 0.10,
        .tax_amount = 120,
        .total = 1320,
        .primary_color = "#3498db",
        .notes = "Generated with Zig PDF Generator",
    };

    // Generate PDF
    const pdf_bytes = try generateInvoice(allocator, data);
    defer allocator.free(pdf_bytes);

    // Verify PDF structure
    try std.testing.expect(pdf_bytes.len > 1000);
    try std.testing.expect(std.mem.startsWith(u8, pdf_bytes, "%PDF-1.4"));
    try std.testing.expect(std.mem.endsWith(u8, pdf_bytes, "%%EOF\n"));

    // Verify content includes key text
    try std.testing.expect(std.mem.indexOf(u8, pdf_bytes, "Quantum Zig Labs") != null);
    try std.testing.expect(std.mem.indexOf(u8, pdf_bytes, "QZL-2025-001") != null);
}
