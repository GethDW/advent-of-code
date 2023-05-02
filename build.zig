const std = @import("std");

const Year = enum { @"2015", @"2021", @"2022" };
const Solution = struct {
    name: []const u8,
    path: []const u8,
    input: ?[]const u8,
    example: ?[]const u8,
    year: Year,
    module: *std.Build.Module,
};

fn getSolutions(b: *std.build.Builder, year: Year) []const Solution {
    var list = std.ArrayList(Solution).init(b.allocator);
    defer list.deinit();

    var src = b.build_root.handle.openDir(@tagName(year), .{}) catch unreachable;
    defer src.close();
    for (1..26) |n| {
        const number = b.fmt("{d:0>2}", .{n});
        const sub_path = b.fmt("{s}.zig", .{number});
        const path = b.pathJoin(&.{ @tagName(year), sub_path });
        if (src.access(sub_path, .{}) == error.FileNotFound) continue;

        const input_path = b.fmt("{s}.txt", .{number});
        const example_path = b.fmt("{s}_example.txt", .{number});
        list.append(Solution{
            .name = number,
            .path = path,
            .input = if (src.access(input_path, .{}) != error.FileNotFound) b.pathJoin(&.{ @tagName(year), input_path }) else null,
            .example = if (src.access(example_path, .{}) != error.FileNotFound) b.pathJoin(&.{ @tagName(year), example_path }) else null,
            .year = year,
            .module = b.createModule(.{ .source_file = .{ .path = path } }),
        }) catch unreachable;
    }

    return list.toOwnedSlice() catch unreachable;
}

const Action = enum { run, @"test", alloc_test, compile };
fn addSolution(
    b: *std.Build,
    solution: Solution,
    action: Action,
    use_example: bool,
    filter: ?[]const u8,
    optimize: std.builtin.Mode,
    target: std.zig.CrossTarget,
) *std.Build.Step {
    var config = b.addOptions();
    config.addOption([]const u8, "number", solution.name);
    config.addOption([]const u8, "year", @tagName(solution.year));
    config.addOption(bool, "example", use_example);

    return switch (action) {
        inline .compile, .run => blk: {
            // executable for run action.
            const exe = b.addExecutable(.{
                .name = solution.name,
                .root_source_file = .{ .path = "build/solution_runner.zig" },
                .target = target,
                .optimize = optimize,
            });
            if (solution.input) |input| exe.addModule("input", b.createModule(.{ .source_file = .{ .path = input } }));
            if (solution.example) |example| exe.addModule("example", b.createModule(.{ .source_file = .{ .path = example } }));
            exe.addModule("solution", solution.module);
            exe.addOptions("config", config);

            switch (comptime action) {
                .compile => break :blk &exe.step,
                .run => {
                    const run_cmd = b.addRunArtifact(exe);
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
                .optimize = optimize,
            });
            test_exe.filter = filter;
            break :blk &test_exe.step;
        },
        .alloc_test => blk: {
            const test_exe = b.addTest(.{
                .root_source_file = .{ .path = "build/solution_runner.zig" },
                .target = target,
                .optimize = optimize,
            });
            test_exe.filter = "__allocations";
            test_exe.addAnonymousModule("solution", .{
                .source_file = .{ .path = solution.path },
            });

            break :blk &test_exe.step;
        },
    };
}

pub fn build(b: *std.build.Builder) !void {
    // remove install and uninstall steps, and override default step.
    b.top_level_steps.clearRetainingCapacity();
    const year = b.option(Year, "year", "Select a year") orelse .@"2022";
    const all = b.step("all", b.fmt("Run all solutions ({s})", .{@tagName(year)}));
    b.default_step = all;

    // option to decide what to do with the chosen solution.
    const action = b.option(
        Action,
        "mode",
        "Choose what to do with a solution (default is run)",
    ) orelse .run;
    const use_example = b.option(bool, "example", "run solution with example input") orelse false;

    const filter = b.option([]const u8, "filter", "Test filter");

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const solutions = getSolutions(b, year);
    for (solutions) |solution| {
        const step = b.step(solution.name, b.fmt("Run solution for day {s}", .{solution.name}));
        const solution_step = addSolution(b, solution, action, use_example, filter, optimize, target);
        step.dependOn(solution_step);
        all.dependOn(solution_step);
    }
}
