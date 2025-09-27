const std = @import("std");
const protobuf = @import("protobuf");
const HelloRequest = @import("./gen/greeter/v1.pb.zig").HelloRequest;
const HelloResponse = @import("./gen/greeter/v1.pb.zig").HelloResponse;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();

    var req = HelloRequest{};
    req.name = "client";

    const encoded_req = try req.jsonEncode(.{}, allocator);
    defer allocator.free(encoded_req);

    var allocating = std.Io.Writer.Allocating.init(allocator);
    defer allocating.deinit();

    const res = try client.fetch(.{
        .method = .POST,
        .location = .{ .url = "http://localhost:8000/greeter.v1.Greeter/SayHello" },
        .headers = .{ .content_type = .{ .override = "application/json" } },
        .payload = encoded_req,
        .response_writer = &allocating.writer,
    });

    std.debug.print("Response status: {}\n", .{res.status});
    std.debug.print("Response body: {s}\n", .{allocating.written()});
}
