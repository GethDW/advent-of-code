const input = @embedFile("05.txt");

const std = @import("std");

fn parseState(
    str: []const u8,
    nodes: *std.SegmentedList(std.TailQueue(u8).Node, 0),
    allocator: std.mem.Allocator,
) ![9]std.TailQueue(u8) {
    var stacks = [1]std.TailQueue(u8){.{}} ** 9;
    var rows = std.mem.tokenize(u8, str, "\n");
    while (rows.next()) |line| {
        if (line[1] == '1') break;
        const row = @ptrCast([*]const [4]u8, line)[0 .. line.len / 4 + 1];
        std.debug.assert(row.len == 9);
        for (row) |e, i| {
            if (e[1] != ' ') {
                const node = try nodes.addOne(allocator);
                node.data = e[1];
                stacks[i].prepend(node);
            }
        }
    }
    return stacks;
}

const Inst = struct {
    count: usize,
    from: usize,
    to: usize,
};
fn parseInstruction(inst: []const u8) !Inst {
    var ret: Inst = undefined;
    var iter = std.mem.split(u8, inst, " ");
    _ = iter.next();
    ret.count = try std.fmt.parseInt(usize, iter.next().?, 10);
    _ = iter.next();
    ret.from = try std.fmt.parseInt(usize, iter.next().?, 10) - 1;
    _ = iter.next();
    ret.to = try std.fmt.parseInt(usize, iter.next().?, 10) - 1;
    return ret;
}

pub fn part1(allocator: std.mem.Allocator) ![]const u8 {
    const setup_end = std.mem.indexOf(u8, input, "\n\n").?;
    var instructions = std.mem.tokenize(u8, input[setup_end + 2 ..], "\n");
    var nodes = std.SegmentedList(std.TailQueue(u8).Node, 0){};
    defer nodes.deinit(allocator);
    var stacks = try parseState(input[0..setup_end], &nodes, allocator);

    while (instructions.next()) |inst| {
        const in = try parseInstruction(inst);
        const from: *std.TailQueue(u8) = &stacks[in.from];
        const to: *std.TailQueue(u8) = &stacks[in.to];
        var i: usize = 0;
        while (i < in.count) : (i += 1) to.append(from.pop().?);
    }

    var ret = std.ArrayListUnmanaged(u8){};
    for (stacks) |*stack| {
        if (stack.pop()) |node| try ret.append(allocator, node.data);
    }

    return try ret.toOwnedSlice(allocator);
}

pub fn part2(allocator: std.mem.Allocator) ![]const u8 {
    const setup_end = std.mem.indexOf(u8, input, "\n\n").?;
    var instructions = std.mem.tokenize(u8, input[setup_end + 2 ..], "\n");
    var nodes = std.SegmentedList(std.TailQueue(u8).Node, 0){};
    defer nodes.deinit(allocator);
    var stacks = try parseState(input[0..setup_end], &nodes, allocator);

    while (instructions.next()) |inst| {
        const in = try parseInstruction(inst);
        const from: *std.TailQueue(u8) = &stacks[in.from];
        const to: *std.TailQueue(u8) = &stacks[in.to];

        var tmp = std.TailQueue(u8){};
        var i: usize = 0;
        while (i < in.count) : (i += 1) tmp.append(from.pop().?);
        i = 0;
        while (i < in.count) : (i += 1) to.append(tmp.pop().?);
    }

    var ret = std.ArrayListUnmanaged(u8){};
    for (stacks) |*stack| {
        if (stack.pop()) |node| try ret.append(allocator, node.data);
    }

    return try ret.toOwnedSlice(allocator);
}
