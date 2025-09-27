const std = @import("std");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    for (args[1..]) |arg| {
        const s = std.mem.sliceTo(arg, 0);
        try stdout.print("arg: {s}\n", .{s});
        try stdout.flush();
    }
}
