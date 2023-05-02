const std = @import("std");

pub fn part1(input: []const u8, allocator: std.mem.Allocator) !void {
    std.debug.print("\n", .{});
    var nums = std.ArrayList(u3).init(allocator);
    defer nums.deinit();
    for (std.mem.bytesAsSlice([2]u8, input)) |x| {
        try nums.append(@intCast(u3, x[0] - '0'));
    }
    std.debug.print("{d}\n", .{nums.items});
    for (nums.items) |*n| n.* -%= 1;
    std.debug.print("{d}\n", .{nums.items});
}
