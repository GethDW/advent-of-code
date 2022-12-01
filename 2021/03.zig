const input = @embedFile("03.txt");

const std = @import("std");

pub fn part1() u64 {
    var count: u32 = 0;
    var bit_counts = [1]u32{0} ** 16;
    var lines = std.mem.tokenize(u8, input, "\n");
    var line_len: u4 = 0;
    while (lines.next()) |line| {
        line_len = @max(@intCast(u4, line.len), line_len);
        var i: usize = 0;
        while (i < line.len) : (i += 1) {
            bit_counts[bit_counts.len - i - 1] += line[line.len - i - 1] - '0';
        }
        count += 1;
    }
    var gamma: u16 = 0;
    for (bit_counts[bit_counts.len - line_len ..]) |bit| {
        if (bit > count / 2) gamma |= 0b1;
        gamma <<= 1;
    }
    gamma >>= 1;
    const epsilon = ~gamma & ~(@as(u16, 0xFFFF) << line_len);

    return std.math.mulWide(u16, gamma, epsilon);
}

fn filter(bit_count: u4, most_common: bool, ns: *std.ArrayList(u16)) u16 {
    var mask: u16 = @as(u16, 1) << bit_count - 1; // bit to check
    while (mask != 0) : (mask >>= 1) {
        var i: usize = 0;
        var set_count: usize = 0;
        for (ns.items) |num| {
            if (mask & num != 0) set_count += 1;
        }
        const unset_count = ns.items.len - set_count;

        while (i < ns.items.len) {
            if (ns.items.len == 1) return ns.items[0];
            const is_set = mask & ns.items[i] != 0;
            const should_be_set = if (most_common)
                set_count >= unset_count
            else
                set_count < unset_count;
            if ((should_be_set and !is_set) or
                (!should_be_set and is_set))
            {
                _ = ns.orderedRemove(i);
            } else i += 1;
        }
    }
    unreachable;
}
pub fn part2(allocator: std.mem.Allocator) !u64 {
    var nums = std.ArrayList(u16).init(allocator);
    defer nums.deinit();
    var lines = std.mem.tokenize(u8, input, "\n");
    var line_len: u4 = 0;
    while (lines.next()) |line| {
        line_len = @max(@intCast(u4, line.len), line_len);
        try nums.append(try std.fmt.parseInt(u16, line, 2));
    }

    const copy = try nums.clone();
    const oxygen = filter(line_len, true, &nums);
    nums.deinit();
    nums = copy;
    const carbon = filter(line_len, false, &nums);
    return std.math.mulWide(u16, oxygen, carbon);
}
