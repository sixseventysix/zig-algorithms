const std = @import("std");

const problem1 = @import("problems/problem1.zig");
const problem2 = @import("problems/problem2.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const problem_num = if (args.len > 1)
        try std.fmt.parseInt(u32, args[1], 10)
    else blk: {
        var env_map = try std.process.getEnvMap(allocator);
        defer env_map.deinit();

        if (env_map.get("PROBLEM")) |prob_str| {
            break :blk try std.fmt.parseInt(u32, prob_str, 10);
        }

        break :blk 1;
    };

    switch (problem_num) {
        1 => try problem1.run(allocator),
        2 => try problem2.run(allocator),
        else => {
            return error.InvalidProblem;
        },
    }
}
