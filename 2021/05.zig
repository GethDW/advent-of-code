const input = @embedFile("05.txt");

const std = @import("std");

pub fn part1(allocator: std.mem.Allocator) !u32 {
    var points = std.AutoArrayHashMap([2]u32, u32).init(allocator);
    defer points.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var pairs = std.mem.split(u8, line, " -> ");
        const a = pairs.next().?;
        var comma_idx = std.mem.indexOfScalar(u8, a, ',').?;
        const x1 = try std.fmt.parseInt(u32, a[0..comma_idx], 10);
        const y1 = try std.fmt.parseInt(u32, a[comma_idx + 1 ..], 10);
        const b = pairs.next().?;
        comma_idx = std.mem.indexOfScalar(u8, b, ',').?;
        const x2 = try std.fmt.parseInt(u32, b[0..comma_idx], 10);
        const y2 = try std.fmt.parseInt(u32, b[comma_idx + 1 ..], 10);

        if (x1 == x2) {
            // vertical
            var y: u32 = @min(y1, y2);
            while (y <= @max(y1, y2)) : (y += 1) {
                const gop = try points.getOrPut(.{ x1, y });
                if (gop.found_existing) {
                    gop.value_ptr.* += 1;
                } else {
                    gop.value_ptr.* = 1;
                }
            }
        } else if (y1 == y2) {
            // horizontal
            var x: u32 = @min(x1, x2);
            while (x <= @max(x1, x2)) : (x += 1) {
                const gop = try points.getOrPut(.{ x, y1 });
                if (gop.found_existing) {
                    gop.value_ptr.* += 1;
                } else {
                    gop.value_ptr.* = 1;
                }
            }
        }
    }

    var count: u32 = 0;
    for (points.values()) |c| {
        if (c >= 2) count += 1;
    }
    return count;
}

pub fn part2(allocator: std.mem.Allocator) !u32 {
    var points = std.AutoArrayHashMap([2]u32, u32).init(allocator);
    defer points.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var pairs = std.mem.split(u8, line, " -> ");
        const a = pairs.next().?;
        var comma_idx = std.mem.indexOfScalar(u8, a, ',').?;
        const x1 = try std.fmt.parseInt(u32, a[0..comma_idx], 10);
        const y1 = try std.fmt.parseInt(u32, a[comma_idx + 1 ..], 10);
        const b = pairs.next().?;
        comma_idx = std.mem.indexOfScalar(u8, b, ',').?;
        const x2 = try std.fmt.parseInt(u32, b[0..comma_idx], 10);
        const y2 = try std.fmt.parseInt(u32, b[comma_idx + 1 ..], 10);

        if (x1 == x2) {
            // vertical
            var y: u32 = @min(y1, y2);
            while (y <= @max(y1, y2)) : (y += 1) {
                const gop = try points.getOrPut(.{ x1, y });
                if (gop.found_existing) {
                    gop.value_ptr.* += 1;
                } else {
                    gop.value_ptr.* = 1;
                }
            }
        } else if (y1 == y2) {
            // horizontal
            var x: u32 = @min(x1, x2);
            while (x <= @max(x1, x2)) : (x += 1) {
                const gop = try points.getOrPut(.{ x, y1 });
                if (gop.found_existing) {
                    gop.value_ptr.* += 1;
                } else {
                    gop.value_ptr.* = 1;
                }
            }
        } else {
            var x: u32 = x1;
            var y: u32 = y1;
            while (true) : ({
                if (x1 < x2) x += 1 else x -= 1;
                if (y1 < y2) y += 1 else y -= 1;
            }) {
                const gop = try points.getOrPut(.{ x, y });
                if (gop.found_existing) {
                    gop.value_ptr.* += 1;
                } else {
                    gop.value_ptr.* = 1;
                }
                if (x == x2 or y == y2) break;
            }
        }
    }

    var count: u32 = 0;
    for (points.values()) |c| {
        if (c >= 2) count += 1;
    }
    return count;
}
