const input = @embedFile("04.txt");

const std = @import("std");

const BitSet = std.bit_set.IntegerBitSet(25);
const Board = struct {
    bit_set: BitSet = BitSet.initEmpty(),
    squares: [25]u8,

    pub fn hasWon(self: Board) bool {
        var mask: u25 = 0b11111;
        var i: u8 = 0;
        while (i < 5) : ({
            i += 1;
            mask <<= 5;
        }) {
            if (@popCount(mask & self.bit_set.mask) == 5) return true;
        }
        mask = 0b0000100001000010000100001;
        i = 0;
        while (i < 5) : ({
            i += 1;
            mask <<= 1;
        }) {
            if (@popCount(mask & self.bit_set.mask) == 5) return true;
        }
        return false;
    }

    pub fn score(self: Board) u32 {
        var s: u32 = 0;
        var iter = self.bit_set.iterator(.{ .kind = .unset });
        while (iter.next()) |i| {
            s += self.squares[i];
        }
        return s;
    }
};

pub fn part1(allocator: std.mem.Allocator) !u32 {
    var boards = std.ArrayList(Board).init(allocator);
    defer boards.deinit();

    var lines = std.mem.split(u8, input, "\n\n");
    var nums = std.mem.split(u8, lines.next().?, ",");
    while (lines.next()) |board| {
        var squares = std.mem.tokenize(u8, board, &.{ ' ', '\n' });
        var s = std.BoundedArray(u8, 25).init(0) catch unreachable;
        while (squares.next()) |square| {
            try s.append(try std.fmt.parseInt(u8, square, 10));
        }
        std.debug.assert(s.slice().len == 25);
        try boards.append(Board{
            .squares = s.buffer,
        });
    }
    while (nums.next()) |num| {
        const n = try std.fmt.parseInt(u8, num, 10);
        for (boards.items) |*board| {
            if (std.mem.indexOfScalar(u8, &board.squares, n)) |i| {
                board.bit_set.set(i);
                if (board.hasWon()) return board.score() * n;
            }
        }
    }
    unreachable;
}

pub fn part2(allocator: std.mem.Allocator) !u32 {
    var boards = std.ArrayList(Board).init(allocator);
    defer boards.deinit();

    var lines = std.mem.split(u8, input, "\n\n");
    var nums = std.mem.split(u8, lines.next().?, ",");
    while (lines.next()) |board| {
        var squares = std.mem.tokenize(u8, board, &.{ ' ', '\n' });
        var s = std.BoundedArray(u8, 25).init(0) catch unreachable;
        while (squares.next()) |square| {
            try s.append(try std.fmt.parseInt(u8, square, 10));
        }
        std.debug.assert(s.slice().len == 25);
        try boards.append(Board{
            .squares = s.buffer,
        });
    }
    while (nums.next()) |num| {
        const n = try std.fmt.parseInt(u8, num, 10);
        var i: usize = 0;
        while (i < boards.items.len) {
            if (std.mem.indexOfScalar(u8, &boards.items[i].squares, n)) |j| {
                const board = &boards.items[i];
                board.bit_set.set(j);
                if (board.hasWon()) {
                    if (boards.items.len == 1) {
                        return board.score() * n;
                    } else {
                        _ = boards.orderedRemove(i);
                        i -|= 1;
                    }
                }
            }
            i += 1;
        }
    }
    unreachable;
}
