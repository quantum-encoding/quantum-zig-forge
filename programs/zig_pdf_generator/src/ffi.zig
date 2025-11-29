//! C Foreign Function Interface (FFI)
//!
//! Exposes the PDF generator to C/C++, Kotlin (JNI), Swift, and Rust.
//! This interface allows Android and iOS apps to generate PDFs by:
//! 1. Passing quote data as JSON string
//! 2. Receiving PDF bytes back
//!
//! Memory Management:
//! - Input strings are borrowed (caller owns)
//! - Output bytes are allocated by Zig, caller must free with zigpdf_free()
//!
//! Usage from C:
//! ```c
//! const char* json = "{...}";
//! size_t pdf_len = 0;
//! uint8_t* pdf = zigpdf_generate_invoice(json, &pdf_len);
//! if (pdf) {
//!     // Use PDF bytes...
//!     zigpdf_free(pdf, pdf_len);
//! }
//! ```
//!
//! Usage from Kotlin (JNI):
//! ```kotlin
//! external fun generateInvoice(json: String): ByteArray?
//! ```

const std = @import("std");
const json_parser = @import("json.zig");
const invoice = @import("invoice.zig");
const document = @import("document.zig");

// =============================================================================
// Global Allocator for FFI
// =============================================================================

/// Use the C allocator for FFI compatibility
const ffi_allocator = std.heap.c_allocator;

// =============================================================================
// Error Codes
// =============================================================================

pub const ZigPdfError = enum(c_int) {
    success = 0,
    invalid_json = -1,
    render_failed = -2,
    out_of_memory = -3,
    invalid_argument = -4,
};

// =============================================================================
// Result Buffer
// =============================================================================

/// Thread-local storage for error message
var last_error: [256]u8 = undefined;
var last_error_len: usize = 0;

fn setLastError(msg: []const u8) void {
    const copy_len = @min(msg.len, last_error.len - 1);
    @memcpy(last_error[0..copy_len], msg[0..copy_len]);
    last_error[copy_len] = 0;
    last_error_len = copy_len;
}

// =============================================================================
// Core FFI Functions
// =============================================================================

/// Generate an invoice PDF from JSON input
///
/// Parameters:
/// - json_input: Null-terminated JSON string containing invoice data
/// - output_len: Pointer to receive the length of the output PDF
///
/// Returns:
/// - Pointer to PDF bytes on success (caller must free with zigpdf_free)
/// - NULL on error (call zigpdf_get_error for details)
export fn zigpdf_generate_invoice(json_input: [*:0]const u8, output_len: *usize) ?[*]u8 {
    const json_slice = std.mem.span(json_input);

    // Parse JSON to InvoiceData
    const data = json_parser.parseInvoiceJson(ffi_allocator, json_slice) catch |err| {
        var buf: [128]u8 = undefined;
        const msg = std.fmt.bufPrint(&buf, "JSON parse error: {s}", .{@errorName(err)}) catch "JSON parse error";
        setLastError(msg);
        return null;
    };
    defer json_parser.freeInvoiceData(ffi_allocator, &data);

    // Generate PDF
    const pdf_bytes = invoice.generateInvoice(ffi_allocator, data) catch |err| {
        var buf: [128]u8 = undefined;
        const msg = std.fmt.bufPrint(&buf, "PDF generation error: {s}", .{@errorName(err)}) catch "PDF generation error";
        setLastError(msg);
        return null;
    };

    output_len.* = pdf_bytes.len;
    return @ptrCast(pdf_bytes.ptr);
}

/// Generate a simple PDF document (for testing)
///
/// Parameters:
/// - title: Document title (null-terminated)
/// - body: Document body text (null-terminated)
/// - output_len: Pointer to receive output length
///
/// Returns:
/// - Pointer to PDF bytes on success
/// - NULL on error
export fn zigpdf_generate_simple(
    title: [*:0]const u8,
    body: [*:0]const u8,
    output_len: *usize,
) ?[*]u8 {
    const title_slice = std.mem.span(title);
    const body_slice = std.mem.span(body);

    var doc = document.PdfDocument.init(ffi_allocator);
    defer doc.deinit();

    _ = doc.addFont(.helvetica);
    _ = doc.addFont(.helvetica_bold);

    var content = document.ContentStream.init(ffi_allocator);
    defer content.deinit();

    // Title
    content.drawText(title_slice, 72, 750, "F1", 24, document.Color.black) catch {
        setLastError("Failed to draw title");
        return null;
    };

    // Body
    content.drawText(body_slice, 72, 700, "F0", 12, document.Color.black) catch {
        setLastError("Failed to draw body");
        return null;
    };

    doc.addPage(&content) catch {
        setLastError("Failed to add page");
        return null;
    };

    const pdf_bytes = doc.build() catch {
        setLastError("Failed to build PDF");
        return null;
    };

    // Copy to C-allocated buffer
    const result = ffi_allocator.alloc(u8, pdf_bytes.len) catch {
        setLastError("Out of memory");
        return null;
    };
    @memcpy(result, pdf_bytes);

    output_len.* = result.len;
    return result.ptr;
}

/// Free memory allocated by zigpdf functions
///
/// Must be called for every non-NULL return from zigpdf_generate_*
export fn zigpdf_free(ptr: ?[*]u8, len: usize) void {
    if (ptr) |p| {
        ffi_allocator.free(p[0..len]);
    }
}

/// Get the last error message
///
/// Returns: Null-terminated error string (valid until next zigpdf call)
export fn zigpdf_get_error() [*:0]const u8 {
    return @ptrCast(&last_error);
}

/// Get library version
export fn zigpdf_version() [*:0]const u8 {
    return "1.0.0";
}

// =============================================================================
// Convenience Functions
// =============================================================================

/// Generate invoice and write directly to file
///
/// Parameters:
/// - json_input: Null-terminated JSON string
/// - output_path: Null-terminated file path
///
/// Returns: Error code
export fn zigpdf_generate_invoice_to_file(
    json_input: [*:0]const u8,
    output_path: [*:0]const u8,
) ZigPdfError {
    var len: usize = 0;
    const pdf_ptr = zigpdf_generate_invoice(json_input, &len);

    if (pdf_ptr == null) {
        return .invalid_json;
    }
    defer zigpdf_free(pdf_ptr, len);

    const path_slice = std.mem.span(output_path);
    const pdf_data = pdf_ptr.?[0..len];

    const file = std.fs.createFileAbsolute(path_slice, .{}) catch {
        setLastError("Failed to create output file");
        return .render_failed;
    };
    defer file.close();

    file.writeAll(pdf_data) catch {
        setLastError("Failed to write PDF data");
        return .render_failed;
    };

    return .success;
}

// =============================================================================
// JNI Helper (Android)
// =============================================================================

/// JNI-friendly wrapper that returns a newly allocated buffer
/// The buffer includes a 4-byte length prefix for easy Java/Kotlin parsing
///
/// Buffer format: [4 bytes length (big endian)][PDF data]
export fn zigpdf_generate_invoice_jni(json_input: [*:0]const u8, total_len: *usize) ?[*]u8 {
    var pdf_len: usize = 0;
    const pdf_ptr = zigpdf_generate_invoice(json_input, &pdf_len);

    if (pdf_ptr == null) {
        return null;
    }

    // Allocate buffer with length prefix
    const result = ffi_allocator.alloc(u8, pdf_len + 4) catch {
        zigpdf_free(pdf_ptr, pdf_len);
        setLastError("Out of memory for JNI buffer");
        return null;
    };

    // Write length as big-endian 32-bit
    result[0] = @truncate(pdf_len >> 24);
    result[1] = @truncate(pdf_len >> 16);
    result[2] = @truncate(pdf_len >> 8);
    result[3] = @truncate(pdf_len);

    // Copy PDF data
    @memcpy(result[4..], pdf_ptr.?[0..pdf_len]);

    zigpdf_free(pdf_ptr, pdf_len);

    total_len.* = pdf_len + 4;
    return result.ptr;
}

// =============================================================================
// Tests
// =============================================================================

test "FFI simple document generation" {
    var len: usize = 0;
    const result = zigpdf_generate_simple("Test Title", "Test body text", &len);

    if (result) |ptr| {
        defer zigpdf_free(ptr, len);
        try std.testing.expect(len > 100);
        try std.testing.expect(ptr[0] == '%');
        try std.testing.expect(ptr[1] == 'P');
        try std.testing.expect(ptr[2] == 'D');
        try std.testing.expect(ptr[3] == 'F');
    } else {
        // If this fails, print the error
        const err = zigpdf_get_error();
        std.debug.print("Error: {s}\n", .{std.mem.span(err)});
        try std.testing.expect(false);
    }
}
