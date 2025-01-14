const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args[1..]) |arg| {
        const s = std.mem.sliceTo(arg, 0);
        try stdout.print("arg: {s}\n", .{s});
    }
}
