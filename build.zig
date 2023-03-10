const std = @import("std");

const Solution = struct {
    name: []const u8,
    path: []const u8,
};
fn getSolutions(b: *std.build.Builder, year: []const u8) []const Solution {
    var list = std.ArrayList(Solution).init(b.allocator);
    defer list.deinit();

    var src = std.fs.openDirAbsolute(b.pathFromRoot(year), .{}) catch return &.{};
    defer src.close();
    var n: u8 = 1;
    while (n <= 25) : (n += 1) {
        const path = b.fmt("{d:0>2}.zig", .{n});
        src.access(path, .{}) catch continue;
        list.append(Solution{
            .name = b.fmt("{d:0>2}", .{n}),
            .path = b.pathJoin(&.{ year, path }),
        }) catch unreachable;
    }

    return list.toOwnedSlice() catch unreachable;
}

const Action = enum { run, @"test", alloc_test, compile };
fn addSolutions(
    b: *std.Build,
    all: *std.Build.Step,
    action: Action,
    filter: ?[]const u8,
    opt: std.builtin.Mode,
    target: std.zig.CrossTarget,
    year: []const u8,
) void {
    const solutions = getSolutions(b, year);
    for (solutions) |solution| {
        const step = b.step(solution.name, b.fmt("Run solution for day {s} ({s})", .{ solution.name, year }));
        var config = b.addOptions();
        config.addOption([]const u8, "number", solution.name);
        config.addOption([]const u8, "year", year);

        const action_step = switch (action) {
            inline .compile, .run => blk: {
                // executable for run action.
                const exe = b.addExecutable(.{
                    .name = solution.name,
                    .root_source_file = .{ .path = "build/solution_runner.zig" },
                    .target = target,
                    .optimize = opt,
                });
                exe.addAnonymousModule("solution", .{
                    .source_file = .{ .path = solution.path },
                });
                exe.addOptions("config", config);

                switch (comptime action) {
                    .compile => break :blk &exe.step,
                    .run => {
                        const run_cmd = exe.run();
                        run_cmd.step.dependOn(b.getInstallStep());
                        if (b.args) |args| run_cmd.addArgs(args);
                        break :blk &run_cmd.step;
                    },
                    else => unreachable,
                }
            },
            .@"test" => blk: {
                // test for solution.
                const test_exe = b.addTest(.{
                    .root_source_file = .{ .path = solution.path },
                    .target = target,
                    .optimize = opt,
                });
                test_exe.filter = filter;
                break :blk &test_exe.step;
            },
            .alloc_test => blk: {
                const test_exe = b.addTest(.{
                    .root_source_file = .{ .path = "build/solution_runner.zig" },
                    .target = target,
                    .optimize = opt,
                });
                test_exe.filter = "__allocations";
                test_exe.addAnonymousModule("solution", .{
                    .source_file = .{ .path = solution.path },
                });

                break :blk &test_exe.step;
            },
        };
        step.dependOn(action_step);
        all.dependOn(action_step);
    }
}
const Year = enum { @"2021", @"2022" };
pub fn build(b: *std.build.Builder) !void {
    const year = @tagName(b.option(Year, "year", "Select a year") orelse .@"2022");
    // remove install and uninstall steps, and override default step.
    b.top_level_steps.clearRetainingCapacity();
    const all = b.step("all", b.fmt("Run all solutions ({s})", .{year}));
    b.default_step = all;

    // option to decide what to do with the chosen solution.
    const action = b.option(
        Action,
        "mode",
        "Choose what to do with a solution (default is run)",
    ) orelse .run;

    const filter = b.option([]const u8, "filter", "Test filter");

    const target = b.standardTargetOptions(.{});
    const opt = b.standardOptimizeOption(.{});

    addSolutions(b, all, action, filter, opt, target, year);
}
