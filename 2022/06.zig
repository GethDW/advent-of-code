const input = @embedFile("06.txt");

const std = @import("std");

pub fn part1() usize {
    for (input) |_, i| {
        var bit_set = std.bit_set.IntegerBitSet(26).initEmpty();
        for (input[i .. i + 4]) |c| bit_set.set(c - 'a');
        if (bit_set.count() == 4) return i + 4;
    }
    unreachable;
}

pub fn part2() usize {
    for (input) |_, i| {
        var bit_set = std.bit_set.IntegerBitSet(26).initEmpty();
        for (input[i .. i + 14]) |c| bit_set.set(c - 'a');
        if (bit_set.count() == 14) return i + 14;
    }
    unreachable;
}
