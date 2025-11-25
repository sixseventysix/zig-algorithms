some algorithms stuff in zig.

## Quick Start

```bash
# Run a problem (builds automatically)
make run PROB=1

# Run without rebuilding (fast iteration)
make run-nobuild PROB=2

# Just build
make build
```

## Running Problems
```bash
make run PROB=1              # Build and run problem 1
make run-nobuild PROB=2      # Run problem 2 without rebuilding
```

**Alternative:** Direct execution
```bash
zig build
./zig-out/bin/zig_algorithms 1 < inputs/problem1_input.txt
```

## Adding a New Problem

### 1. Create problem file
Create `src/problems/problemN.zig`:

```zig
const std = @import("std");
const io = @import("../utils/io.zig");

// Problem: [Brief description]
// Constraints: [List constraints]

fn solve(/* parameters */) []const u8 {
    // Your solution logic here
    return "result";
}

pub fn run(allocator: std.mem.Allocator) !void {
    const input = try io.readAllStdin(allocator);
    defer allocator.free(input);

    // Parse input and call solve()
    // Write output using io.writeStdoutLine()
}
```

### 2. Add input file
Create `inputs/problemN_input.txt` with test input.

### 3. Register in main.zig
Add import:
```zig
const problemN = @import("problems/problemN.zig");
```

Add switch case:
```zig
N => try problemN.run(allocator),
```

### 4. Test
```bash
make run PROB=N
```

## Available Utilities

**I/O Functions** (`src/utils/io.zig`):
- `readAllStdin(allocator)` - Single syscall to read all stdin
- `writeStdout(s)` - Write string to stdout
- `writeStdoutLine(s)` - Write string with newline

## Current Problems

**Problem 1:** Binary XOR Game (arrays with 0/1)
**Problem 2:** Large Integer Bit XOR Game (0 ≤ aᵢ ≤ 10⁶)
