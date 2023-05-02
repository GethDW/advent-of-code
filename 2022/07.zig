const std = @import("std");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("\n\n", .{});
    var path = std.ArrayList([]const u8).init(allocator);
    defer path.deinit();
    var cmds = std.mem.split(u8, input, "$ ");
    while (cmds.next()) |cmd| {
        if (std.mem.startsWith(u8, cmd, "cd")) {
            const dir = cmd["cd ".len .. cmd.len - 1];
            if (std.mem.eql(u8, dir, ".."))
                _ = path.pop()
            else
                try path.append(dir);
            std.debug.print("{s}\n", .{path.items});
        } else if (std.mem.startsWith(u8, cmd, "ls")) {
            var entries = std.mem.tokenize(u8, cmd, "\n");
            _ = entries.next();
            while (entries.next()) |entry| {
                std.debug.print("{s}\n", .{entry});
            }
        }
    }
    std.debug.print("\n", .{});
}
