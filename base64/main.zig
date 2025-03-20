const std = @import("std");

pub const Base64 = struct {
    table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const number = "0123456789";
        const symbol = "+/";

        return Base64{ .table = upper ++ lower ++ number ++ symbol };
    }

    fn char_at(self: Base64, index: u8) u8 {
        return self.table[index];
    }

    fn char_index(self: Base64, char: u8) u8 {
        if (char == '=') {
            return 64;
        }

        var index: u8 = 0;
        for (0..63) |_| {
            if (self.char_at(index) == char) {
                break;
            } else {
                index += 1;
            }
        }

        return index;
    }

    fn calc_encode_length(_: Base64, input: []const u8) !usize {
        var n: usize = 0;

        if (input.len < 3) {
            n = 1;
        } else {
            n = try std.math.divCeil(usize, input.len, 3);
        }

        return n * 4;
    }

    fn calc_decode_length(_: Base64, input: []const u8) !usize {
        var n: usize = 0;

        if (input.len < 4) {
            n = 1;
        } else {
            n = try std.math.divFloor(usize, input.len, 4);
        }

        return n * 3;
    }

    pub fn encode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0) {
            return "";
        }

        const len = try self.calc_encode_length(input);
        var output = try allocator.alloc(u8, len);
        var output_index: usize = 0;
        var buffer = [3]u8{ 0, 0, 0 };
        var buffer_index: u8 = 0;

        for (input, 0..) |_, i| {
            buffer[buffer_index] = input[i];
            buffer_index += 1;

            if (buffer_index == 3) {
                output[output_index] = self.char_at(buffer[0] >> 2);
                output[output_index + 1] = self.char_at(((buffer[0] & 0x03) << 4) + (buffer[1] >> 4));
                output[output_index + 2] = self.char_at(((buffer[1] & 0x0f) << 2) + (buffer[2] >> 6));
                output[output_index + 3] = self.char_at(buffer[2] & 0x3f);

                output_index += 4;
                buffer_index = 0;
            }
        }

        if (buffer_index == 1) {
            output[output_index] = self.char_at(buffer[0] >> 2);
            output[output_index + 1] = self.char_at((buffer[0] & 0x03) << 4);
            output[output_index + 2] = '=';
            output[output_index + 3] = '=';
        }

        if (buffer_index == 2) {
            output[output_index] = self.char_at(buffer[0] >> 2);
            output[output_index + 1] = self.char_at(((buffer[0] & 0x03) << 4) + (buffer[1] >> 4));
            output[output_index + 2] = self.char_at((buffer[1] & 0x0f) << 2);
            output[output_index + 3] = '=';
        }

        return output;
    }

    pub fn decode(self: Base64, allocator: std.mem.Allocator, input: []const u8) ![]u8 {
        if (input.len == 0)
            return "";

        const len = try self.calc_decode_length(input);
        var output = try allocator.alloc(u8, len);
        var output_index: usize = 0;
        var buffer = [4]u8{ 0, 0, 0, 0 };
        var buffer_index: u8 = 0;

        for (0..output.len) |i| {
            output[i] = 0;
        }

        for (0..input.len) |i| {
            buffer[buffer_index] = self.char_index(input[i]);
            buffer_index += 1;

            if (buffer_index == 4) {
                output[output_index] = (buffer[0] << 2) + (buffer[1] >> 4);
                if (buffer[2] != 64) {
                    output[output_index + 1] = (buffer[1] << 4) + (buffer[2] >> 2);
                }
                if (buffer[3] != 64) {
                    output[output_index + 2] = (buffer[2] << 6) + buffer[3];
                }

                output_index += 3;
                buffer_index = 0;
            }
        }

        return output;
    }
};

test "encode" {
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();

    const input = "Hi";
    const expected = "SGk=";

    const base64 = Base64.init();
    const actual = try base64.encode(allocator, input);

    try std.testing.expect(std.mem.eql(u8, actual, expected));
}

test "decode" {
    var aa = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer aa.deinit();
    const allocator = aa.allocator();

    const input = "SGk=";
    const expected = [_:0]u8{ 'H', 'i', 0 };

    const base64 = Base64.init();
    const actual = try base64.decode(allocator, input);

    try std.testing.expect(std.mem.eql(u8, actual, &expected));
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var aa = std.heap.ArenaAllocator.init(gpa.allocator());
    defer aa.deinit();
    const allocator = aa.allocator();

    const text = "Testing some more stuff";
    const etext = "VGVzdGluZyBzb21lIG1vcmUgc3R1ZmY=";
    const base64 = Base64.init();
    const encoded_text = try base64.encode(allocator, text);
    const decoded_text = try base64.decode(allocator, etext);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Encoded text: {s}\n", .{encoded_text});
    try stdout.print("Decoded text: {s}\n", .{decoded_text});
}
