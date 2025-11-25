const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get output file path from command line args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const output_path = if (args.len > 1) args[1] else null;

    // Scan src/problems directory
    var dir = try std.fs.cwd().openDir("src/problems", .{ .iterate = true });
    defer dir.close();

    // Collect problem files using a simple dynamic array
    var problem_list = try std.ArrayList(ProblemFile).initCapacity(allocator, 0);
    defer problem_list.deinit(allocator);

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".zig")) {
            if (std.mem.startsWith(u8, entry.name, "problem")) {
                // Extract number from filename (e.g., "problem3.zig" -> 3)
                const name_without_ext = entry.name[0 .. entry.name.len - 4]; // Remove ".zig"
                const num_str = name_without_ext["problem".len..];

                if (std.fmt.parseInt(u32, num_str, 10)) |number| {
                    try problem_list.append(allocator, .{
                        .filename = try allocator.dupe(u8, entry.name),
                        .number = number,
                    });
                } else |_| {
                    // Skip files that don't have valid number
                    continue;
                }
            }
        }
    }

    // Sort by problem number
    std.mem.sort(ProblemFile, problem_list.items, {}, struct {
        fn lessThan(_: void, lhs: ProblemFile, rhs: ProblemFile) bool {
            return lhs.number < rhs.number;
        }
    }.lessThan);

    // Generate problems.zig - either to file or stdout
    const output_file = if (output_path) |path|
        try std.fs.cwd().createFile(path, .{})
    else
        std.fs.File.stdout();
    defer if (output_path != null) output_file.close();

    // Header
    _ = try output_file.write("const std = @import(\"std\");\n\n");

    // Imports
    for (problem_list.items) |pf| {
        const line = try std.fmt.allocPrint(allocator, "const problem{d} = @import(\"problems/{s}\");\n", .{ pf.number, pf.filename });
        defer allocator.free(line);
        _ = try output_file.write(line);
    }

    // Type definitions
    _ = try output_file.write("\npub const ProblemFn = fn (std.mem.Allocator) anyerror!void;\n\n");
    _ = try output_file.write("pub const Problem = struct {\n");
    _ = try output_file.write("    number: u32,\n");
    _ = try output_file.write("    run: ProblemFn,\n");
    _ = try output_file.write("};\n\n");

    // Registry array
    _ = try output_file.write("pub const registry = [_]Problem{\n");
    for (problem_list.items) |pf| {
        const line = try std.fmt.allocPrint(allocator, "    .{{ .number = {d}, .run = problem{d}.run }},\n", .{ pf.number, pf.number });
        defer allocator.free(line);
        _ = try output_file.write(line);
    }
    _ = try output_file.write("};\n\n");

    // Dispatch function
    _ = try output_file.write(
        \\pub fn dispatch(problem_num: u32, allocator: std.mem.Allocator) !void {
        \\    inline for (registry) |problem| {
        \\        if (problem.number == problem_num) {
        \\            return problem.run(allocator);
        \\        }
        \\    }
        \\    return error.InvalidProblem;
        \\}
        \\
    );

    // Cleanup allocated filenames
    for (problem_list.items) |pf| {
        allocator.free(pf.filename);
    }
}

const ProblemFile = struct {
    filename: []const u8,
    number: u32,
};
