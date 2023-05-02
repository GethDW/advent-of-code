const std = @import("std");

pub fn part1(input: []const u8) u32 {
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

pub fn part2(input: []const u8) !u32 {
    var iter = std.mem.split(u8, input, "\n");
    var top: [4]u32 = .{ 0, 0, 0, 0 };
    var sum: u32 = 0;
    while (iter.next()) |line| {
        if (std.fmt.parseInt(u32, line, 10)) |n| {
            sum += n;
        } else |_| {
            top[3] = sum;
            std.sort.sort(u32, &top, {}, std.sort.desc(u32));
            sum = 0;
        }
    }

    var res: u32 = 0;
    for (top[0..3]) |t| res += t;
    return res;
}
