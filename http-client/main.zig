const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var allocating = std.Io.Writer.Allocating.init(allocator);
    defer allocating.deinit();

    const response = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = "https://b.hatena.ne.jp" },
        .response_writer = &allocating.writer,
    });

    std.debug.print("Result: {}\n", .{response.status});
    std.debug.print("Response: {s}\n", .{allocating.written()});
}
