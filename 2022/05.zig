const input = @embedFile("05.txt");

const std = @import("std");
const mem = std.mem;

const Stack = std.SinglyLinkedList(u8);
const NodePool = std.SegmentedList(Stack.Node, 64);

fn parseState(
    str: []const u8,
    nodes: *NodePool,
    allocator: mem.Allocator,
) ![9]Stack {
    var stacks = [1]Stack{.{}} ** 9;
    var rows = mem.splitBackwards(u8, str, "\n");
    _ = rows.next();
    while (rows.next()) |line| {
        const row = @ptrCast([*]const [4]u8, line)[0 .. line.len / 4 + 1];
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
    var iter = mem.tokenize(u8, inst, " ");
    _ = iter.next();
    ret.count = try std.fmt.parseInt(usize, iter.next().?, 10);
    _ = iter.next();
    ret.from = try std.fmt.parseInt(usize, iter.next().?, 10) - 1;
    _ = iter.next();
    ret.to = try std.fmt.parseInt(usize, iter.next().?, 10) - 1;
    return ret;
}

pub fn part1(allocator: mem.Allocator) ![9]u8 {
    const setup_end = mem.indexOf(u8, input, "\n\n").?;

    var nodes = NodePool{};
    defer nodes.deinit(allocator);
    var stacks = try parseState(input[0..setup_end], &nodes, allocator);

    var instructions = mem.tokenize(u8, input[setup_end + 2 ..], "\n");
    while (instructions.next()) |inst| {
        const in = try parseInstruction(inst);
        const from = &stacks[in.from];
        const to = &stacks[in.to];
        var i: usize = 0;
        while (i < in.count) : (i += 1) to.prepend(from.popFirst().?);
    }

    var ret: [9]u8 = undefined;
    for (stacks) |stack, i| {
        ret[i] = if (stack.first) |node| node.data else ' ';
    }
    return ret;
}

pub fn part2(allocator: mem.Allocator) ![9]u8 {
    const setup_end = mem.indexOf(u8, input, "\n\n").?;

    var nodes = NodePool{};
    defer nodes.deinit(allocator);
    var stacks = try parseState(input[0..setup_end], &nodes, allocator);

    var instructions = mem.tokenize(u8, input[setup_end + 2 ..], "\n");
    while (instructions.next()) |inst| {
        const in = try parseInstruction(inst);
        const from = &stacks[in.from];
        const to = &stacks[in.to];

        var tmp = Stack{};
        var i: usize = 0;
        while (i < in.count) : (i += 1) tmp.prepend(from.popFirst().?);
        while (tmp.popFirst()) |node| to.prepend(node);
    }

    var ret: [9]u8 = undefined;
    for (stacks) |stack, i| {
        ret[i] = if (stack.first) |node| node.data else ' ';
    }
    return ret;
}
