const std = @import("std");
const protobuf = @import("protobuf");
const greeter = @import("./proto/greeter.pb.zig");

test "HelloRequest" {
    const allocator = std.testing.allocator;

    var req: greeter.HelloRequest = greeter.HelloRequest.init(allocator);
    defer req.deinit();

    const input = "hoge";
    const expected = "hoge";

    req.name = protobuf.ManagedString.static(input);

    try std.testing.expectEqualStrings(expected, req.name.getSlice());
}

test "HelloResponse" {
    const allocator = std.testing.allocator;

    var res: greeter.HelloResponse = greeter.HelloResponse.init(allocator);
    defer res.deinit();

    const input = "fuga";
    const expected = "fuga";

    res.message = protobuf.ManagedString.static(input);

    try std.testing.expectEqualStrings(expected, res.message.getSlice());
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var req: greeter.HelloRequest = greeter.HelloRequest.init(allocator);
    defer req.deinit();

    req.name = protobuf.ManagedString.static("hoge");
    std.debug.print("request: {s}\n", .{req.name.getSlice()});

    var res: greeter.HelloResponse = greeter.HelloResponse.init(allocator);
    defer req.deinit();

    res.message = protobuf.ManagedString.static("fuga");
    std.debug.print("response: {s}\n", .{res.message.getSlice()});
}
