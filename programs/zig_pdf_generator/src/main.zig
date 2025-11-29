//! Zig PDF Generator CLI
//!
//! Command-line interface for generating PDFs from JSON input.
//!
//! Usage:
//!   pdf-gen invoice.json output.pdf      Generate PDF from JSON file
//!   pdf-gen --stdin output.pdf           Read JSON from stdin
//!   pdf-gen --demo output.pdf            Generate demo invoice
//!   pdf-gen --help                        Show help

const std = @import("std");
const lib = @import("lib.zig");

const VERSION = "1.0.0";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        printUsage();
        return;
    }

    const cmd = args[1];

    if (std.mem.eql(u8, cmd, "--help") or std.mem.eql(u8, cmd, "-h")) {
        printUsage();
        return;
    }

    if (std.mem.eql(u8, cmd, "--version") or std.mem.eql(u8, cmd, "-v")) {
        std.debug.print("zig-pdf-generator {s}\n", .{VERSION});
        return;
    }

    if (std.mem.eql(u8, cmd, "--demo")) {
        if (args.len < 3) {
            std.debug.print("Error: Missing output file path\n", .{});
            printUsage();
            return;
        }
        try generateDemo(allocator, args[2]);
        return;
    }

    if (std.mem.eql(u8, cmd, "--stdin")) {
        if (args.len < 3) {
            std.debug.print("Error: Missing output file path\n", .{});
            printUsage();
            return;
        }
        try generateFromStdin(allocator, args[2]);
        return;
    }

    // Default: json_file output_file
    if (args.len < 3) {
        std.debug.print("Error: Missing output file path\n", .{});
        printUsage();
        return;
    }

    try generateFromFile(allocator, args[1], args[2]);
}

fn printUsage() void {
    std.debug.print(
        \\Zig PDF Generator v{s}
        \\
        \\Usage:
        \\  pdf-gen <input.json> <output.pdf>   Generate PDF from JSON file
        \\  pdf-gen --stdin <output.pdf>        Read JSON from stdin
        \\  pdf-gen --demo <output.pdf>         Generate demo invoice
        \\  pdf-gen --help                      Show this help
        \\  pdf-gen --version                   Show version
        \\
        \\JSON Format:
        \\  {{
        \\    "document_type": "invoice",
        \\    "company_name": "Your Company",
        \\    "company_address": "123 Business St",
        \\    "company_vat": "VAT123456",
        \\    "client_name": "Client Name",
        \\    "client_address": "456 Client Ave",
        \\    "invoice_number": "INV-001",
        \\    "invoice_date": "2025-11-29",
        \\    "items": [
        \\      {{"description": "Service", "quantity": 10, "unit_price": 100, "total": 1000}}
        \\    ],
        \\    "subtotal": 1000,
        \\    "tax_rate": 0.21,
        \\    "tax_amount": 210,
        \\    "total": 1210,
        \\    "primary_color": "#b39a7d"
        \\  }}
        \\
        \\Optional fields:
        \\  company_logo_base64    Base64-encoded PNG/JPEG logo
        \\  verifactu_qr_base64    Base64-encoded QR code
        \\  notes                  Footer notes
        \\  payment_terms          Payment terms text
        \\  display_mode           "itemized" or "blackbox"
        \\  template_style         "professional", "modern", "classic", "creative"
        \\
    , .{VERSION});
}

fn generateFromFile(allocator: std.mem.Allocator, json_path: []const u8, output_path: []const u8) !void {
    // Read JSON file
    const json_file = std.fs.cwd().openFile(json_path, .{}) catch |err| {
        std.debug.print("Error: Cannot open '{s}': {s}\n", .{ json_path, @errorName(err) });
        return;
    };
    defer json_file.close();

    // Get file size and read contents
    const file_stat = json_file.stat() catch |err| {
        std.debug.print("Error: Cannot stat file: {s}\n", .{@errorName(err)});
        return;
    };

    const file_size = file_stat.size;
    if (file_size > 10 * 1024 * 1024) {
        std.debug.print("Error: File too large (max 10MB)\n", .{});
        return;
    }

    const json_data = allocator.alloc(u8, file_size) catch |err| {
        std.debug.print("Error: Cannot allocate memory: {s}\n", .{@errorName(err)});
        return;
    };
    defer allocator.free(json_data);

    // Read file contents
    var total_read: usize = 0;
    while (total_read < file_size) {
        const bytes_read = json_file.read(json_data[total_read..]) catch |err| {
            std.debug.print("Error: Cannot read file: {s}\n", .{@errorName(err)});
            return;
        };
        if (bytes_read == 0) break;
        total_read += bytes_read;
    }

    try generatePdf(allocator, json_data[0..total_read], output_path);
    std.debug.print("Generated: {s}\n", .{output_path});
}

fn generateFromStdin(allocator: std.mem.Allocator, output_path: []const u8) !void {
    // Read from stdin using posix
    var buffer: std.ArrayListUnmanaged(u8) = .empty;
    defer buffer.deinit(allocator);

    var read_buf: [4096]u8 = undefined;
    while (true) {
        const bytes_read = std.posix.read(0, &read_buf) catch |err| {
            std.debug.print("Error: Cannot read stdin: {s}\n", .{@errorName(err)});
            return;
        };
        if (bytes_read == 0) break;
        try buffer.appendSlice(allocator, read_buf[0..bytes_read]);
    }

    try generatePdf(allocator, buffer.items, output_path);
    std.debug.print("Generated: {s}\n", .{output_path});
}

fn generatePdf(allocator: std.mem.Allocator, json_data: []const u8, output_path: []const u8) !void {
    // Parse JSON
    const data = lib.json.parseInvoiceJson(allocator, json_data) catch |err| {
        std.debug.print("Error: Invalid JSON: {s}\n", .{@errorName(err)});
        return;
    };
    defer lib.json.freeInvoiceData(allocator, &data);

    // Generate PDF
    const pdf_bytes = lib.generateInvoice(allocator, data) catch |err| {
        std.debug.print("Error: PDF generation failed: {s}\n", .{@errorName(err)});
        return;
    };
    defer allocator.free(pdf_bytes);

    // Write to file
    const file = std.fs.cwd().createFile(output_path, .{}) catch |err| {
        std.debug.print("Error: Cannot create '{s}': {s}\n", .{ output_path, @errorName(err) });
        return;
    };
    defer file.close();

    file.writeAll(pdf_bytes) catch |err| {
        std.debug.print("Error: Cannot write file: {s}\n", .{@errorName(err)});
        return;
    };
}

fn generateDemo(allocator: std.mem.Allocator, output_path: []const u8) !void {
    const items = [_]lib.LineItem{
        .{ .description = "Web Application Development", .quantity = 80, .unit_price = 125, .total = 10000 },
        .{ .description = "UI/UX Design Services", .quantity = 40, .unit_price = 100, .total = 4000 },
        .{ .description = "Server Infrastructure Setup", .quantity = 1, .unit_price = 2500, .total = 2500 },
        .{ .description = "Technical Documentation", .quantity = 16, .unit_price = 75, .total = 1200 },
        .{ .description = "Training Session (2 hours)", .quantity = 4, .unit_price = 200, .total = 800 },
    };

    const subtotal: f64 = 18500;
    const tax_rate: f64 = 0.21;
    const tax_amount: f64 = subtotal * tax_rate;
    const total: f64 = subtotal + tax_amount;

    const data = lib.InvoiceData{
        .document_type = "invoice",
        .company_name = "Quantum Code Labs",
        .company_address = "42 Innovation Drive, Tech Valley, CA 94025",
        .company_vat = "US-QCL-2025-001",
        .client_name = "Stellar Industries Inc.",
        .client_address = "789 Enterprise Blvd, Business Park, NY 10001",
        .client_vat = "US-STL-2024-555",
        .invoice_number = "QCL-2025-0001",
        .invoice_date = "2025-11-29",
        .due_date = "2025-12-29",
        .items = &items,
        .subtotal = subtotal,
        .tax_rate = tax_rate,
        .tax_amount = tax_amount,
        .total = total,
        .notes = "Thank you for choosing Quantum Code Labs! Payment can be made via bank transfer or credit card.",
        .payment_terms = "Net 30 - Payment due within 30 days of invoice date.",
        .primary_color = "#2563eb",
        .secondary_color = "#1e3a5f",
        .title_color = "#2563eb",
    };

    const pdf_bytes = try lib.generateInvoice(allocator, data);
    defer allocator.free(pdf_bytes);

    const file = try std.fs.cwd().createFile(output_path, .{});
    defer file.close();

    try file.writeAll(pdf_bytes);
    std.debug.print("Generated demo invoice: {s}\n", .{output_path});
    std.debug.print("  Company: {s}\n", .{data.company_name});
    std.debug.print("  Client: {s}\n", .{data.client_name});
    std.debug.print("  Total: ${d:.2}\n", .{total});
}
