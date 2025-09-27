const std = @import("std");

const calc = @cImport({
    @cInclude("libcalc.h");
});

fn add(x: i32, y: i32) i32 {
    const a: calc.GoInt = @intCast(x);
    const b: calc.GoInt = @intCast(y);
    const c: i32 = @intCast(calc.Add(a, b));

    return c;
}

pub fn main() !void {
    const x: i32 = 5;
    const y: i32 = 16;
    const z: i32 = add(x, y);

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("{d} + {d} = {d}\n", .{ x, y, z });
    try stdout.flush();
}

test "test add" {
    try std.testing.expectEqual(@as(i32, 21), add(5, 16));
}
