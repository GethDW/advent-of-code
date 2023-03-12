const std = @import("std");
const input = @embedFile("02.txt");

pub fn part1() !u32 {
    var acc: u32 = 0;
    var lines = std.mem.tokenize(u8, input, &.{'\n'});
    while (lines.next()) |line| {
        var sides: [3]u32 = undefined;
        var nums = std.mem.split(u8, line, "x");
        for (&sides) |*side| {
            side.* = try std.fmt.parseInt(u32, nums.next().?, 10);
        }
        std.debug.assert(nums.next() == null);

        var min: u32 = std.math.maxInt(u32);
        for (0..3) |i| {
            for (0..i) |j| {
                const side = sides[i] * sides[j];
                acc += 2 * side;
                min = @min(min, side);
            }
        }
        acc += min;
    }
    return acc;
}

pub fn part2() !u32 {
    var acc: u32 = 0;
    var lines = std.mem.tokenize(u8, input, &.{'\n'});
    while (lines.next()) |line| {
        var sides: [3]u32 = undefined;
        var nums = std.mem.split(u8, line, "x");
        for (&sides) |*side| {
            side.* = try std.fmt.parseInt(u32, nums.next().?, 10);
        }
        std.debug.assert(nums.next() == null);

        std.sort.sort(u32, &sides, {}, std.sort.asc(u32));
        for (sides[0..2]) |side| acc += 2 * side;
        var prod: u32 = 1;
        for (&sides) |side| prod *= side;
        acc += prod;
    }
    return acc;
}
