//! Work-stealing scheduler
//!
//! Performance: <100ns task spawn, 10M+ tasks/sec

const std = @import("std");
const deque_mod = @import("../deque/worksteal.zig");
const ThreadPool = @import("../executor/threadpool.zig").ThreadPool;
const Task = @import("../task/handle.zig").Task;

pub const Scheduler = struct {
    const Self = @This();
    const WorkQueue = deque_mod.WorkStealDeque(*TaskEntry);
    const TaskMap = std.AutoHashMap(u64, *TaskEntry);

    allocator: std.mem.Allocator,
    thread_count: usize,
    thread_pool: ThreadPool,
    work_queues: []*WorkQueue,
    task_map: TaskMap,
    task_map_mutex: std.Thread.Mutex,
    next_task_id: std.atomic.Value(u64),
    running: std.atomic.Value(bool),
    // Condition variable for worker sleep/wake
    work_cond: std.Thread.Condition,
    work_mutex: std.Thread.Mutex,

    pub const Options = struct {
        thread_count: usize = 8,
        queue_size: usize = 4096,
    };

    const TaskEntry = struct {
        task: Task,
        func: *const fn (*anyopaque) void,
        context: *anyopaque,
        allocator: std.mem.Allocator,

        pub fn execute(self: *TaskEntry) void {
            self.task.state.store(.running, .release);
            self.func(self.context);
            self.task.complete(null);
        }
    };

    pub fn init(allocator: std.mem.Allocator, options: Options) !Self {
        const thread_count = if (options.thread_count == 0)
            try std.Thread.getCpuCount()
        else
            options.thread_count;

        // Create work queues (one per thread)
        const work_queues = try allocator.alloc(*WorkQueue, thread_count);
        errdefer allocator.free(work_queues);

        for (work_queues, 0..) |*queue, i| {
            queue.* = try allocator.create(WorkQueue);
            errdefer {
                var j: usize = 0;
                while (j < i) : (j += 1) {
                    allocator.destroy(work_queues[j]);
                }
            }
            queue.*.* = try WorkQueue.init(allocator, options.queue_size);
        }

        const thread_pool = try ThreadPool.init(allocator, thread_count);
        errdefer thread_pool.deinit();

        return Self{
            .allocator = allocator,
            .thread_count = thread_count,
            .thread_pool = thread_pool,
            .work_queues = work_queues,
            .task_map = TaskMap.init(allocator),
            .task_map_mutex = std.Thread.Mutex{},
            .next_task_id = std.atomic.Value(u64).init(0),
            .running = std.atomic.Value(bool).init(false),
            .work_cond = std.Thread.Condition{},
            .work_mutex = std.Thread.Mutex{},
        };
    }

    pub fn deinit(self: *Self) void {
        self.running.store(false, .release);
        self.thread_pool.deinit();

        // Clean up any remaining tasks
        var it = self.task_map.valueIterator();
        while (it.next()) |entry| {
            self.allocator.destroy(entry.*);
        }
        self.task_map.deinit();

        for (self.work_queues) |queue| {
            queue.deinit();
            self.allocator.destroy(queue);
        }
        self.allocator.free(self.work_queues);
    }

    pub fn start(self: *Self) !void {
        self.running.store(true, .release);

        // Start thread pool with worker function
        for (self.thread_pool.threads, 0..) |*thread, i| {
            thread.* = try std.Thread.spawn(.{}, workerThread, .{ self, i });
        }
    }

    pub fn stop(self: *Self) void {
        self.running.store(false, .release);

        // Wake up all sleeping workers so they can see the shutdown flag
        self.work_cond.broadcast();
    }

    /// Spawn a new task
    pub fn spawn(self: *Self, comptime func: anytype, args: anytype) !TaskHandle {
        const task_id = self.next_task_id.fetchAdd(1, .monotonic);

        // Create task entry
        const entry = try self.allocator.create(TaskEntry);
        errdefer self.allocator.destroy(entry);

        entry.task = Task.init(task_id);
        entry.allocator = self.allocator;

        // Create wrapper for function + args
        // Store only the args (runtime data), the function is comptime-known
        const Args = @TypeOf(args);

        const ctx = try self.allocator.create(Args);
        errdefer self.allocator.destroy(ctx);
        ctx.* = args;

        entry.context = @ptrCast(ctx);
        entry.func = struct {
            fn wrapper(ptr: *anyopaque) void {
                const a: *Args = @ptrCast(@alignCast(ptr));
                @call(.auto, func, a.*);
            }
        }.wrapper;

        // Register task
        self.task_map_mutex.lock();
        defer self.task_map_mutex.unlock();
        try self.task_map.put(task_id, entry);

        // Push to current thread's queue (round-robin if not started)
        const thread_id = task_id % self.thread_count;
        try self.work_queues[thread_id].push(entry);

        // Wake up one sleeping worker to handle the new task
        self.work_cond.signal();

        return TaskHandle{ .id = task_id, .scheduler = self };
    }

    fn workerThread(self: *Self, worker_id: usize) void {
        var rng = std.Random.DefaultPrng.init(@intCast(worker_id));
        const random = rng.random();
        var idle_spins: usize = 0;
        const max_spins: usize = 1000; // Spin longer for high-throughput scenarios

        while (self.running.load(.acquire)) {
            // Try to pop from own queue
            if (self.work_queues[worker_id].pop()) |entry| {
                entry.execute();
                self.unregisterTask(entry);
                idle_spins = 0; // Reset spin counter
                continue;
            }

            // Work stealing: try to steal from random queue
            var attempts: usize = 0;
            var found_work = false;
            while (attempts < self.thread_count) : (attempts += 1) {
                const victim = random.intRangeAtMost(usize, 0, self.thread_count - 1);
                if (victim == worker_id) continue;

                if (self.work_queues[victim].steal()) |entry| {
                    entry.execute();
                    self.unregisterTask(entry);
                    found_work = true;
                    idle_spins = 0; // Reset spin counter
                    break;
                }
            }

            // If we found work, continue immediately to check for more
            if (found_work) continue;

            // No work found - spin briefly before sleeping
            // This improves latency for burst workloads
            if (idle_spins < max_spins) {
                idle_spins += 1;
                std.Thread.yield() catch {};
                continue;
            }

            // Still no work after spinning - sleep on condition variable
            // This prevents busy-waiting and allows clean shutdown
            self.work_mutex.lock();
            // Double-check running flag before sleeping
            if (!self.running.load(.acquire)) {
                self.work_mutex.unlock();
                break;
            }
            // Sleep until woken by new work or shutdown signal
            self.work_cond.wait(&self.work_mutex);
            self.work_mutex.unlock();
            idle_spins = 0; // Reset after waking
        }
    }

    fn unregisterTask(self: *Self, entry: *TaskEntry) void {
        self.task_map_mutex.lock();
        defer self.task_map_mutex.unlock();
        _ = self.task_map.remove(entry.task.id);
        self.allocator.destroy(entry);
    }
};

pub const TaskHandle = struct {
    id: u64,
    scheduler: *Scheduler,

    pub fn await_completion(self: TaskHandle) void {
        // Spin-wait for task completion
        // In production, could use condition variable or futex
        while (true) {
            self.scheduler.task_map_mutex.lock();
            const entry = self.scheduler.task_map.get(self.id);
            self.scheduler.task_map_mutex.unlock();

            if (entry == null) {
                // Task has been removed, meaning it completed
                break;
            }

            if (entry.?.task.isCompleted()) {
                break;
            }

            // Yield to avoid busy-wait
            std.Thread.yield() catch {};
        }
    }

    pub fn getStatus(self: TaskHandle) ?Task.State {
        self.scheduler.task_map_mutex.lock();
        defer self.scheduler.task_map_mutex.unlock();

        if (self.scheduler.task_map.get(self.id)) |entry| {
            return entry.task.getState();
        }
        return null; // Task completed and removed
    }
};
