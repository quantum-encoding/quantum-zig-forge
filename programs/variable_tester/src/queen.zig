//! The Queen - Task Coordinator for the Brute-Force Swarm
//!
//! Responsibilities:
//! - Accept worker connections
//! - Distribute task chunks to workers
//! - Collect and aggregate results
//! - Track worker health via heartbeats

const std = @import("std");
const posix = std.posix;
const protocol = @import("protocol.zig");
const variable_tester = @import("variable_tester.zig");

/// Worker connection state
pub const WorkerState = struct {
    id: u64,
    sockfd: posix.socket_t,
    cpu_cores: u16,
    chunk_size: u32,
    tasks_assigned: u64,
    tasks_completed: u64,
    tasks_succeeded: u64,
    last_heartbeat: i64,
    connected: bool,

    pub fn init(id: u64, sockfd: posix.socket_t, cpu_cores: u16) WorkerState {
        return WorkerState{
            .id = id,
            .sockfd = sockfd,
            .cpu_cores = cpu_cores,
            .chunk_size = protocol.DEFAULT_CHUNK_SIZE * cpu_cores,
            .tasks_assigned = 0,
            .tasks_completed = 0,
            .tasks_succeeded = 0,
            .last_heartbeat = 0,
            .connected = true,
        };
    }
};

/// Queen configuration
pub const QueenConfig = struct {
    port: u16 = protocol.DEFAULT_PORT,
    max_workers: usize = 1024,
    chunk_size: u32 = protocol.DEFAULT_CHUNK_SIZE,
    test_fn_id: protocol.TestFnId = .lossless_compression,
};

/// The Queen coordinator
pub const Queen = struct {
    allocator: std.mem.Allocator,
    config: QueenConfig,
    listen_fd: posix.socket_t,
    workers: std.AutoHashMap(u64, WorkerState),
    next_worker_id: std.atomic.Value(u64),
    running: std.atomic.Value(bool),

    // Task management
    tasks: std.ArrayListUnmanaged([]const u8),
    next_task_idx: std.atomic.Value(u64),
    total_tasks: u64,

    // Results
    results_found: std.atomic.Value(u64),
    best_score: f64,
    mutex: std.Thread.Mutex,

    pub fn init(allocator: std.mem.Allocator, config: QueenConfig) !*Queen {
        const self = try allocator.create(Queen);
        errdefer allocator.destroy(self);

        // Create listening socket
        const listen_fd = try posix.socket(posix.AF.INET, posix.SOCK.STREAM, posix.IPPROTO.TCP);
        errdefer posix.close(listen_fd);

        // Set SO_REUSEADDR
        const optval: i32 = 1;
        try posix.setsockopt(listen_fd, posix.SOL.SOCKET, posix.SO.REUSEADDR, std.mem.asBytes(&optval));

        // Bind
        var addr: posix.sockaddr.in = undefined;
        addr.family = posix.AF.INET;
        addr.port = std.mem.nativeToBig(u16, config.port);
        addr.addr = 0; // INADDR_ANY

        try posix.bind(listen_fd, @ptrCast(&addr), @sizeOf(@TypeOf(addr)));

        // Listen
        try posix.listen(listen_fd, 128);

        self.* = Queen{
            .allocator = allocator,
            .config = config,
            .listen_fd = listen_fd,
            .workers = std.AutoHashMap(u64, WorkerState).init(allocator),
            .next_worker_id = std.atomic.Value(u64).init(1),
            .running = std.atomic.Value(bool).init(false),
            .tasks = std.ArrayListUnmanaged([]const u8){},
            .next_task_idx = std.atomic.Value(u64).init(0),
            .total_tasks = 0,
            .results_found = std.atomic.Value(u64).init(0),
            .best_score = 0.0,
            .mutex = std.Thread.Mutex{},
        };

        return self;
    }

    pub fn deinit(self: *Queen) void {
        self.stop();
        posix.close(self.listen_fd);

        // Close all worker connections
        var iter = self.workers.valueIterator();
        while (iter.next()) |worker| {
            if (worker.connected) {
                posix.close(worker.sockfd);
            }
        }
        self.workers.deinit();

        // Free tasks
        for (self.tasks.items) |task| {
            self.allocator.free(task);
        }
        self.tasks.deinit(self.allocator);

        self.allocator.destroy(self);
    }

    /// Load tasks from a file (one task per line)
    pub fn loadTasksFromFile(self: *Queen, path: []const u8) !void {
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        var buf_reader = std.io.bufferedReader(file.reader());
        var reader = buf_reader.reader();

        var line_buf: [4096]u8 = undefined;
        while (reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
            if (line) |l| {
                if (l.len > 0) {
                    const task = try self.allocator.dupe(u8, l);
                    try self.tasks.append(self.allocator, task);
                }
            } else break;
        } else |_| {}

        self.total_tasks = self.tasks.items.len;
    }

    /// Add tasks programmatically
    pub fn addTask(self: *Queen, data: []const u8) !void {
        const task = try self.allocator.dupe(u8, data);
        try self.tasks.append(self.allocator, task);
        self.total_tasks = self.tasks.items.len;
    }

    /// Generate range of numeric tasks
    pub fn generateNumericTasks(self: *Queen, start_val: u64, end_val: u64) !void {
        var i = start_val;
        while (i < end_val) : (i += 1) {
            const task = try std.fmt.allocPrint(self.allocator, "{}", .{i});
            try self.tasks.append(self.allocator, task);
        }
        self.total_tasks = self.tasks.items.len;
    }

    /// Start the Queen (non-blocking, spawns acceptor thread)
    pub fn start(self: *Queen) !void {
        if (self.running.load(.acquire)) return error.AlreadyRunning;
        self.running.store(true, .release);

        _ = try std.Thread.spawn(.{}, acceptLoop, .{self});
    }

    /// Stop the Queen
    pub fn stop(self: *Queen) void {
        self.running.store(false, .release);
    }

    /// Accept loop - runs in separate thread
    fn acceptLoop(self: *Queen) void {
        std.debug.print("👑 Queen listening on port {}\n", .{self.config.port});

        while (self.running.load(.acquire)) {
            var client_addr: posix.sockaddr.in = undefined;
            var addr_len: posix.socklen_t = @sizeOf(@TypeOf(client_addr));

            const client_fd = posix.accept(self.listen_fd, @ptrCast(&client_addr), &addr_len, 0) catch |err| {
                if (err == error.WouldBlock) continue;
                std.debug.print("👑 Accept error: {}\n", .{err});
                continue;
            };

            // Spawn handler thread for this worker
            _ = std.Thread.spawn(.{}, handleWorker, .{ self, client_fd }) catch |err| {
                std.debug.print("👑 Failed to spawn worker handler: {}\n", .{err});
                posix.close(client_fd);
                continue;
            };
        }
    }

    /// Handle a single worker connection
    fn handleWorker(self: *Queen, sockfd: posix.socket_t) void {
        defer posix.close(sockfd);

        var buffer: [65536]u8 = undefined;

        // Expect WORKER_HELLO
        const header = protocol.Net.recvHeader(sockfd, &buffer) catch |err| {
            std.debug.print("👑 Failed to receive hello: {}\n", .{err});
            return;
        };

        if (header.msg_type != .worker_hello) {
            std.debug.print("👑 Expected WORKER_HELLO, got {}\n", .{header.msg_type});
            return;
        }

        const payload = protocol.Net.recvPayload(sockfd, &buffer, header.payload_len) catch |err| {
            std.debug.print("👑 Failed to receive hello payload: {}\n", .{err});
            return;
        };

        const hello: *const protocol.WorkerHello = @ptrCast(@alignCast(payload.ptr));

        // Assign worker ID
        const worker_id = self.next_worker_id.fetchAdd(1, .monotonic);
        const chunk_size = self.config.chunk_size * hello.cpu_cores;

        // Send welcome
        const welcome = protocol.QueenWelcome.init(worker_id, chunk_size);
        protocol.Net.sendStruct(sockfd, .queen_welcome, welcome) catch |err| {
            std.debug.print("👑 Failed to send welcome: {}\n", .{err});
            return;
        };

        // Register worker
        const worker = WorkerState.init(worker_id, sockfd, hello.cpu_cores);
        {
            self.mutex.lock();
            defer self.mutex.unlock();
            self.workers.put(worker_id, worker) catch {};
        }

        std.debug.print("👑 Worker {} connected ({} cores, chunk_size={})\n", .{ worker_id, hello.cpu_cores, chunk_size });

        // Main worker loop
        while (self.running.load(.acquire)) {
            const msg_header = protocol.Net.recvHeader(sockfd, &buffer) catch |err| {
                std.debug.print("👑 Worker {} disconnected: {}\n", .{ worker_id, err });
                break;
            };

            switch (msg_header.msg_type) {
                .request_work => {
                    self.handleWorkRequest(sockfd, worker_id, chunk_size);
                },
                .submit_result => {
                    const result_payload = protocol.Net.recvPayload(sockfd, &buffer, msg_header.payload_len) catch break;
                    self.handleResultSubmit(sockfd, worker_id, result_payload);
                },
                .heartbeat => {
                    const hb_payload = protocol.Net.recvPayload(sockfd, &buffer, msg_header.payload_len) catch break;
                    self.handleHeartbeat(worker_id, hb_payload);
                },
                else => {
                    std.debug.print("👑 Unknown message type from worker {}: {}\n", .{ worker_id, msg_header.msg_type });
                },
            }
        }

        // Cleanup worker
        {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.workers.getPtr(worker_id)) |w| {
                w.connected = false;
            }
        }

        std.debug.print("👑 Worker {} disconnected\n", .{worker_id});
    }

    fn handleWorkRequest(self: *Queen, sockfd: posix.socket_t, worker_id: u64, chunk_size: u32) void {
        const start_idx = self.next_task_idx.fetchAdd(chunk_size, .monotonic);

        if (start_idx >= self.total_tasks) {
            // No more work
            protocol.Net.sendMessage(sockfd, .no_work, &.{}) catch {};
            return;
        }

        const end_idx = @min(start_idx + chunk_size, self.total_tasks);
        const actual_count: u32 = @intCast(end_idx - start_idx);

        // Build dispatch message
        var payload = std.ArrayListUnmanaged(u8){};
        defer payload.deinit(self.allocator);

        // Write dispatch header
        const dispatch = protocol.WorkDispatch.init(start_idx, actual_count, @intFromEnum(self.config.test_fn_id));
        payload.appendSlice(self.allocator, std.mem.asBytes(&dispatch)) catch return;

        // Write task entries
        var i = start_idx;
        while (i < end_idx) : (i += 1) {
            const task_data = self.tasks.items[i];
            const entry = protocol.TaskEntry.init(i, @intCast(task_data.len));
            payload.appendSlice(self.allocator, std.mem.asBytes(&entry)) catch return;
            payload.appendSlice(self.allocator, task_data) catch return;
        }

        protocol.Net.sendMessage(sockfd, .dispatch_work, payload.items) catch |err| {
            std.debug.print("👑 Failed to dispatch work to {}: {}\n", .{ worker_id, err });
            return;
        };

        // Update stats
        {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.workers.getPtr(worker_id)) |w| {
                w.tasks_assigned += actual_count;
            }
        }
    }

    fn handleResultSubmit(self: *Queen, sockfd: posix.socket_t, worker_id: u64, payload: []const u8) void {
        if (payload.len < @sizeOf(protocol.ResultSubmit)) return;

        const result: *const protocol.ResultSubmit = @ptrCast(@alignCast(payload.ptr));

        if (result.success == 1) {
            _ = self.results_found.fetchAdd(1, .monotonic);

            // Update best score with mutex
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (result.score > self.best_score) {
                    self.best_score = result.score;
                }
            }

            // Extract result data
            const data_start = @sizeOf(protocol.ResultSubmit);
            const data = payload[data_start..][0..result.data_len];

            std.debug.print("🎯 SOLUTION from Worker {} - Task {}: score={d:.4} data=\"{s}\"\n", .{
                worker_id,
                result.task_id,
                result.score,
                data,
            });
        }

        // Update worker stats
        {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.workers.getPtr(worker_id)) |w| {
                w.tasks_completed += 1;
                if (result.success == 1) {
                    w.tasks_succeeded += 1;
                }
            }
        }

        // Send ACK
        protocol.Net.sendMessage(sockfd, .ack_result, &.{}) catch {};
    }

    fn handleHeartbeat(self: *Queen, worker_id: u64, payload: []const u8) void {
        if (payload.len < @sizeOf(protocol.Heartbeat)) return;

        const hb: *const protocol.Heartbeat = @ptrCast(@alignCast(payload.ptr));

        const now = (posix.clock_gettime(.REALTIME) catch return).sec;

        {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.workers.getPtr(worker_id)) |w| {
                w.last_heartbeat = now;
                w.tasks_completed = hb.tasks_processed;
                w.tasks_succeeded = hb.tasks_succeeded;
            }
        }
    }

    /// Get current statistics
    pub fn getStats(self: *Queen) QueenStats {
        self.mutex.lock();
        defer self.mutex.unlock();

        var active_workers: u32 = 0;
        var total_cores: u32 = 0;
        var total_assigned: u64 = 0;
        var total_completed: u64 = 0;
        var total_succeeded: u64 = 0;

        var iter = self.workers.valueIterator();
        while (iter.next()) |worker| {
            if (worker.connected) {
                active_workers += 1;
                total_cores += worker.cpu_cores;
                total_assigned += worker.tasks_assigned;
                total_completed += worker.tasks_completed;
                total_succeeded += worker.tasks_succeeded;
            }
        }

        return QueenStats{
            .total_tasks = self.total_tasks,
            .tasks_distributed = self.next_task_idx.load(.monotonic),
            .active_workers = active_workers,
            .total_cores = total_cores,
            .tasks_assigned = total_assigned,
            .tasks_completed = total_completed,
            .tasks_succeeded = total_succeeded,
            .solutions_found = self.results_found.load(.monotonic),
            .best_score = self.best_score,
        };
    }

    pub const QueenStats = struct {
        total_tasks: u64,
        tasks_distributed: u64,
        active_workers: u32,
        total_cores: u32,
        tasks_assigned: u64,
        tasks_completed: u64,
        tasks_succeeded: u64,
        solutions_found: u64,
        best_score: f64,
    };
};
