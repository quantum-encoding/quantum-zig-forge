//! JSON Parser for Invoice Data
//!
//! Parses JSON input matching the frontend's invoiceData format:
//! ```json
//! {
//!   "document_type": "invoice",
//!   "company_name": "Acme Corp",
//!   "company_address": "123 Business St",
//!   "company_vat": "ESB12345678",
//!   "company_logo_base64": "data:image/png;base64,...",
//!   "client_name": "Client LLC",
//!   "client_address": "456 Client Ave",
//!   "client_vat": "ESB87654321",
//!   "invoice_number": "INV-2025-001",
//!   "invoice_date": "2025-11-29",
//!   "due_date": "2025-12-29",
//!   "display_mode": "itemized",
//!   "items": [
//!     {"description": "Service", "quantity": 10, "unit_price": 100, "total": 1000}
//!   ],
//!   "blackbox_description": "",
//!   "subtotal": 1000,
//!   "tax_rate": 0.21,
//!   "tax_amount": 210,
//!   "total": 1210,
//!   "verifactu_qr_base64": "data:image/png;base64,...",
//!   "notes": "Thank you",
//!   "payment_terms": "30 days",
//!   "primary_color": "#b39a7d",
//!   "secondary_color": "#2c3e50",
//!   "title_color": "#b39a7d",
//!   "company_name_color": "#1a1a1a",
//!   "font_family": "Helvetica"
//! }
//! ```

const std = @import("std");
const invoice = @import("invoice.zig");

pub const JsonError = error{
    InvalidJson,
    MissingField,
    InvalidType,
    OutOfMemory,
};

// =============================================================================
// JSON Parsing
// =============================================================================

/// Parse JSON string to InvoiceData
pub fn parseInvoiceJson(allocator: std.mem.Allocator, json_str: []const u8) !invoice.InvoiceData {
    const parsed = std.json.parseFromSlice(std.json.Value, allocator, json_str, .{}) catch {
        return error.InvalidJson;
    };
    defer parsed.deinit();

    return parseInvoiceFromValue(allocator, parsed.value);
}

/// Parse InvoiceData from parsed JSON value
fn parseInvoiceFromValue(allocator: std.mem.Allocator, root: std.json.Value) !invoice.InvoiceData {
    if (root != .object) return error.InvalidJson;

    const obj = root.object;

    var data = invoice.InvoiceData{};

    // Parse string fields
    data.document_type = try dupeJsonString(allocator, obj, "document_type") orelse "invoice";
    data.company_name = try dupeJsonString(allocator, obj, "company_name") orelse "";
    data.company_address = try dupeJsonString(allocator, obj, "company_address") orelse "";
    data.company_vat = try dupeJsonString(allocator, obj, "company_vat") orelse "";
    data.company_logo_base64 = try dupeJsonString(allocator, obj, "company_logo_base64");
    data.client_name = try dupeJsonString(allocator, obj, "client_name") orelse "";
    data.client_address = try dupeJsonString(allocator, obj, "client_address") orelse "";
    data.client_vat = try dupeJsonString(allocator, obj, "client_vat") orelse "";
    data.invoice_number = try dupeJsonString(allocator, obj, "invoice_number") orelse "";
    data.invoice_date = try dupeJsonString(allocator, obj, "invoice_date") orelse "";
    data.due_date = try dupeJsonString(allocator, obj, "due_date") orelse "";
    data.blackbox_description = try dupeJsonString(allocator, obj, "blackbox_description") orelse "";
    data.verifactu_qr_base64 = try dupeJsonString(allocator, obj, "verifactu_qr_base64");
    data.notes = try dupeJsonString(allocator, obj, "notes") orelse "";
    data.payment_terms = try dupeJsonString(allocator, obj, "payment_terms") orelse "";
    data.primary_color = try dupeJsonString(allocator, obj, "primary_color") orelse "#b39a7d";
    data.secondary_color = try dupeJsonString(allocator, obj, "secondary_color") orelse "#2c3e50";
    data.title_color = try dupeJsonString(allocator, obj, "title_color") orelse "#b39a7d";
    data.company_name_color = try dupeJsonString(allocator, obj, "company_name_color") orelse "#1a1a1a";
    data.font_family = try dupeJsonString(allocator, obj, "font_family") orelse "Helvetica";

    // Parse numeric fields
    data.subtotal = getJsonFloat(obj, "subtotal") orelse 0;
    data.tax_rate = getJsonFloat(obj, "tax_rate") orelse 0.21;
    data.tax_amount = getJsonFloat(obj, "tax_amount") orelse 0;
    data.total = getJsonFloat(obj, "total") orelse 0;
    data.logo_x = @floatCast(getJsonFloat(obj, "logo_x") orelse 40);
    data.logo_y = @floatCast(getJsonFloat(obj, "logo_y") orelse 750);
    data.logo_width = @floatCast(getJsonFloat(obj, "logo_width") orelse 80);
    data.logo_height = @floatCast(getJsonFloat(obj, "logo_height") orelse 50);

    // Parse display mode
    if (getJsonString(obj, "display_mode")) |mode| {
        if (std.mem.eql(u8, mode, "blackbox")) {
            data.display_mode = .blackbox;
        } else {
            data.display_mode = .itemized;
        }
    }

    // Parse template style
    if (getJsonString(obj, "template_style")) |style| {
        if (std.mem.eql(u8, style, "modern")) {
            data.template_style = .modern;
        } else if (std.mem.eql(u8, style, "classic")) {
            data.template_style = .classic;
        } else if (std.mem.eql(u8, style, "creative")) {
            data.template_style = .creative;
        } else {
            data.template_style = .professional;
        }
    }

    // Parse line items
    if (obj.get("items")) |items_val| {
        if (items_val == .array) {
            const items_array = items_val.array;
            var items = try allocator.alloc(invoice.LineItem, items_array.items.len);

            for (items_array.items, 0..) |item_val, i| {
                if (item_val == .object) {
                    const item_obj = item_val.object;
                    items[i] = invoice.LineItem{
                        .description = try dupeJsonString(allocator, item_obj, "description") orelse "",
                        .quantity = getJsonFloat(item_obj, "quantity") orelse 0,
                        .unit_price = getJsonFloat(item_obj, "unit_price") orelse 0,
                        .total = getJsonFloat(item_obj, "total") orelse 0,
                    };
                }
            }

            data.items = items;
        }
    }

    return data;
}

/// Get string value from JSON object
fn getJsonString(obj: std.json.ObjectMap, key: []const u8) ?[]const u8 {
    if (obj.get(key)) |val| {
        if (val == .string) {
            return val.string;
        }
    }
    return null;
}

/// Get float value from JSON object
fn getJsonFloat(obj: std.json.ObjectMap, key: []const u8) ?f64 {
    if (obj.get(key)) |val| {
        switch (val) {
            .float => return val.float,
            .integer => return @floatFromInt(val.integer),
            else => return null,
        }
    }
    return null;
}

/// Duplicate a JSON string value (allocates memory)
fn dupeJsonString(allocator: std.mem.Allocator, obj: std.json.ObjectMap, key: []const u8) !?[]const u8 {
    if (getJsonString(obj, key)) |str| {
        return try allocator.dupe(u8, str);
    }
    return null;
}

/// Free InvoiceData allocated strings and items
pub fn freeInvoiceData(allocator: std.mem.Allocator, data: *const invoice.InvoiceData) void {
    // Free string fields
    if (data.document_type.len > 0) allocator.free(data.document_type);
    if (data.company_name.len > 0) allocator.free(data.company_name);
    if (data.company_address.len > 0) allocator.free(data.company_address);
    if (data.company_vat.len > 0) allocator.free(data.company_vat);
    if (data.company_logo_base64) |s| allocator.free(s);
    if (data.client_name.len > 0) allocator.free(data.client_name);
    if (data.client_address.len > 0) allocator.free(data.client_address);
    if (data.client_vat.len > 0) allocator.free(data.client_vat);
    if (data.invoice_number.len > 0) allocator.free(data.invoice_number);
    if (data.invoice_date.len > 0) allocator.free(data.invoice_date);
    if (data.due_date.len > 0) allocator.free(data.due_date);
    if (data.blackbox_description.len > 0) allocator.free(data.blackbox_description);
    if (data.verifactu_qr_base64) |s| allocator.free(s);
    if (data.notes.len > 0) allocator.free(data.notes);
    if (data.payment_terms.len > 0) allocator.free(data.payment_terms);
    if (data.primary_color.len > 0) allocator.free(data.primary_color);
    if (data.secondary_color.len > 0) allocator.free(data.secondary_color);
    if (data.title_color.len > 0) allocator.free(data.title_color);
    if (data.company_name_color.len > 0) allocator.free(data.company_name_color);
    if (data.font_family.len > 0) allocator.free(data.font_family);

    // Free items
    if (data.items.len > 0) {
        for (data.items) |item| {
            if (item.description.len > 0) allocator.free(item.description);
        }
        allocator.free(data.items);
    }
}

// =============================================================================
// Tests
// =============================================================================

test "parse simple invoice JSON" {
    const allocator = std.testing.allocator;

    const json =
        \\{
        \\  "document_type": "invoice",
        \\  "company_name": "Test Corp",
        \\  "company_vat": "ESB12345678",
        \\  "client_name": "Client Inc",
        \\  "invoice_number": "INV-001",
        \\  "invoice_date": "2025-11-29",
        \\  "items": [
        \\    {"description": "Service A", "quantity": 5, "unit_price": 100, "total": 500}
        \\  ],
        \\  "subtotal": 500,
        \\  "tax_rate": 0.21,
        \\  "tax_amount": 105,
        \\  "total": 605
        \\}
    ;

    const data = try parseInvoiceJson(allocator, json);
    defer freeInvoiceData(allocator, &data);

    try std.testing.expectEqualStrings("invoice", data.document_type);
    try std.testing.expectEqualStrings("Test Corp", data.company_name);
    try std.testing.expectEqualStrings("Client Inc", data.client_name);
    try std.testing.expectEqual(@as(usize, 1), data.items.len);
    try std.testing.expectEqualStrings("Service A", data.items[0].description);
    try std.testing.expectApproxEqAbs(@as(f64, 500), data.subtotal, 0.01);
    try std.testing.expectApproxEqAbs(@as(f64, 605), data.total, 0.01);
}

test "parse invoice with colors" {
    const allocator = std.testing.allocator;

    const json =
        \\{
        \\  "company_name": "Acme",
        \\  "primary_color": "#ff0000",
        \\  "secondary_color": "#00ff00",
        \\  "display_mode": "blackbox",
        \\  "blackbox_description": "Professional services"
        \\}
    ;

    const data = try parseInvoiceJson(allocator, json);
    defer freeInvoiceData(allocator, &data);

    try std.testing.expectEqualStrings("#ff0000", data.primary_color);
    try std.testing.expectEqualStrings("#00ff00", data.secondary_color);
    try std.testing.expectEqual(invoice.DisplayMode.blackbox, data.display_mode);
    try std.testing.expectEqualStrings("Professional services", data.blackbox_description);
}
