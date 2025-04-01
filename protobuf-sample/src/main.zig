const std = @import("std");
const protobuf = @import("protobuf");
const greeter = @import("./proto/greeter.pb.zig");

test "HelloRequest init" {
    const allocator = std.testing.allocator;

    var req: greeter.HelloRequest = greeter.HelloRequest.init(allocator);
    defer req.deinit();

    const input = "hoge";
    const expected = "hoge";

    req.name = protobuf.ManagedString.static(input);

    try std.testing.expectEqualStrings(expected, req.name.getSlice());
}

test "HelloRequest encode" {
    const allocator = std.testing.allocator;

    var req: greeter.HelloRequest = greeter.HelloRequest.init(allocator);
    defer req.deinit();

    const input = "hoge";
    const expected = &[_]u8{ 10, 4, 104, 111, 103, 101 };

    req.name = protobuf.ManagedString.static(input);
    const encoded = try req.encode(allocator);
    defer allocator.free(encoded);

    try std.testing.expectEqualSlices(u8, expected, encoded);
}

test "HelloRequest decode" {
    const allocator = std.testing.allocator;

    const input = &[_]u8{ 10, 4, 104, 111, 103, 101 };
    const expected = "hoge";

    const decoded = try greeter.HelloRequest.decode(input, allocator);
    defer decoded.deinit();

    try std.testing.expectEqualStrings(expected, decoded.name.getSlice());
}

test "HelloRequest json_encode" {
    const allocator = std.testing.allocator;

    var req: greeter.HelloRequest = greeter.HelloRequest.init(allocator);
    defer req.deinit();

    const input = "hoge";
    const expected = "{\"name\":\"hoge\"}";

    req.name = protobuf.ManagedString.static(input);
    const encoded = try req.json_encode(.{}, allocator);
    defer allocator.free(encoded);

    try std.testing.expectEqualStrings(expected, encoded);
}

test "HelloRequest json_decode" {
    const allocator = std.testing.allocator;

    const input = "{\"name\":\"hoge\"}";
    const expected = "hoge";

    const decoded = try greeter.HelloRequest.json_decode(input, .{}, allocator);
    defer decoded.deinit();

    try std.testing.expectEqualSlices(u8, expected, decoded.value.name.getSlice());
}

test "HelloResponse init" {
    const allocator = std.testing.allocator;

    var res: greeter.HelloResponse = greeter.HelloResponse.init(allocator);
    defer res.deinit();

    const input = "fuga";
    const expected = "fuga";

    res.message = protobuf.ManagedString.static(input);

    try std.testing.expectEqualStrings(expected, res.message.getSlice());
}

test "HelloResponse encode" {
    const allocator = std.testing.allocator;

    var res: greeter.HelloResponse = greeter.HelloResponse.init(allocator);
    defer res.deinit();

    const input = "fuga";
    const expected = &[_]u8{ 10, 4, 102, 117, 103, 97 };

    res.message = protobuf.ManagedString.static(input);
    const encoded = try res.encode(allocator);
    defer allocator.free(encoded);

    try std.testing.expectEqualSlices(u8, expected, encoded);
}

test "HelloResponse decode" {
    const allocator = std.testing.allocator;

    const input = &[_]u8{ 10, 4, 102, 117, 103, 97 };
    const expected = "fuga";

    const decoded = try greeter.HelloResponse.decode(input, allocator);
    defer decoded.deinit();

    try std.testing.expectEqualStrings(expected, decoded.message.getSlice());
}

test "HelloReponse json_encode" {
    const allocator = std.testing.allocator;

    var res: greeter.HelloResponse = greeter.HelloResponse.init(allocator);
    defer res.deinit();

    const input = "fuga";
    const expected = "{\"message\":\"fuga\"}";

    res.message = protobuf.ManagedString.static(input);
    const encoded = try res.json_encode(.{}, allocator);
    defer allocator.free(encoded);

    try std.testing.expectEqualStrings(expected, encoded);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var req: greeter.HelloRequest = greeter.HelloRequest.init(allocator);
    defer req.deinit();

    req.name = protobuf.ManagedString.static("hoge");
    std.debug.print("request: {s}\n", .{req.name.getSlice()});
    std.debug.print("request_encode: {any}\n", .{try req.encode(allocator)});
    std.debug.print("request_json_encode: {!s}\n", .{try req.json_encode(.{}, allocator)});

    const decodedReq = try greeter.HelloRequest.decode(&.{ 10, 4, 104, 111, 103, 101 }, allocator);
    defer decodedReq.deinit();
    std.debug.print("request_decode: {!s}\n", .{decodedReq.name.getSlice()});

    const decodedJSONReq = try greeter.HelloRequest.json_decode("{\"name\":\"hoge\"}", .{}, allocator);
    defer decodedJSONReq.deinit();
    std.debug.print("request_json_decode: {!s}\n", .{decodedJSONReq.value.name.getSlice()});

    var res: greeter.HelloResponse = greeter.HelloResponse.init(allocator);
    defer req.deinit();

    res.message = protobuf.ManagedString.static("fuga");
    std.debug.print("response: {s}\n", .{res.message.getSlice()});
    std.debug.print("response_encode: {any}\n", .{try res.encode(allocator)});
    std.debug.print("response_json_encode: {!s}\n", .{try res.json_encode(.{}, allocator)});

    const decodedRes = try greeter.HelloResponse.decode(&.{ 10, 4, 102, 117, 103, 97 }, allocator);
    defer decodedRes.deinit();
    std.debug.print("response_decode: {!s}\n", .{decodedRes.message.getSlice()});

    const decodedJSONRes = try greeter.HelloResponse.json_decode("{\"message\":\"fuga\"}", .{}, allocator);
    defer decodedJSONRes.deinit();
    std.debug.print("response_json_decode: {!s}\n", .{decodedJSONRes.value.message.getSlice()});
}
