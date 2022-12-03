const input = @embedFile("03.txt");

const std = @import("std");

const BitSet = std.bit_set.IntegerBitSet('z' - 'A' + 1);
pub fn part1() u32 {
    var sum: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        std.debug.assert(line.len % 2 == 0);
        var first = BitSet.initEmpty();
        var second = BitSet.initEmpty();
        for (line[0 .. line.len / 2]) |c| {
            first.set(c - 'A');
        }
        for (line[line.len / 2 ..]) |c| {
            second.set(c - 'A');
        }
        first.setIntersection(second);
        const c = @intCast(u8, first.findFirstSet().?) + 'A';
        const priority: u8 = if (std.ascii.isLower(c))
            c - 'a' + 1
        else
            c - 'A' + 27;
        sum += priority;
    }
    return sum;
}

pub fn part2() u32 {
    var sum: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    loop: while (true) {
        var common = BitSet.initFull();
        for ([_]void{{}} ** 3) |_| {
            var tmp = BitSet.initEmpty();
            for (lines.next() orelse break :loop) |c| tmp.set(c - 'A');
            common.setIntersection(tmp);
        }
        const c = @intCast(u8, common.findFirstSet().?) + 'A';
        const priority: u8 = if (std.ascii.isLower(c))
            c - 'a' + 1
        else
            c - 'A' + 27;
        sum += priority;
    }

    return sum;
}
