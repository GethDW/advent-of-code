const input = @embedFile("04.txt");

const std = @import("std");

pub fn part1() !u32 {
    var count: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const comma_idx = std.mem.indexOfScalar(u8, line, ',').?;
        const section1 = line[0..comma_idx];
        const section2 = line[comma_idx + 1 ..];
        const dash_idx1 = std.mem.indexOfScalar(u8, section1, '-').?;
        const dash_idx2 = std.mem.indexOfScalar(u8, section2, '-').?;
        const a1 = try std.fmt.parseInt(u32, section1[0..dash_idx1], 10);
        const b1 = try std.fmt.parseInt(u32, section1[dash_idx1 + 1 ..], 10);
        const a2 = try std.fmt.parseInt(u32, section2[0..dash_idx2], 10);
        const b2 = try std.fmt.parseInt(u32, section2[dash_idx2 + 1 ..], 10);
        std.debug.assert(a1 <= b1 and a2 <= b2);
        if ((a1 <= a2 and b2 <= b1) or
            (a2 <= a1 and b1 <= b2)) count += 1;
    }
    return count;
}

pub fn part2() !u32 {
    var count: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        const comma_idx = std.mem.indexOfScalar(u8, line, ',').?;
        const section1 = line[0..comma_idx];
        const section2 = line[comma_idx + 1 ..];
        const dash_idx1 = std.mem.indexOfScalar(u8, section1, '-').?;
        const dash_idx2 = std.mem.indexOfScalar(u8, section2, '-').?;
        const a1 = try std.fmt.parseInt(u32, section1[0..dash_idx1], 10);
        const b1 = try std.fmt.parseInt(u32, section1[dash_idx1 + 1 ..], 10);
        const a2 = try std.fmt.parseInt(u32, section2[0..dash_idx2], 10);
        const b2 = try std.fmt.parseInt(u32, section2[dash_idx2 + 1 ..], 10);
        std.debug.assert(a1 <= b1 and a2 <= b2);
        if ((a1 <= a2 and a2 <= b1) or
            (a2 <= b1 and b1 <= b2) or
            (a2 <= a1 and a1 <= b2) or
            (a1 <= b2 and b2 <= b1)) count += 1;
    }
    return count;
}
