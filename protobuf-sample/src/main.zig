const std = @import("std");
const protobuf = @import("protobuf");
const greeter = @import("./proto/greeter.pb.zig");

test "HelloRequest init" {
    var req: greeter.HelloRequest = greeter.HelloRequest{};

    const input = "hoge";
    const expected = "hoge";

    req.name = input;

    try std.testing.expectEqualStrings(expected, req.name);
}

test "HelloRequest encode" {
    const allocator = std.testing.allocator;

    var req: greeter.HelloRequest = greeter.HelloRequest{};

    const input = "hoge";
    const expected = &[_]u8{ 10, 4, 104, 111, 103, 101 };

    req.name = input;

    var allocating = std.Io.Writer.Allocating.init(allocator);
    defer allocating.deinit();

    try req.encode(&allocating.writer, allocator);

    try std.testing.expectEqualSlices(u8, expected, allocating.written());
}

test "HelloRequest decode" {
    const allocator = std.testing.allocator;

    const input = &[_]u8{ 10, 4, 104, 111, 103, 101 };
    const expected = "hoge";

    var reader: std.Io.Reader = .fixed(input);
    var decoded = try greeter.HelloRequest.decode(&reader, allocator);
    defer decoded.deinit(allocator);

    try std.testing.expectEqualStrings(expected, decoded.name);
}

test "HelloRequest jsonEncode" {
    const allocator = std.testing.allocator;

    var req: greeter.HelloRequest = greeter.HelloRequest{};

    const input = "hoge";
    const expected = "{\"name\":\"hoge\"}";

    req.name = input;
    const encoded = try req.jsonEncode(.{}, allocator);
    defer allocator.free(encoded);

    try std.testing.expectEqualStrings(expected, encoded);
}

test "HelloRequest jsonDecode" {
    const allocator = std.testing.allocator;

    const input = "{\"name\":\"hoge\"}";
    const expected = "hoge";

    const decoded = try greeter.HelloRequest.jsonDecode(input, .{}, allocator);
    defer decoded.deinit();

    try std.testing.expectEqualSlices(u8, expected, decoded.value.name);
}

test "HelloResponse init" {
    var res: greeter.HelloResponse = greeter.HelloResponse{};

    const input = "fuga";
    const expected = "fuga";

    res.message = input;

    try std.testing.expectEqualStrings(expected, res.message);
}

test "HelloResponse encode" {
    const allocator = std.testing.allocator;

    var res: greeter.HelloResponse = greeter.HelloResponse{};

    const input = "fuga";
    const expected = &[_]u8{ 10, 4, 102, 117, 103, 97 };

    res.message = input;

    var allocating = std.Io.Writer.Allocating.init(allocator);
    defer allocating.deinit();

    try res.encode(&allocating.writer, allocator);

    try std.testing.expectEqualSlices(u8, expected, allocating.written());
}

test "HelloResponse decode" {
    const allocator = std.testing.allocator;

    const input = &[_]u8{ 10, 4, 102, 117, 103, 97 };
    const expected = "fuga";

    var reader: std.Io.Reader = .fixed(input);
    var decoded = try greeter.HelloResponse.decode(&reader, allocator);
    defer decoded.deinit(allocator);

    try std.testing.expectEqualStrings(expected, decoded.message);
}

test "HelloReponse jsonEncode" {
    const allocator = std.testing.allocator;

    var res: greeter.HelloResponse = greeter.HelloResponse{};

    const input = "fuga";
    const expected = "{\"message\":\"fuga\"}";

    res.message = input;
    const encoded = try res.jsonEncode(.{}, allocator);
    defer allocator.free(encoded);

    try std.testing.expectEqualStrings(expected, encoded);
}

test "HelloResponse jsonDecode" {
    const allocator = std.testing.allocator;

    const input = "{\"message\":\"fuga\"}";
    const expected = "fuga";

    const decoded = try greeter.HelloResponse.jsonDecode(input, .{}, allocator);
    defer decoded.deinit();

    try std.testing.expectEqualSlices(u8, expected, decoded.value.message);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var req: greeter.HelloRequest = greeter.HelloRequest{};
    req.name = "hoge";

    var allocating = std.Io.Writer.Allocating.init(allocator);
    defer allocating.deinit();
    try req.encode(&allocating.writer, allocator);
    const encoded = allocating.written();

    const json_encoded = try req.jsonEncode(.{}, allocator);
    defer allocator.free(json_encoded);

    std.debug.print("request: {s}\n", .{req.name});
    std.debug.print("request_encode: {any}\n", .{encoded});
    std.debug.print("request_json_encode: {any}\n", .{json_encoded});

    var reader: std.Io.Reader = .fixed(encoded);
    var decodedReq = try greeter.HelloRequest.decode(&reader, allocator);
    defer decodedReq.deinit(allocator);
    std.debug.print("request_decode: {s}\n", .{decodedReq.name});

    const decodedJSONReq = try greeter.HelloRequest.jsonDecode(json_encoded, .{}, allocator);
    defer decodedJSONReq.deinit();
    std.debug.print("request_json_decode: {any}\n", .{decodedJSONReq.value});
}
