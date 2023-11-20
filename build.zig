const std = @import("std");
const raylib_zig_build = @import("external/raylib-zig/build.zig");
const zig_ecs_build = @import("external/zig-ecs/build.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_mod = raylib_zig_build.getModule(b, "external/raylib-zig");
    const raylib_math_mod = raylib_zig_build.math.getModule(b, "external/raylib-zig");
    const zig_ecs_mod = if (b.modules.contains("zig-ecs")) b.modules.get("zig-ecs") else b.addModule("zig-ecs", .{ .source_file = .{ .path = "external/zig-ecs/src/ecs.zig" } });

    const exe = b.addExecutable(.{
        .name = "fae_zig",
        .root_source_file = .{ .path = "src/main.zig" },
        .optimize = optimize,
        .target = target,
    });

    raylib_zig_build.link(b, exe, target, optimize);

    exe.addModule("raylib", raylib_mod);
    exe.addModule("raylib-math", raylib_math_mod);
    if (zig_ecs_mod != null) {
        exe.addModule("zig-ecs", zig_ecs_mod.?);
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
