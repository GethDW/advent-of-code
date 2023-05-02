const std = @import("std");

pub fn part1(input: []const u8) !u32 {
    var count: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    var previous = try std.fmt.parseInt(u32, lines.next().?, 10);
    while (lines.next()) |line| {
        const current = try std.fmt.parseInt(u32, line, 10);
        if (current > previous) count += 1;
        previous = current;
    }
    return count;
}

pub fn part2(input: []const u8) !u32 {
    var count: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    var window: [3]u32 = undefined;
    var prev: u32 = 0;
    for (&window) |*item| {
        item.* = try std.fmt.parseInt(u32, lines.next().?, 10);
        prev += item.*;
    }
    while (lines.next()) |line| {
        std.mem.rotate(u32, &window, 1);
        window[2] = try std.fmt.parseInt(u32, line, 10);
        var current: u32 = 0;
        for (window) |item| current += item;
        if (current > prev) count += 1;
        prev = current;
    }
    return count;
}
