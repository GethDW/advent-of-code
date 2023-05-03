const std = @import("std");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    const width = blk: {
        var lines = std.mem.tokenize(u8, input, "\n");
        break :blk lines.next().?.len;
    };
    const height = width;
    const rows: []const u8 = blk: {
        var grid = std.ArrayList(u8).init(allocator);
        defer grid.deinit();
        var lines = std.mem.tokenize(u8, input, "\n");
        while (lines.next()) |line| {
            try grid.appendSlice(line);
        }
        break :blk try grid.toOwnedSlice();
    };
    defer allocator.free(rows);
    std.debug.assert(rows.len == width * height);

    var visible = try std.DynamicBitSet.initEmpty(allocator, width * height);
    defer visible.deinit();

    for (1..width - 1) |x| for (1..height - 1) |y| {
        const i = y * width + x;
        const current = rows[i];
        const is_visible = blk: {
            for (x + 1..width) |z| {
                if (current <= rows[y * width + z]) break;
            } else break :blk true;

            for (0..x) |z| {
                if (current <= rows[y * width + z]) break;
            } else break :blk true;

            for (y + 1..height) |z| {
                if (current <= rows[z * width + x]) break;
            } else break :blk true;

            for (0..y) |z| {
                if (current <= rows[z * width + x]) break;
            } else break :blk true;

            break :blk false;
        };
        if (is_visible) visible.set(i);
    };

    return visible.count() + 2 * width + 2 * height - 4;
}
