const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var response = std.ArrayList(u8).init(allocator);
    defer response.deinit();

    const result = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = "https://b.hatena.ne.jp" },
        .response_storage = .{ .dynamic = &response },
    });

    std.debug.print("Result: {}\n", .{result.status});
    std.debug.print("Response: {s}\n", .{response.items});
}
