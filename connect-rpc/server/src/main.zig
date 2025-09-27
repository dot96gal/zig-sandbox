const std = @import("std");
const protobuf = @import("protobuf");
const HelloRequest = @import("./gen/greeter/v1.pb.zig").HelloRequest;
const HelloResponse = @import("./gen/greeter/v1.pb.zig").HelloResponse;

pub const Greeter = struct {
    allocator: std.mem.Allocator,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
        };
    }

    pub fn deinit(_: Self) void {}

    pub fn sayHello(self: Self, hello_request: HelloRequest) !HelloResponse {
        var res = HelloResponse{};

        const message = try std.fmt.allocPrint(
            self.allocator,
            "Hello, {s}!",
            .{hello_request.name},
        );

        res.message = message;

        return res;
    }
};

test "Greeter.sayHello" {
    const allocator = std.testing.allocator;

    var req = HelloRequest{};
    req.name = "hoge";

    var expected = HelloResponse{};
    expected.message = "Hello, hoge!";

    const greeter = Greeter.init(allocator);
    defer greeter.deinit();

    var actual = try greeter.sayHello(req);
    defer actual.deinit(allocator);

    try std.testing.expectEqualStrings(expected.message, actual.message);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const host = "127.0.0.1";
    const port = 8000;
    const addr = try std.net.Address.parseIp4(host, port);
    var listener = try addr.listen(.{ .reuse_address = true });
    defer listener.deinit();

    std.debug.print("serve http://localhost:{}\r\n", .{port});

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
            const path = request.head.target;
            const content_type = request.head.content_type.?;

            if (method == .POST and std.mem.eql(u8, path, "/greeter.v1.Greeter/SayHello") and std.mem.eql(u8, content_type, "application/json")) {
                const body = try (try request.readerExpectContinue(&.{})).allocRemaining(allocator, .unlimited);
                defer allocator.free(body);

                const req = try HelloRequest.jsonDecode(body, .{}, allocator);
                defer req.deinit();

                const greeter = Greeter.init(allocator);
                defer greeter.deinit();

                const res = try greeter.sayHello(req.value);

                const http_res = try res.jsonEncode(.{}, allocator);
                defer allocator.free(http_res);

                try request.respond(http_res, .{
                    .status = .ok,
                    .extra_headers = &.{
                        .{ .name = "content-type", .value = content_type },
                    },
                });

                continue;
            }

            try request.respond("", .{ .status = .not_found });
        }
    }
}
