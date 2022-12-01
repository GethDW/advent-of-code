const input = @embedFile("02.txt");

const std = @import("std");

pub fn part1() !u32 {
    var x: u32 = 0;
    var y: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var iter = std.mem.tokenize(u8, line, " ");
        switch (iter.next().?[0]) {
            inline 'f', 'd', 'u' => |d| {
                const n = try std.fmt.parseInt(u32, iter.next().?, 10);
                switch (comptime d) {
                    'f' => x += n,
                    'd' => y += n,
                    'u' => y -= n,
                    else => @compileError("what"),
                }
            },
            else => unreachable,
        }
    }
    return x * y;
}

pub fn part2() !u32 {
    var x: u32 = 0;
    var y: u32 = 0;
    var aim: u32 = 0;
    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var iter = std.mem.tokenize(u8, line, " ");
        switch (iter.next().?[0]) {
            inline 'f', 'd', 'u' => |d| {
                const n = try std.fmt.parseInt(u32, iter.next().?, 10);
                switch (comptime d) {
                    'f' => {
                        x += n;
                        y += aim * n;
                    },
                    'd' => aim += n,
                    'u' => aim -= n,
                    else => @compileError("what"),
                }
            },
            else => unreachable,
        }
    }
    return x * y;
}
