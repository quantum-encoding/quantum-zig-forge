//! Zero-Copy Network Stack
//!
//! High-performance networking with io_uring

pub const tcp = @import("tcp/server.zig");
// UDP socket needs full rewrite for stdlib IoUring - TODO
// pub const udp = @import("udp/socket.zig");
pub const io_uring = @import("io_uring/ring.zig");
pub const buffer = @import("buffer/pool.zig");

pub const TcpServer = tcp.TcpServer;
// pub const UdpSocket = udp.UdpSocket;
pub const IoUring = io_uring.IoUring;
pub const BufferPool = buffer.BufferPool;

test {
    @import("std").testing.refAllDecls(@This());
}
