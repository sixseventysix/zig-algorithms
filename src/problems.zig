const std = @import("std");

const problem1 = @import("problems/problem1.zig");
const problem2 = @import("problems/problem2.zig");
const problem3 = @import("problems/problem3.zig");

pub const ProblemFn = fn (std.mem.Allocator) anyerror!void;

pub const Problem = struct {
    number: u32,
    run: ProblemFn,
};

pub const registry = [_]Problem{
    .{ .number = 1, .run = problem1.run },
    .{ .number = 2, .run = problem2.run },
    .{ .number = 3, .run = problem3.run },
};

pub fn dispatch(problem_num: u32, allocator: std.mem.Allocator) !void {
    inline for (registry) |problem| {
        if (problem.number == problem_num) {
            return problem.run(allocator);
        }
    }
    return error.InvalidProblem;
}
