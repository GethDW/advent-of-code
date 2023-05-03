const std = @import("std");

const Dir = std.StringArrayHashMapUnmanaged(Entry);
const Entry = union(enum) {
    file: u64,
    dir: Dir,
};
fn freeDir(dir: *Dir, allocator: std.mem.Allocator) void {
    var it = dir.iterator();
    while (it.next()) |entry| {
        switch (entry.value_ptr.*) {
            .file => {},
            .dir => |*d| freeDir(d, allocator),
        }
    }
    dir.deinit(allocator);
}

fn parseDir(input: []const u8, allocator: std.mem.Allocator) !Dir {
    const CurrentDir = struct { name: []const u8, dir: *Dir };
    var dir_stack = std.ArrayList(CurrentDir).init(allocator);
    defer dir_stack.deinit();
    var root = Dir{};
    var cwd = CurrentDir{ .name = "/", .dir = &root };

    var cmds = std.mem.split(u8, input, "$ ");
    while (cmds.next()) |cmd| {
        if (std.mem.startsWith(u8, cmd, "cd")) {
            const dir_name = cmd["cd ".len .. cmd.len - 1];
            if (std.mem.eql(u8, dir_name, "/")) {
                dir_stack.clearRetainingCapacity();
                cwd = .{ .name = "/", .dir = &root };
            } else if (std.mem.eql(u8, dir_name, "..")) {
                cwd = dir_stack.pop();
            } else {
                try dir_stack.append(cwd);
                const gop = try cwd.dir.getOrPut(allocator, dir_name);
                if (!gop.found_existing) {
                    gop.value_ptr.* = .{ .dir = .{} };
                    gop.key_ptr.* = dir_name;
                }
                cwd = .{ .name = gop.key_ptr.*, .dir = &gop.value_ptr.dir };
            }
        } else if (std.mem.startsWith(u8, cmd, "ls")) {
            var entries = std.mem.tokenize(u8, cmd, "\n");
            _ = entries.next();
            while (entries.next()) |entry| {
                if (std.mem.startsWith(u8, entry, "dir ")) {
                    try cwd.dir.put(allocator, entry["dir ".len..], .{ .dir = .{} });
                } else {
                    const middle = std.mem.indexOfScalar(u8, entry, ' ').?;
                    const size = try std.fmt.parseInt(u64, entry[0..middle], 10);
                    const name = entry[middle + 1 ..];
                    try cwd.dir.put(allocator, name, .{ .file = size });
                }
            }
        }
    }

    return root;
}

const Cwd = struct { dir: Dir.Iterator, size: usize };
pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var root = try parseDir(input, allocator);
    defer freeDir(&root, allocator);
    var total: usize = 0;
    var stack = std.ArrayList(Cwd).init(allocator);
    defer stack.deinit();
    var cwd = Cwd{ .dir = root.iterator(), .size = 0 };
    while (true) {
        while (cwd.dir.next()) |entry| {
            switch (entry.value_ptr.*) {
                .file => |s| cwd.size += s,
                .dir => |dir| {
                    try stack.append(cwd);
                    cwd = .{ .dir = dir.iterator(), .size = 0 };
                },
            }
        }
        if (cwd.size <= 100_000) {
            total += cwd.size;
        }
        const new_cwd = stack.popOrNull() orelse break;
        cwd = .{ .dir = new_cwd.dir, .size = new_cwd.size + cwd.size };
    }
    return total;
}

pub fn part2(input: []const u8, allocator: std.mem.Allocator) !usize {
    var root = try parseDir(input, allocator);
    defer freeDir(&root, allocator);
    const total: usize = 70_000_000;
    const needed: usize = 30_000_000;
    var sizes = std.ArrayList(usize).init(allocator);
    defer sizes.deinit();
    var stack = std.ArrayList(Cwd).init(allocator);
    defer stack.deinit();
    var cwd = Cwd{ .dir = root.iterator(), .size = 0 };
    while (true) {
        while (cwd.dir.next()) |entry| {
            switch (entry.value_ptr.*) {
                .file => |s| cwd.size += s,
                .dir => |dir| {
                    try stack.append(cwd);
                    cwd = .{ .dir = dir.iterator(), .size = 0 };
                },
            }
        }
        try sizes.append(cwd.size);
        const new_cwd = stack.popOrNull() orelse break;
        cwd = .{ .dir = new_cwd.dir, .size = new_cwd.size + cwd.size };
    }
    const used = cwd.size;
    const unused = total - used;
    const to_remove = needed - unused;
    var min: usize = std.math.maxInt(usize);
    for (sizes.items) |size| {
        if (size >= to_remove) {
            min = @min(min, size);
        }
    }
    return min;
}
