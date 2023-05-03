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
    const Cwd = struct { name: []const u8, dir: *Dir };
    var dir_stack = std.ArrayList(Cwd).init(allocator);
    defer dir_stack.deinit();
    var root = Dir{};
    var cwd = Cwd{ .name = "/", .dir = &root };

    var cmds = std.mem.split(u8, input, "$ ");
    while (cmds.next()) |cmd| {
        if (std.mem.startsWith(u8, cmd, "cd")) {
            const dir_name = cmd["cd ".len .. cmd.len - 1];
            if (std.mem.eql(u8, dir_name, "/")) {
                dir_stack.clearRetainingCapacity();
                cwd = Cwd{ .name = "/", .dir = &root };
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
pub fn part1(input: []const u8, allocator: std.mem.Allocator) !usize {
    var root = try parseDir(input, allocator);
    defer freeDir(&root, allocator);
    var total: usize = 0;
    var stack = std.ArrayList(struct { Dir.Iterator, []const u8, usize }).init(allocator);
    defer stack.deinit();
    var it = root.iterator();
    var size: usize = 0;
    var name: []const u8 = "/";
    while (true) {
        while (it.next()) |entry| {
            switch (entry.value_ptr.*) {
                .file => |s| size += s,
                .dir => |dir| {
                    try stack.append(.{ it, name, size });
                    it = dir.iterator();
                    name = entry.key_ptr.*;
                    size = 0;
                },
            }
        }
        if (size <= 100_000) {
            total += size;
        }
        const s = stack.popOrNull() orelse break;
        it = s[0];
        name = s[1];
        size += s[2];
    }
    return total;
}

fn printDir(root: Dir, allocator: std.mem.Allocator) !void {
    var stack = std.ArrayList(Dir.Iterator).init(allocator);
    var it = root.iterator();
    std.debug.print("- / (dir)\n", .{});
    while (true) {
        while (it.next()) |entry| {
            std.debug.print("  ", .{});
            for (0..stack.items.len) |_| std.debug.print("  ", .{});
            switch (entry.value_ptr.*) {
                .file => |size| std.debug.print("- {s} (file, size={d})\n", .{ entry.key_ptr.*, size }),
                .dir => |dir| {
                    try stack.append(it);
                    it = dir.iterator();
                    std.debug.print("- {s} (dir)\n", .{entry.key_ptr.*});
                },
            }
        }
        it = stack.popOrNull() orelse break;
    }
}
