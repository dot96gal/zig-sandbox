const std = @import("std");

pub fn TreeNode(comptime T: type) type {
    return struct {
        allocator: std.mem.Allocator,
        data: T,
        left: ?*TreeNode(T),
        right: ?*TreeNode(T),

        const Self = @This();

        pub fn init(
            allocator: std.mem.Allocator,
            data: T,
            left: ?*TreeNode(T),
            right: ?*TreeNode(T),
        ) !*Self {
            var node = try allocator.create(TreeNode(T));
            node.allocator = allocator;
            node.data = data;
            node.left = left;
            node.right = right;

            return node;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.destroy(self);
        }

        pub fn work(self: Self) void {
            std.log.info("element is {}\n", .{self.data});
        }

        pub fn traverse(self: *Self) !void {
            self.work();

            if (self.left != null) {
                try self.left.?.traverse();
            }
            if (self.right != null) {
                try self.right.?.traverse();
            }
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var node_2 = try TreeNode(u8).init(allocator, 2, null, null);
    defer node_2.deinit();

    var node_3 = try TreeNode(u8).init(allocator, 3, null, null);
    defer node_3.deinit();

    var node_1 = try TreeNode(u8).init(allocator, 1, node_2, node_3);
    defer node_1.deinit();

    try node_1.traverse();
}
