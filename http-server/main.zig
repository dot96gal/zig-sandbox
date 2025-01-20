const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const port = 8000;
    const addr = try std.net.Address.parseIp4("127.0.0.1", port);
    var net_server = try addr.listen(.{ .reuse_port = true });
    defer net_server.deinit();

    std.debug.print("serving http://localhost:{}\r\n", .{8000});

    var buffer: [1024]u8 = undefined;

    accept: while (true) {
        var conn = try net_server.accept();
        defer conn.stream.close();

        var http_server = std.http.Server.init(conn, &buffer);
        while (http_server.state == .ready) {
            var request = http_server.receiveHead() catch |err| switch (err) {
                error.HttpConnectionClosing => continue :accept,
                else => return,
            };

            std.debug.print("{}", .{request});

            const method = request.head.method;
            const target = request.head.target;

            if (method == .GET and std.mem.eql(u8, target, "/")) {
                try request.respond("Hello Zig!", .{ .extra_headers = &.{
                    .{ .name = "content-type", .value = "text/plain;charset=UTF-8" },
                } });
                continue;
            }

            if (method == .POST and std.mem.eql(u8, target, "/echo")) {
                var reader = try request.reader();
                const body = try reader.readAllAlloc(allocator, 8192);
                defer allocator.free(body);

                try request.respond(body, .{ .extra_headers = &.{
                    .{ .name = "content-type", .value = request.head.content_type.? },
                } });
                continue;
            }

            try request.respond("", .{ .status = .not_found });
        }
    }
}
