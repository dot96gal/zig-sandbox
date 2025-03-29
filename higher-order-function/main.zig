const std = @import("std");

fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn sub(a: i32, b: i32) i32 {
    return a - b;
}

fn calc(a: i32, b: i32, impl: fn (a: i32, b: i32) i32) i32 {
    return impl(a, b);
}

test "add" {
    try std.testing.expect(calc(1, 2, add) == 3);
}

test "sub" {
    try std.testing.expect(calc(3, 2, sub) == 1);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("1 + 2 = {d}\n", .{calc(1, 2, add)});
    try stdout.print("3 - 2 = {d}\n", .{calc(3, 2, sub)});
}
