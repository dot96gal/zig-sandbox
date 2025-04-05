const std = @import("std");
const sqlite = @import("sqlite");

pub fn main() !void {
    var db = try sqlite.Db.init(.{
        .mode = sqlite.Db.Mode{ .File = "./sample.db" },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    });

    try db.exec("CREATE TABLE IF NOT EXISTS employees(id integer primary key, name text, age integer, salary integer)", .{}, .{});

    const query1 =
        \\INSERT INTO employees(name, age, salary) VALUES(?, ?, ?)
    ;

    var stmt1 = try db.prepare(query1);
    defer stmt1.deinit();

    try stmt1.exec(.{}, .{
        .name = "hoge",
        .age = 40,
        .salary = 20000,
    });

    const query2 =
        \\SELECT name, age FROM employees WHERE id = ?
    ;

    var stmt2 = try db.prepare(query2);
    defer stmt2.deinit();

    const row = try stmt2.one(
        struct {
            name: [128:0]u8,
            age: usize,
        },
        .{},
        .{ .id = 1 },
    );
    if (row) |r| {
        const name_ptr: [*:0]const u8 = &r.name;
        std.log.debug("name: {s}, age: {}", .{ std.mem.span(name_ptr), r.age });
    }

    const query3 =
        \\SELECT name FROM employees WHERE age > ? AND age < ?
    ;

    var stmt3 = try db.prepare(query3);
    defer stmt3.deinit();

    const allocator = std.heap.page_allocator; // Use a suitable allocator

    const names = try stmt3.all([]const u8, allocator, .{}, .{
        .age1 = 20,
        .age2 = 50,
    });
    for (names) |name| {
        std.log.debug("name: {s}", .{name});
    }
}
