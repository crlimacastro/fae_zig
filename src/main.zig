const std = @import("std");
const raylib = @import("raylib");
const raylib_math = @import("raylib-math");
const zig_ecs = @import("zig-ecs");
const fae = @import("fae.zig");

pub const Inputs = struct {
    moveInput: raylib.Vector2,

    pub fn getMoveInput(self: @This()) raylib.Vector2 {
        return self.moveInput;
    }

    pub fn setMoveInput(self: *@This(), value: raylib.Vector2) void {
        self.moveInput = raylib_math.vector2Normalize(value);
    }
};

pub const TopdownCharacterController = struct {
    moveSpeed: f32 = 1024,
};

pub const Player = struct {};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa_allocator = gpa.allocator();

    var app = fae.Application.init(gpa_allocator);
    defer app.deinit();

    app.addPlugin(fae.drawPlugin);

    app.addSingleton(Inputs{
        .moveInput = raylib_math.vector2Zero(),
    });

    app.addSystem(fae.StartStep, startSystem);
    app.addSystem(fae.UpdateStep, updateSystem);
    app.addSystem(fae.UpdateStep, inputSystem);
    app.addSystem(fae.UpdateStep, playerMoveSystem);
    app.addSystem(fae.UpdateStep, physicsSystem);
    app.addSystem(fae.DrawStep, drawSystem);

    var e = app.createEntity();
    e.add(Player{});
    e.add(fae.Transform2{
        .position = raylib.Vector2.init(fae.getScreenWidthAsf32() / 2.0, fae.getScreenHeightAsf32() / 2.0),
    });
    e.add(fae.RigidBody2.default());
    e.add(TopdownCharacterController{});
    e.add(fae.Rectangle.init(raylib.Vector2.init(100, 100)));
    e.add(fae.Tint.init(raylib.Color.red));

    app.run();
}

pub fn startSystem(step: fae.StartStep) void {
    _ = step;
}

pub fn updateSystem(step: fae.UpdateStep) void {
    _ = step;
}

pub fn drawSystem(e: fae.DrawStep) void {
    _ = e;
    defer raylib.drawFPS(4, 4);
}

pub fn inputSystem(step: fae.UpdateStep) void {
    if (!step.step.hasSingleton(Inputs)) {
        return;
    }
    var inputs = step.step.getSingleton(Inputs);
    var moveDirection = raylib_math.vector2Zero();
    if (raylib.isKeyDown(.key_w)) {
        moveDirection.y += -1;
    }
    if (raylib.isKeyDown(.key_a)) {
        moveDirection.x += -1;
    }
    if (raylib.isKeyDown(.key_s)) {
        moveDirection.y += 1;
    }
    if (raylib.isKeyDown(.key_d)) {
        moveDirection.x += 1;
    }
    moveDirection = raylib_math.vector2Normalize(moveDirection);
    inputs.*.setMoveInput(moveDirection);
}

pub fn playerMoveSystem(step: fae.UpdateStep) void {
    if (!step.step.hasSingleton(Inputs)) {
        return;
    }
    const inputs = step.step.getConstSingleton(Inputs);

    var view = step.step.query(.{ Player, TopdownCharacterController, fae.RigidBody2 }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const controller = view.getConst(TopdownCharacterController, entity);
        var rigidBody = view.get(fae.RigidBody2, entity);
        rigidBody.*.velocity = raylib_math.vector2Scale(inputs.getMoveInput(), controller.moveSpeed);
    }
}

pub fn physicsSystem(step: fae.UpdateStep) void {
    const dt = raylib.getFrameTime();

    var view = step.step.query(.{ fae.Transform2, fae.RigidBody2 }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const rigidBody = view.getConst(fae.RigidBody2, entity);
        var transform = view.get(fae.Transform2, entity);
        transform.*.position = raylib_math.vector2Add(transform.*.position, raylib_math.vector2Scale(rigidBody.velocity, dt));
    }
}
