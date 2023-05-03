const std = @import("std");

// we assume:
//    - the input is equal length lines of single digit numbers.
//    - each line ends with a single '\n'.
// we offset indexing of input by +(y * width) to account for the newline.
// we offset indexing of the bit set by -1 for x and y to avoid storing edges.
pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const width = std.mem.indexOfScalar(u8, input, '\n').?;

    // we don't store the edges
    var visible = try std.DynamicBitSet.initEmpty(allocator, (width - 1) * (width - 1));
    defer visible.deinit();

    for (1..width - 1) |x| for (1..width - 1) |y| {
        const current = input[y * (width + 1) + x];
        const is_visible = blk: {
            for (x + 1..width) |z| {
                if (current <= input[y * (width + 1) + z]) break;
            } else break :blk true;

            for (0..x) |z| {
                if (current <= input[y * (width + 1) + z]) break;
            } else break :blk true;

            for (y + 1..width) |z| {
                if (current <= input[z * (width + 1) + x]) break;
            } else break :blk true;

            for (0..y) |z| {
                if (current <= input[z * (width + 1) + x]) break;
            } else break :blk true;

            break :blk false;
        };
        if (is_visible) visible.set((y - 1) * width + (x - 1));
    };

    // we didn't check the edges so we add them after the fact
    return visible.count() + 4 * width - 4;
}
