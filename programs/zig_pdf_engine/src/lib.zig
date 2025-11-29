// zig_pdf_engine - Zero-copy PDF parser and generator
//
// Design principles:
// - Memory-mapped file access (no loading entire PDFs into RAM)
// - Lazy object resolution (parse on demand)
// - SIMD-accelerated decompression where possible
// - Minimal external dependencies

pub const lexer = @import("lexer.zig");
pub const xref = @import("xref.zig");
pub const objects = @import("objects.zig");
pub const document = @import("document.zig");
pub const filters = @import("filters.zig");

// Re-export main types
pub const Document = document.Document;
pub const Object = objects.Object;
pub const ObjectRef = objects.ObjectRef;
pub const XRefTable = xref.XRefTable;
pub const Token = lexer.Token;

// Filter types
pub const FlateDecode = filters.FlateDecode;

test {
    @import("std").testing.refAllDecls(@This());
}
