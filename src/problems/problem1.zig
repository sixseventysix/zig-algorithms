const std = @import("std");
const io = @import("../utils/io.zig");

// Codeforces Round 1065 Div 3 Problem C1
// https://codeforces.com/contest/2171/problem/C1

// beating the other player involves having a higher XOR sum. for binary input, this means possible values are only 0 & 1.
// swapping a_i and b_i when they are equal will have no effect, so all significant moves happen only when a_i != b_i.
// a swap will always invert the result of the XOR sum for both you and your opponent. if both players have the same XOR sum
// at init, then it always ends in a tie.
// if the XOR sums are differing, then the player that has the final significant move wins the game as they can choose whether to swap or not.

fn solve(a: []const u8, b: []const u8) []const u8 {
    var xor_a: u8 = 0;
    var xor_b: u8 = 0;
    for (a) |val| {
        xor_a ^= val;
    }
    for (b) |val| {
        xor_b ^= val;
    }

    if (xor_a == xor_b) {
        return "Tie";
    }

    var i: usize = a.len;
    while (i > 0) {
        i -= 1;
        if (a[i] != b[i]) {
            const one_indexed = i + 1;

            if (one_indexed % 2 == 0) {
                return "Mai";
            } else {
                return "Ajisai";
            }
        }
    }

    return "Tie";
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = try io.readAllStdin(allocator);
    defer allocator.free(input);

    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');

    const t_line = line_iter.next() orelse return error.InvalidInput;
    const t = try std.fmt.parseInt(u32, std.mem.trim(u8, t_line, " \r"), 10);

    var test_case: u32 = 0;
    while (test_case < t) : (test_case += 1) {
        const n_line = line_iter.next() orelse return error.InvalidInput;
        const n = try std.fmt.parseInt(usize, std.mem.trim(u8, n_line, " \r"), 10);

        var a = try allocator.alloc(u8, n);
        defer allocator.free(a);
        var b = try allocator.alloc(u8, n);
        defer allocator.free(b);

        const a_line = line_iter.next() orelse return error.InvalidInput;
        var a_iter = std.mem.tokenizeScalar(u8, a_line, ' ');
        var i: usize = 0;
        while (a_iter.next()) |num_str| : (i += 1) {
            a[i] = try std.fmt.parseInt(u8, std.mem.trim(u8, num_str, " \r"), 10);
        }

        const b_line = line_iter.next() orelse return error.InvalidInput;
        var b_iter = std.mem.tokenizeScalar(u8, b_line, ' ');
        i = 0;
        while (b_iter.next()) |num_str| : (i += 1) {
            b[i] = try std.fmt.parseInt(u8, std.mem.trim(u8, num_str, " \r"), 10);
        }

        const result = solve(a, b);
        try io.writeStdoutLine(result);
    }
}
