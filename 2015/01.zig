pub fn part1(input: []const u8) i64 {
    var floor: i64 = 0;
    for (input) |c| {
        switch (c) {
            '(' => floor += 1,
            ')' => floor -= 1,
            '\n' => {},
            else => unreachable,
        }
    }
    return floor;
}

pub fn part2(input: []const u8) usize {
    var floor: i64 = 0;
    for (input, 1..) |c, i| {
        switch (c) {
            '(' => floor += 1,
            ')' => floor -= 1,
            '\n' => {},
            else => unreachable,
        }
        if (floor == -1) return i;
    }
    unreachable;
}
