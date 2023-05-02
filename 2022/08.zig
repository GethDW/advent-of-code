const std = @import("std");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !void {
    const rows: []const []const u8 = blk: {
        var grid = std.ArrayList([]const u8).init(allocator);
        defer grid.deinit();
        var lines = std.mem.tokenize(u8, input, "\n");
        while (lines.next()) |line| try grid.append(line);
        break :blk try grid.toOwnedSlice();
    };

    var count: u32 = 0;
    trees: for (rows, 0..) |row, x| {
        for (row, 0..) |_, y| {
            const height = rows[x][y];
            if (blk: {
                for (rows[0..x]) |h| {
                    if (h >= height) break :blk false;
                }
                break :blk true;
            }) {
                count += 1;
                continue :trees;
            }
            if (blk: {
                for (rows[x + 1 ..]) |h| {
                    if (h >= height) break :blk false;
                }
                break :blk true;
            }) {
                count += 1;
                continue :trees;
            }
        }
    }
}
