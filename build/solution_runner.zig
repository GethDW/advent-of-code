const std = @import("std");
const builtin = @import("builtin");
const config = @import("config");
const solution = @import("solution");

const mem = std.mem;
const Allocator = mem.Allocator;
const heap = std.heap;
const GeneralPurposeAllocator = heap.GeneralPurposeAllocator(.{});
const ArenaAllocator = heap.ArenaAllocator;
const StatAllocator = @import("StatAllocator.zig");

fn returnInfo(comptime part: type) struct {
    payload: type,
    error_set: ?type,
} {
    const ErrorRetureType = switch (@typeInfo(part)) {
        .Fn, .BoundFn => |f| f.return_type orelse unreachable,
        else => unreachable,
    };
    return switch (@typeInfo(ErrorRetureType)) {
        .ErrorUnion => |info| .{ .payload = info.payload, .error_set = info.error_set },
        else => .{ .payload = ErrorRetureType, .error_set = null },
    };
}
fn AnswerType(comptime part: type) type {
    return returnInfo(part).payload;
}
fn AnswerError(comptime part: type) type {
    return if (returnInfo(part).error_set) |E| E else error{};
}
inline fn run(comptime F: type, part: F, allocator: std.mem.Allocator) !AnswerType(F) {
    const args = switch (ArgsTuple(F)) {
        Tuple(&[_]type{}) => .{}, // `struct {}` is still a struct.
        Tuple(&[_]type{Allocator}) => .{allocator},
        else => @compileError("solve arguments are either empty or std.mem.Allocator"),
    };
    return switch (AnswerError(F)) {
        error{} => @call(.{ .modifier = .always_inline }, part, args),
        else => try @call(.{ .modifier = .always_inline }, part, args),
    };
}
const ArgsTuple = std.meta.ArgsTuple;
const Tuple = std.meta.Tuple;
fn solve(part: anytype, gpa: Allocator, use_arena: bool, format: ?[]const Fmt, writer: anytype) !void {
    const F = @TypeOf(part);
    var arena = ArenaAllocator.init(gpa);
    defer arena.deinit();
    var stat_allocator = StatAllocator.init(if (use_arena) arena.allocator() else gpa);
    const allocator: Allocator = stat_allocator.allocator();
    var answer: ?AnswerType(F) = null;
    var time: u64 = 0;
    for (format orelse &[_]Fmt{.answer}) |fmt| {
        switch (fmt) {
            .answer, .time, .max_mem, .tot_mem, .allocations => {
                if (answer) |_| {} else {
                    var timer = try std.time.Timer.start();
                    answer = try run(F, part, allocator);
                    time = timer.read();
                }
            },
            else => {},
        }
        switch (fmt) {
            .answer => switch (@typeInfo(AnswerType(F))) {
                .Int, .Float => try writer.print("{d}", .{answer.?}),
                else => try writer.print("{any}", .{answer.?}),
            },
            .time => try writer.print("{}", .{std.fmt.fmtDuration(time)}),
            .max_mem => try writer.print("{}", .{std.fmt.fmtIntSizeDec(stat_allocator.max_bytes)}),
            .tot_mem => try writer.print("{}", .{std.fmt.fmtIntSizeDec(stat_allocator.total_bytes)}),
            .allocations => try writer.print("{d}", .{stat_allocator.allocs}),
            .build => try writer.print("{s}", .{@tagName(builtin.mode)}),
            .string => |str| try writer.writeAll(str),
        }
    }
    try writer.writeByte('\n');
}

const Fmt = union(enum) {
    time,
    max_mem,
    tot_mem,
    allocations,
    answer,
    build,
    string: []const u8,

    pub fn parse(allocator: Allocator, fmt: []const u8) ![]const Fmt {
        var format_list = std.ArrayList(Fmt).init(allocator);
        errdefer format_list.deinit();
        var i: usize = 0;
        while (i < fmt.len) {
            switch (fmt[i]) {
                '{' => {
                    const end = mem.indexOfScalarPos(u8, fmt, i + 1, '}') orelse die("missing closing }}\n", .{}, 1);
                    const specifier = fmt[i + 1 .. end];
                    i = end + 1;

                    if (specifier.len == 1) switch (specifier[0]) {
                        't' => try format_list.append(.time),
                        'm' => try format_list.append(.max_mem),
                        'M' => try format_list.append(.tot_mem),
                        'A' => try format_list.append(.allocations),
                        'a' => try format_list.append(.answer),
                        'b' => try format_list.append(.build),
                        else => die("unknown format specifier {{{s}}}\n{s}\n", .{ specifier, usage }, 1),
                    } else die("unknown format specifier {{{s}}}\n{s}\n", .{ specifier, usage }, 1);
                },
                else => {
                    const end = mem.indexOfAnyPos(u8, fmt, i, "{") orelse fmt.len;
                    try format_list.append(.{ .string = fmt[i..end] });
                    i = end;
                },
            }
        }

        return format_list.toOwnedSlice();
    }
};

const Flags = enum {
    fmt,
    arena,
    help,

    const map = std.ComptimeStringMap(Flags, blk: {
        const info = @typeInfo(Flags).Enum;
        var ret: [info.fields.len]struct { []const u8, Flags } = undefined;
        for (info.fields) |field, i| ret[i] = .{ "--" ++ field.name, @intToEnum(Flags, field.value) };
        break :blk ret;
    });

    pub fn get(str: []const u8) ?Flags {
        return map.get(str);
    }
};

const usage =
    \\Usage:
    \\  --help          print this help text.
    \\  --arena         run solution with arena allocation.
    \\  --fmt <string>  provide a format string to cutomize output,
    \\                  format specifiers are marked by surrounding
    \\                  with {}:
    \\                      {a}     solution answer
    \\                      {m}     max memory used
    \\                      {M}     total memory used
    \\                      {A}     the number of allocations made
    \\                      {t}     time the solution took to run
    \\                      {b}     build mode
;
const wants_arena: bool = if (@hasDecl(solution, "arena")) solution.arena else false;
pub fn main() !void {
    var gpa = GeneralPurposeAllocator{};
    defer if (gpa.deinit()) die("memory leak detected\n", .{}, 1);
    const allocator = gpa.allocator();

    var use_arena = wants_arena;
    var format: ?[]const Fmt = null;
    defer if (format) |fmt| allocator.free(fmt);
    var args = try std.process.ArgIterator.initWithAllocator(allocator);
    _ = args.next(); // proc name
    while (args.next()) |arg| {
        if (Flags.get(arg)) |flag| {
            switch (flag) {
                .arena => use_arena = true,
                .fmt => {
                    if (format != null) die("only one format string can be specified\n", .{}, 1);
                    if (args.next()) |fmt| {
                        format = try Fmt.parse(allocator, fmt);
                    } else die("expected format string after argument fmt\n{s}\n", .{usage}, 1);
                },
                .help => die("{s}\n", .{usage}, 0),
            }
        } else die("unknown argument {s}\n", .{arg}, 1);
    }
    args.deinit();

    const stdout = std.io.getStdOut().writer();
    if (comptime std.meta.trait.hasFn("part1")(solution)) {
        try stdout.print("{s}-1: ", .{config.number});
        try solve(solution.part1, allocator, use_arena, format, stdout);
        if (comptime std.meta.trait.hasFn("part2")(solution)) {
            try stdout.print("{s}-2: ", .{config.number});
            try solve(solution.part2, allocator, use_arena, format, stdout);
        }
    } else @compileError("missing `pub fn part1`");
}

inline fn die(comptime fmt: []const u8, args: anytype, exit_code: u8) noreturn {
    std.io.getStdErr().writer().print(fmt, args) catch {};
    std.process.exit(exit_code);
}

const testing = std.testing;
test "__allocations" {
    inline for (.{ "part1", "part2" }) |part| {
        if (comptime std.meta.trait.hasFn(part)(solution)) {
            const f = @field(solution, part);
            const F = @TypeOf(f);
            if (ArgsTuple(F) == struct { Allocator }) {
                try testing.checkAllAllocationFailures(testing.allocator, f, .{});
            }
        }
    }
}
