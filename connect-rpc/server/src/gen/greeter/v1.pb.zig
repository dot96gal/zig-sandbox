// Code generated by protoc-gen-zig
///! package greeter.v1
const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const protobuf = @import("protobuf");
const ManagedString = protobuf.ManagedString;
const fd = protobuf.fd;
const ManagedStruct = protobuf.ManagedStruct;

pub const HelloRequest = struct {
    name: ManagedString = .Empty,

    pub const _desc_table = .{
        .name = fd(1, .String),
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};

pub const HelloResponse = struct {
    message: ManagedString = .Empty,

    pub const _desc_table = .{
        .message = fd(1, .String),
    };

    pub usingnamespace protobuf.MessageMixins(@This());
};
