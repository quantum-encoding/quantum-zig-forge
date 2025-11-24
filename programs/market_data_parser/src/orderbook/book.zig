//! Lock-Free Order Book
//! Cache-line aligned for optimal performance
//! Target: <100ns update latency

const std = @import("std");

pub const PriceLevel = struct {
    price: f64,
    quantity: f64,
    orders: u32,

    pub fn init(price: f64, qty: f64) PriceLevel {
        return .{
            .price = price,
            .quantity = qty,
            .orders = 1,
        };
    }
};

/// High-performance order book
/// Maintains top N levels on each side
pub const OrderBook = struct {
    symbol: [16]u8,
    bids: [100]PriceLevel align(64),  // Cache-line aligned
    asks: [100]PriceLevel align(64),
    bid_count: usize,
    ask_count: usize,
    sequence: u64,

    pub fn init(symbol: []const u8) OrderBook {
        var book: OrderBook = undefined;
        @memset(&book.symbol, 0);
        @memcpy(book.symbol[0..symbol.len], symbol);
        book.bid_count = 0;
        book.ask_count = 0;
        book.sequence = 0;
        return book;
    }

    /// Update bid side (buy orders)
    pub fn updateBid(self: *OrderBook, price: f64, qty: f64) void {
        // TODO: SIMD binary search for price level
        // TODO: Insert/update in sorted order
        _ = self;
        _ = price;
        _ = qty;
    }

    /// Update ask side (sell orders)
    pub fn updateAsk(self: *OrderBook, price: f64, qty: f64) void {
        // TODO: SIMD binary search for price level
        // TODO: Insert/update in sorted order
        _ = self;
        _ = price;
        _ = qty;
    }

    /// Get best bid (highest buy price)
    pub fn getBestBid(self: *const OrderBook) ?PriceLevel {
        if (self.bid_count == 0) return null;
        return self.bids[0];
    }

    /// Get best ask (lowest sell price)
    pub fn getBestAsk(self: *const OrderBook) ?PriceLevel {
        if (self.ask_count == 0) return null;
        return self.asks[0];
    }

    /// Get mid price
    pub fn getMidPrice(self: *const OrderBook) ?f64 {
        const bid = self.getBestBid() orelse return null;
        const ask = self.getBestAsk() orelse return null;
        return (bid.price + ask.price) / 2.0;
    }

    /// Get spread in basis points
    pub fn getSpreadBps(self: *const OrderBook) ?f64 {
        const bid = self.getBestBid() orelse return null;
        const ask = self.getBestAsk() orelse return null;
        const mid = (bid.price + ask.price) / 2.0;
        return ((ask.price - bid.price) / mid) * 10000.0;
    }
};

test "order book init" {
    const book = OrderBook.init("BTCUSDT");
    try std.testing.expectEqual(@as(usize, 0), book.bid_count);
    try std.testing.expectEqual(@as(usize, 0), book.ask_count);
}
