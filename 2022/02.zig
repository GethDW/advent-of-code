const input = @embedFile("02.txt");

const std = @import("std");

const Move = enum(u4) {
    Rock = 1,
    Paper = 2,
    Scissors = 3,

    pub fn value(self: Move) u32 {
        return @enumToInt(self);
    }
    pub fn play(self: Move, other: Move) u32 {
        if (self == other) {
            return 3;
        } else if ((self == .Rock and other == .Scissors) or
            (self == .Paper and other == .Rock) or
            (self == .Scissors and other == .Paper))
        {
            return 6;
        } else {
            return 0;
        }
    }
};

pub fn part1() u32 {
    var score: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        std.debug.assert(line.len == 3);
        const enemy: Move = switch (line[0]) {
            'A' => .Rock,
            'B' => .Paper,
            'C' => .Scissors,
            else => unreachable,
        };
        const player: Move = switch (line[2]) {
            'X' => .Rock,
            'Y' => .Paper,
            'Z' => .Scissors,
            else => unreachable,
        };
        score += player.play(enemy) + player.value();
    }

    return score;
}

pub fn part2() u32 {
    var score: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        std.debug.assert(line.len == 3);
        const enemy: Move = switch (line[0]) {
            'A' => .Rock,
            'B' => .Paper,
            'C' => .Scissors,
            else => unreachable,
        };
        const game_score: u32 = switch (line[2]) {
            'X' => 0,
            'Y' => 3,
            'Z' => 6,
            else => unreachable,
        };
        for (std.enums.values(Move)) |player| {
            if (player.play(enemy) == game_score) {
                score += game_score + player.value();
            }
        }
    }

    return score;
}
