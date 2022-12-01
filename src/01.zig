const example = @embedFile("01_example.txt");
const input = @embedFile("01.txt");

const std = @import("std");

pub fn part1() u32 {
    var iter = std.mem.split(u8, input, "\n");
    var max: u32 = 0;
    var sum: u32 = 0;
    while (iter.next()) |line| {
        if (std.fmt.parseInt(u32, line, 10)) |n| {
            sum += n;
        } else |_| {
            max = @max(max, sum);
            sum = 0;
        }
    }

    return max;
}

pub fn part2(allocator: std.mem.Allocator) !u32 {
    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit();
    var iter = std.mem.split(u8, input, "\n");
    var sum: u32 = 0;
    while (iter.next()) |line| {
        if (std.fmt.parseInt(u32, line, 10)) |n| {
            sum += n;
        } else |_| {
            try list.append(sum);
            sum = 0;
        }
    }

    std.sort.sort(u32, list.items, {}, std.sort.desc(u32));
    var res: u32 = 0;
    for (list.items[0..3]) |n| {
        res += n;
    }

    return res;
}
