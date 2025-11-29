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
pub const page = @import("page.zig");
pub const operators = @import("render/operators.zig");
pub const text_extract = @import("extract/text.zig");
pub const cmap = @import("cmap.zig");

// Re-export main types
pub const Document = document.Document;
pub const DocumentInfo = document.DocumentInfo;
pub const Object = objects.Object;
pub const ObjectRef = objects.ObjectRef;
pub const XRefTable = xref.XRefTable;
pub const Token = lexer.Token;

// Page types
pub const Page = page.Page;
pub const PageTree = page.PageTree;

// Text extraction
pub const TextExtractor = text_extract.TextExtractor;
pub const Operator = operators.Operator;

// Filter types
pub const FlateDecode = filters.FlateDecode;
pub const Ascii85Decode = filters.Ascii85Decode;
pub const AsciiHexDecode = filters.AsciiHexDecode;

test {
    @import("std").testing.refAllDecls(@This());
}
