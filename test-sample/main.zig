const std = @import("std");

test "expect addOne adds one to 41" {
    try std.testing.expect(addOne(41) == 42);
}

test addOne {
    try std.testing.expect(addOne(41) == 42);
}

fn addOne(number: i32) i32 {
    return number + 1;
}

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("41 + 1 = {d}\n", .{addOne(41)});
    try stdout.flush();
}
