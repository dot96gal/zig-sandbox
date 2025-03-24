const std = @import("std");

fn Stack(comptime T: type) type {
    return struct {
        items: []T,
        capacity: usize,
        length: usize,
        allocator: std.mem.Allocator,
        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Stack(T) {
            var buf = try allocator.alloc(T, capacity);
            return .{
                .items = buf[0..],
                .capacity = capacity,
                .length = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, val: T) !void {
            if ((self.length + 1) > self.capacity) {
                var new_buf = try self.allocator.alloc(T, self.capacity * 2);
                @memcpy(new_buf[0..self.capacity], self.items);
                self.allocator.free(self.items);
                self.items = new_buf;
                self.capacity = self.capacity * 2;
            }

            self.items[self.length] = val;
            self.length += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.length == 0) return;

            self.items[self.length - 1] = undefined;
            self.length -= 1;
        }
    };
}

test "Stack" {
    const allocator = std.testing.allocator;
    const Stacku8 = Stack(u8);
    var stack = try Stacku8.init(allocator, 10);
    defer stack.deinit();
    try stack.push(1);

    const expected_length: u8 = 1;
    const expected_capacity: u8 = 10;
    try std.testing.expectEqual(expected_length, stack.length);
    try std.testing.expectEqual(expected_capacity, stack.capacity);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const Stacku8 = Stack(u8);
    var stack = try Stacku8.init(allocator, 10);
    defer stack.deinit();
    try stack.push(1);
    try stack.push(2);
    try stack.push(3);
    try stack.push(4);
    try stack.push(5);
    try stack.push(6);

    std.debug.print("Stack len: {d}\n", .{stack.length});
    std.debug.print("Stack capacity: {d}\n", .{stack.capacity});

    stack.pop();
    std.debug.print("Stack len: {d}\n", .{stack.length});
    stack.pop();
    std.debug.print("Stack len: {d}\n", .{stack.length});
    std.debug.print("Stack state: {any}\n", .{stack.items[0..stack.length]});
}
