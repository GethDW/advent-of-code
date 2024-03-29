const std = @import("std");

pub fn part1(input: []const u8) usize {
    for (0..input.len) |i| {
        var bit_set = std.bit_set.IntegerBitSet(26).initEmpty();
        for (input[i .. i + 4]) |c| bit_set.set(c - 'a');
        if (bit_set.count() == 4) return i + 4;
    }
    unreachable;
}

pub fn part2(input: []const u8) usize {
    for (0..input.len) |i| {
        var bit_set = std.bit_set.IntegerBitSet(26).initEmpty();
        for (input[i .. i + 14]) |c| bit_set.set(c - 'a');
        if (bit_set.count() == 14) return i + 14;
    }
    unreachable;
}
