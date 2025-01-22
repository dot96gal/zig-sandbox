const std = @import("std");

const Reset = "\x1b[m";

const FontColorBlack = "\x1b[30m";
const FontColorRed = "\x1b[31m";
const FontColorGreen = "\x1b[32m";
const FontColorYellow = "\x1b[33m";
const FontColorBlue = "\x1b[34m";
const FontColorMagenta = "\x1b[35m";
const FontColorCyan = "\x1b[36m";
const FontColorWhite = "\x1b[37m";
const FontColorDefault = "\x1b[39m";

const FontColor = enum {
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,

    pub fn apply(self: FontColor, w: anytype, s: []const u8) !void {
        switch (self) {
            .black => try w.print("{s}{s}{s}", .{ FontColorBlack, s, Reset }),
            .red => try w.print("{s}{s}{s}", .{ FontColorRed, s, Reset }),
            .green => try w.print("{s}{s}{s}", .{ FontColorGreen, s, Reset }),
            .yellow => try w.print("{s}{s}{s}", .{ FontColorYellow, s, Reset }),
            .blue => try w.print("{s}{s}{s}", .{ FontColorBlue, s, Reset }),
            .magenta => try w.print("{s}{s}{s}", .{ FontColorMagenta, s, Reset }),
            .cyan => try w.print("{s}{s}{s}", .{ FontColorCyan, s, Reset }),
            .white => try w.print("{s}{s}{s}", .{ FontColorWhite, s, Reset }),
        }
    }
};

const BackgroundColorBlack = "\x1b[40m";
const BackgroundColorRed = "\x1b[41m";
const BackgroundColorGreen = "\x1b[42m";
const BackgroundColorYellow = "\x1b[43m";
const BackgroundColorBlue = "\x1b[44m";
const BackgroundColorMagenta = "\x1b[45m";
const BackgroundColorCyan = "\x1b[46m";
const BackgroundColorWhite = "\x1b[47m";
const BackgroundColorDefault = "\x1b[49m";

const BackgroundColor = enum {
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,
    white,

    pub fn apply(self: BackgroundColor, w: anytype, s: []const u8) !void {
        switch (self) {
            .black => try w.print("{s}{s}{s}", .{ BackgroundColorBlack, s, Reset }),
            .red => try w.print("{s}{s}{s}", .{ BackgroundColorRed, s, Reset }),
            .green => try w.print("{s}{s}{s}", .{ BackgroundColorGreen, s, Reset }),
            .yellow => try w.print("{s}{s}{s}", .{ BackgroundColorYellow, s, Reset }),
            .blue => try w.print("{s}{s}{s}", .{ BackgroundColorBlue, s, Reset }),
            .magenta => try w.print("{s}{s}{s}", .{ BackgroundColorMagenta, s, Reset }),
            .cyan => try w.print("{s}{s}{s}", .{ BackgroundColorCyan, s, Reset }),
            .white => try w.print("{s}{s}{s}", .{ BackgroundColorWhite, s, Reset }),
        }
    }
};
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var array = std.ArrayList(u8).init(allocator);
    defer array.deinit();
    const w = array.writer();

    const stdout = std.io.getStdOut().writer();

    try FontColor.black.apply(w, "Hello, Zig!\n");
    try FontColor.red.apply(w, "Hello, Zig!\n");
    try FontColor.green.apply(w, "Hello, Zig!\n");
    try FontColor.yellow.apply(w, "Hello, Zig!\n");
    try FontColor.blue.apply(w, "Hello, Zig!\n");
    try FontColor.magenta.apply(w, "Hello, Zig!\n");
    try FontColor.cyan.apply(w, "Hello, Zig!\n");
    try FontColor.white.apply(w, "Hello, Zig!\n");

    try BackgroundColor.black.apply(w, "Hello, ANSI!\n");
    try BackgroundColor.red.apply(w, "Hello, ANSI!\n");
    try BackgroundColor.green.apply(w, "Hello, ANSI!\n");
    try BackgroundColor.yellow.apply(w, "Hello, ANSI!\n");
    try BackgroundColor.blue.apply(w, "Hello, ANSI!\n");
    try BackgroundColor.magenta.apply(w, "Hello, ANSI!\n");
    try BackgroundColor.cyan.apply(w, "Hello, ANSI!\n");
    try BackgroundColor.white.apply(w, "Hello, ANSI!\n");

    try stdout.print("{s}", .{array.items});
}
