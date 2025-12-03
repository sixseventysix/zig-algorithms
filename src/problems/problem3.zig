const std = @import("std");
const io = @import("../utils/io.zig");

// example inputs:

// 7 15
// 9 -4
// 2 -2
// 8 3
// 0 4
// -6 10
// 6 6
// 3 5

// solution: 353.429173528852

// 15 15
// -4 -1
// 0 -1
// 2 -9
// 0 2
// 8 1
// 3 -3
// -9 3
// 8 6
// 9 7
// -9 -1
// 2 6
// -2 7
// -10 -8
// 4 0
// -5 -8

// solution: 168.906562205067

// 4 5
// -3 -3
// 3 -3
// -3 3
// 3 3

// solution: 11.182380450040
const Pair = struct { x: isize, y: isize };

fn cross(o: Pair, a: Pair, b: Pair) isize {
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

fn distSquared(a: Pair, b: Pair) isize {
    const dx = a.x - b.x;
    const dy = a.y - b.y;
    return dx * dx + dy * dy;
}

fn grahamScan(allocator: std.mem.Allocator, points: []Pair) ![]Pair {
    if (points.len < 3) {
        const hull = try allocator.alloc(Pair, points.len);
        @memcpy(hull, points);
        return hull;
    }

    // Find the point with lowest y-coordinate (and leftmost if tie)
    var start_idx: usize = 0;
    for (points, 0..) |p, i| {
        if (p.y < points[start_idx].y or (p.y == points[start_idx].y and p.x < points[start_idx].x)) {
            start_idx = i;
        }
    }

    const start = points[start_idx];

    // Sort points by polar angle with respect to start point
    const Context = struct {
        start_point: Pair,

        pub fn lessThan(ctx: @This(), a: Pair, b: Pair) bool {
            const c = cross(ctx.start_point, a, b);
            if (c == 0) {
                // Collinear: choose closer point first
                return distSquared(ctx.start_point, a) < distSquared(ctx.start_point, b);
            }
            return c > 0;
        }
    };

    const ctx = Context{ .start_point = start };
    std.mem.sort(Pair, points, ctx, Context.lessThan);

    var hull: std.ArrayList(Pair) = .{};
    defer hull.deinit(allocator);

    try hull.append(allocator, points[0]);
    try hull.append(allocator, points[1]);

    for (points[2..]) |point| {
        // Remove points that make clockwise turn
        while (hull.items.len > 1 and cross(hull.items[hull.items.len - 2], hull.items[hull.items.len - 1], point) <= 0) {
            _ = hull.pop();
        }
        try hull.append(allocator, point);
    }

    return try hull.toOwnedSlice(allocator);
}

fn circularSegmentArea(p1: Pair, p2: Pair, radius: f64) f64 {
    const x1 = @as(f64, @floatFromInt(p1.x));
    const y1 = @as(f64, @floatFromInt(p1.y));
    const x2 = @as(f64, @floatFromInt(p2.x));
    const y2 = @as(f64, @floatFromInt(p2.y));

    // Calculate perpendicular distance from origin to line through p1 and p2
    // Line equation: (y2-y1)x - (x2-x1)y + (x2-x1)y1 - (y2-y1)x1 = 0
    // Distance = |ax0 + by0 + c| / sqrt(a^2 + b^2)
    const a = y2 - y1;
    const b = -(x2 - x1);
    const c = (x2 - x1) * y1 - (y2 - y1) * x1;

    const distance = @abs(c) / @sqrt(a * a + b * b);

    // If distance > radius, chord doesn't intersect circle
    if (distance >= radius) return 0.0;

    // Circular segment area = r^2 * arccos(d/r) - d * sqrt(r^2 - d^2)
    const r_squared = radius * radius;
    const angle = std.math.acos(distance / radius);
    const small_segment = r_squared * angle - distance * @sqrt(r_squared - distance * distance);
    return small_segment;
}

fn allPointsShareOriginHalfPlane(allocator: std.mem.Allocator, points: []Pair) !bool {
    if (points.len <= 1) return true;

    const count = points.len;
    const total_len = count * 2;
    var angles = try allocator.alloc(f64, total_len);
    defer allocator.free(angles);

    const two_pi = 2.0 * std.math.pi;

    for (points, 0..) |p, idx| {
        const xf = @as(f64, @floatFromInt(p.x));
        const yf = @as(f64, @floatFromInt(p.y));
        var angle = std.math.atan2(yf, xf);
        if (angle < 0) angle += two_pi;
        angles[idx] = angle;
    }

    const base = angles[0..count];
    const Ctx = struct {
        fn lessThan(_: void, lhs: f64, rhs: f64) bool {
            return lhs < rhs;
        }
    };
    std.mem.sort(f64, base, {}, Ctx.lessThan);

    for (base, 0..) |angle, idx| {
        angles[count + idx] = angle + two_pi;
    }

    var end_idx: usize = 0;
    const limit = std.math.pi + 1e-9;
    for (0..count) |start_idx| {
        const start_angle = angles[start_idx];
        if (end_idx < start_idx) {
            end_idx = start_idx;
        }
        while (end_idx < start_idx + count and angles[end_idx] - start_angle <= limit) {
            end_idx += 1;
        }
        if (end_idx - start_idx == count) return true;
    }

    return false;
}

fn solve(allocator: std.mem.Allocator, pairs: []Pair, r: usize) !f64 {
    const rf = @as(f64, @floatFromInt(r));
    const half_area = (std.math.pi * rf * rf) / 2.0;

    if (pairs.len <= 1) return half_area;
    if (try allPointsShareOriginHalfPlane(allocator, pairs)) return half_area;

    // Compute convex hull using Graham's scan
    const hull = try grahamScan(allocator, pairs);
    defer allocator.free(hull);

    if (hull.len < 2) return half_area;

    var max_area: f64 = 0.0;

    // Check each edge of the convex hull
    for (0..hull.len) |i| {
        const p1 = hull[i];
        const p2 = hull[(i + 1) % hull.len];

        const area = circularSegmentArea(p1, p2, rf);
        max_area = @max(max_area, area);
    }

    return max_area;
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = try io.readAllStdin(allocator);
    defer allocator.free(input);

    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');

    const nr_line = line_iter.next() orelse return error.InvalidInput;
    var nr_iter = std.mem.tokenizeScalar(u8, nr_line, ' ');
    const n = try std.fmt.parseInt(usize, nr_iter.next() orelse return error.InvalidInput, 10);
    const r = try std.fmt.parseInt(usize, nr_iter.next() orelse return error.InvalidInput, 10);
    var pairs: std.ArrayList(Pair) = .{};
    defer pairs.deinit(allocator);
    for (0..n) |_| {
        const i_iter = line_iter.next() orelse return error.InvalidInput;
        var coord_iter = std.mem.tokenizeScalar(u8, i_iter, ' ');
        const x = try std.fmt.parseInt(isize, coord_iter.next() orelse return error.InvalidInput, 10);
        const y = try std.fmt.parseInt(isize, coord_iter.next() orelse return error.InvalidInput, 10);

        try pairs.append(allocator, .{ .x = x, .y = y });
    }
    const result = try solve(allocator, pairs.items, r);
    std.debug.print("{d}\n", .{result});
}
