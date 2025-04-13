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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var req = HelloRequest.init(allocator);
    req.name = protobuf.ManagedString.static("client");
    defer req.deinit();

    const encoded_req = try req.json_encode(.{}, allocator);
    defer allocator.free(encoded_req);

    var res = std.ArrayList(u8).init(allocator);
    defer res.deinit();

    const result = try client.fetch(.{
        .method = .POST,
        .location = .{ .url = "http://localhost:8000/greeter.v1.Greeter/SayHello" },
        .headers = .{ .content_type = .{ .override = "application/json" } },
        .payload = encoded_req,
        .response_storage = .{ .dynamic = &res },
    });

    std.debug.print("Result: {}\n", .{result.status});
    std.debug.print("Response: {s}\n", .{res.items});
}
