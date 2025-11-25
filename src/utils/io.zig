const std = @import("std");

/// Reads all stdin in a single syscall
/// Caller must free the returned slice
pub fn readAllStdin(allocator: std.mem.Allocator) ![]u8 {
    const stdin = std.fs.File.stdin();
    const max_input_size = 10_000_000; // 10MB
    const input = try stdin.readToEndAlloc(allocator, max_input_size);
    return input;
}

/// Writes a string to stdout
pub fn writeStdout(s: []const u8) !void {
    const stdout = std.fs.File.stdout();
    _ = try stdout.write(s);
}

/// Writes a string to stdout with newline
pub fn writeStdoutLine(s: []const u8) !void {
    try writeStdout(s);
    try writeStdout("\n");
}
