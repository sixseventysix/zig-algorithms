const std = @import("std");
const io = @import("../utils/io.zig");

// Codeforces Round 1065 Div 3 Problem C2
// https://codeforces.com/contest/2171/problem/C2

// an extension to problem 1. essentially like playing parallel versions of the same game across various bit positions.
// we will start with the MSB because if a player wins the MSB position (playing the same game as problem 1), they win the game here.
// winning the MSB position (i.e. having a higher bit value in the MSB) would mean the final value of the XOR sum will be greater,
// so we only need to worry about the MSB. if there's a tie in the MSB, the MSB position gets decremented.
// according to constraints, max value for numbers in the arrays is 10**6 which fits into 20 bits.

fn solve1(a: []const u8, b: []const u8) []const u8 {
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

fn solve(a: []const u32, b: []const u32, allocator: std.mem.Allocator) ![]const u8 {
    const n = a.len;
    const max_bits = 20;

    var bit_arrays_a = try allocator.alloc([]u8, max_bits);
    defer {
        for (bit_arrays_a) |arr| {
            allocator.free(arr);
        }
        allocator.free(bit_arrays_a);
    }

    var bit_arrays_b = try allocator.alloc([]u8, max_bits);
    defer {
        for (bit_arrays_b) |arr| {
            allocator.free(arr);
        }
        allocator.free(bit_arrays_b);
    }

    for (0..max_bits) |bit_pos| {
        bit_arrays_a[bit_pos] = try allocator.alloc(u8, n);
        bit_arrays_b[bit_pos] = try allocator.alloc(u8, n);

        for (0..n) |i| {
            bit_arrays_a[bit_pos][i] = @intCast((a[i] >> @intCast(bit_pos)) & 1);
            bit_arrays_b[bit_pos][i] = @intCast((b[i] >> @intCast(bit_pos)) & 1);
        }
    }

    var bit_pos: usize = max_bits;
    while (bit_pos > 0) {
        bit_pos -= 1;

        const result = solve1(bit_arrays_a[bit_pos], bit_arrays_b[bit_pos]);
        if (!std.mem.eql(u8, result, "Tie")) {
            return result;
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

        var a = try allocator.alloc(u32, n);
        defer allocator.free(a);
        var b = try allocator.alloc(u32, n);
        defer allocator.free(b);

        const a_line = line_iter.next() orelse return error.InvalidInput;
        var a_iter = std.mem.tokenizeScalar(u8, a_line, ' ');
        var i: usize = 0;
        while (a_iter.next()) |num_str| : (i += 1) {
            a[i] = try std.fmt.parseInt(u32, std.mem.trim(u8, num_str, " \r"), 10);
        }

        const b_line = line_iter.next() orelse return error.InvalidInput;
        var b_iter = std.mem.tokenizeScalar(u8, b_line, ' ');
        i = 0;
        while (b_iter.next()) |num_str| : (i += 1) {
            b[i] = try std.fmt.parseInt(u32, std.mem.trim(u8, num_str, " \r"), 10);
        }

        const result = try solve(a, b, allocator);
        try io.writeStdoutLine(result);
    }
}
