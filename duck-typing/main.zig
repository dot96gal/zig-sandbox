const std = @import("std");

const Add = struct {
    const Self = @This();

    pub fn calculate(_: Self, x: i8, y: i8) i8 {
        return x + y;
    }
};

const Sub = struct {
    const Self = @This();

    pub fn calculate(_: Self, x: i8, y: i8) i8 {
        return x - y;
    }
};

const Calculator = union(enum) {
    Add: Add,
    Sub: Sub,

    const Self = @This();

    pub fn calculate(self: Self, x: i8, y: i8) i8 {
        return switch (self) {
            inline else => |impl| impl.calculate(x, y),
        };
    }
};

pub fn main() !void {
    const x = 1;
    const y = 2;

    const add = Calculator{ .Add = Add{} };
    std.debug.print("{d}+{d}={d}\n", .{ x, y, add.calculate(x, y) });

    const sub = Calculator{ .Sub = Sub{} };
    std.debug.print("{d}-{d}={d}\n", .{ x, y, sub.calculate(x, y) });
}

test "Add" {
    const x = 1;
    const y = 2;
    const expected = 3;

    const add = Calculator{ .Add = Add{} };
    try std.testing.expectEqual(expected, add.calculate(x, y));
}

test "Sub" {
    const x = 1;
    const y = 2;
    const expected = -1;

    const sub = Calculator{ .Sub = Sub{} };
    try std.testing.expectEqual(expected, sub.calculate(x, y));
}
