const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var s = Scheduler(Task).init(allocator);
    defer s.deinit();

    try s.start();

    var p1 = Person{ .name = "hoge" };
    var p2 = Person{ .name = "fuga" };

    try s.scheduleIn(.{ .say = .{ .person = &p1, .msg = "hello, world!" } }, 1000);
    try s.scheduleIn(.{ .say = .{ .person = &p2, .msg = "hello, world!" } }, 3000);

    std.time.sleep(std.time.ns_per_ms * 2000);
    s.stop();
}

const Person = struct {
    name: []const u8,

    fn say(p: *const Person, msg: []const u8, when: u64) void {
        std.time.sleep(when);
        std.debug.print("{s} said: {s}\n", .{ p.name, msg });
    }
};

const Task = union(enum) {
    say: Say,
    db_cleaner: void,

    const Say = struct {
        person: *Person,
        msg: []const u8,
    };

    pub fn run(task: Task) void {
        switch (task) {
            .say => |s| std.debug.print("{s} said: {s}\n", .{ s.person.name, s.msg }),
            .db_cleaner => {
                std.debug.print("Cleaning old records from the database\n", .{});
            },
        }
    }
};

fn Job(comptime T: type) type {
    return struct {
        task: T,
        run_at: i64,
    };
}

fn Scheduler(comptime T: type) type {
    return struct {
        queue: Queue,
        running: bool,
        thread: ?std.Thread,
        mutex: std.Thread.Mutex,
        cond: std.Thread.Condition,

        const Self = @This();

        const Queue = std.PriorityQueue(Job(T), void, compare);

        fn compare(_: void, a: Job(T), b: Job(T)) std.math.Order {
            return std.math.order(a.run_at, b.run_at);
        }

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .queue = Queue.init(allocator, {}),
                .running = false,
                .thread = null,
                .mutex = .{},
                .cond = .{},
            };
        }

        pub fn deinit(self: *Self) void {
            self.queue.deinit();
        }

        pub fn schedule(self: *Self, task: T, run_at: i64) !void {
            const job = Job(T){
                .task = task,
                .run_at = run_at,
            };

            var reschedule = false;
            {
                self.mutex.lock();
                defer self.mutex.unlock();

                if (self.queue.peek()) |*next| {
                    if (run_at < next.run_at) {
                        reschedule = true;
                    }
                } else {
                    reschedule = true;
                }
                try self.queue.add(job);
            }

            if (reschedule) {
                self.cond.signal();
            }
        }

        pub fn scheduleIn(self: *Self, task: T, ms: i64) !void {
            return self.schedule(task, std.time.milliTimestamp() + ms);
        }

        pub fn start(self: *Self) !void {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (self.running == true) {
                    return error.AlreadyRunning;
                }
                self.running = true;
            }

            self.thread = try std.Thread.spawn(.{}, Self.run, .{self});
        }

        pub fn stop(self: *Self) void {
            {
                self.mutex.lock();
                defer self.mutex.unlock();
                if (self.running == false) {
                    return;
                }
                self.running = false;
            }

            self.cond.signal();
            self.thread.?.join();
        }

        fn run(self: *Self) void {
            self.mutex.lock();

            while (true) {
                const ms_until_next = self.processPending();

                if (self.running == false) {
                    self.mutex.unlock();
                    return;
                }

                if (ms_until_next) |timeout| {
                    const ns = @as(u64, @intCast(timeout * std.time.ns_per_ms));
                    self.cond.timedWait(&self.mutex, ns) catch |err| {
                        std.debug.assert(err == error.Timeout);
                    };
                } else {
                    self.cond.wait(&self.mutex);
                }
            }
        }

        fn processPending(self: *Self) ?i64 {
            while (true) {
                const next = self.queue.peek() orelse {
                    return null;
                };

                const ms_until_next = next.run_at - std.time.milliTimestamp();
                if (ms_until_next > 0) {
                    return ms_until_next;
                }

                const job = self.queue.remove();

                self.mutex.unlock();
                defer self.mutex.lock();

                job.task.run();
            }
        }
    };
}
