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
        var res = HelloResponse.init(self.allocator);

        const message = try std.fmt.allocPrint(
            self.allocator,
            "Hello, {s}!",
            .{hello_request.name.getSlice()},
        );

        res.message = protobuf.ManagedString.move(message, self.allocator);

        return res;
    }
};

test "Greeter.sayHello" {
    const allocator = std.testing.allocator;

    var req = HelloRequest.init(allocator);
    req.name = protobuf.ManagedString.static("hoge");
    defer req.deinit();

    var expected = HelloResponse.init(allocator);
    expected.message = protobuf.ManagedString.static("Hello, hoge!");
    defer expected.deinit();

    const greeter = Greeter.init(allocator);
    defer greeter.deinit();

    const actual = try greeter.sayHello(req);
    defer actual.deinit();

    try std.testing.expectEqualStrings(expected.message.getSlice(), actual.message.getSlice());
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const host = "127.0.0.1";
    const port = 8000;
    const addr = try std.net.Address.parseIp4(host, port);
    var server = try addr.listen(.{ .reuse_port = true });
    defer server.deinit();

    std.debug.print("serve http://localhost:{}\r\n", .{8000});

    var buffer: [1024]u8 = undefined;

    accept: while (true) {
        var conn = try server.accept();
        defer conn.stream.close();

        var http_server = std.http.Server.init(conn, &buffer);
        while (http_server.state == .ready) {
            var request = http_server.receiveHead() catch |err| switch (err) {
                error.HttpConnectionClosing => continue :accept,
                else => return,
            };

            const method = request.head.method;
            const path = request.head.target;
            const content_type = request.head.content_type.?;

            if (method == .POST and std.mem.eql(u8, path, "/greeter.v1.Greeter/SayHello") and std.mem.eql(u8, content_type, "application/json")) {
                var reader = try request.reader();
                const body = try reader.readAllAlloc(allocator, 8192);
                defer allocator.free(body);

                // TODO refactor respond_json

                const req = try HelloRequest.json_decode(body, .{}, allocator);
                defer req.deinit();

                const greeter = Greeter.init(allocator);
                defer greeter.deinit();

                const res = try greeter.sayHello(req.value);

                const http_res = try res.json_encode(.{}, allocator);
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
