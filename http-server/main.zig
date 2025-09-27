const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const port = 8000;
    const addr = try std.net.Address.parseIp4("127.0.0.1", port);
    var listener = try addr.listen(.{ .reuse_address = true });
    defer listener.deinit();

    std.log.info("serving http://localhost:{}\r\n", .{port});

    while (true) {
        const connection = listener.accept() catch |err| {
            std.log.err("Failed to accept connection: {}", .{err});
            continue;
        };

        var buffer: [4096]u8 = undefined;

        var file_reader = connection.stream.reader(&buffer);
        const reader = &file_reader.file_reader.interface;
        var file_writer = connection.stream.writer(&buffer);
        const writer = &file_writer.file_writer.interface;

        var server = std.http.Server.init(reader, writer);

        while (true) {
            var request = server.receiveHead() catch |err| {
                if (err == error.HttpConnectionClosing) break;
                std.log.err("Failed to receive request: {}", .{err});
                break;
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
                // read header before expired
                const content_type = request.head.content_type.?;

                // expired header here
                const body = try (try request.readerExpectContinue(&.{})).allocRemaining(allocator, .unlimited);
                defer allocator.free(body);

                try request.respond(body, .{ .extra_headers = &.{
                    .{ .name = "content-type", .value = content_type },
                } });
                continue;
            }

            try request.respond("", .{ .status = .not_found });
        }
    }
}
