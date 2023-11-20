const zig_ecs = @import("zig-ecs");
const raylib = @import("raylib");
const application = @import("application.zig");
const Application = application.Application;
const ApplicationStep = application.ApplicationStep;
const UpdateStep = application.UpdateStep;
const components = @import("components.zig");
const Transform2 = components.Transform2;

pub const DrawStep = struct {
    step: ApplicationStep,

    pub fn init(registry: *zig_ecs.Registry, dispatcher: *zig_ecs.Dispatcher) @This() {
        return @This(){
            .step = ApplicationStep.init(registry, dispatcher),
        };
    }
};

pub const Rectangle = struct {
    size: raylib.Vector2,

    pub fn init(size: raylib.Vector2) @This() {
        return @This(){
            .size = size,
        };
    }

    pub fn default() @This() {
        return @This(){
            .size = raylib.Vector2.init(1, 1),
        };
    }
};

pub const Tint = struct {
    color: raylib.Color,

    pub fn init(color: raylib.Color) @This() {
        return @This(){
            .color = color,
        };
    }

    pub fn default() @This() {
        return @This(){
            .color = raylib.Color.black,
        };
    }
};

pub fn drawPlugin(app: *Application) void {
    app.addSystem(UpdateStep, invokeDrawStep);
    app.addSystem(DrawStep, drawSquares);
}

pub fn invokeDrawStep(step: UpdateStep) void {
    raylib.beginDrawing();
    defer raylib.endDrawing();

    raylib.clearBackground(raylib.Color.ray_white);
    step.step.invoke(DrawStep, DrawStep.init(step.step.registry, step.step.dispatcher));
}

pub fn drawSquares(step: DrawStep) void {
    var view = step.step.query(.{ Transform2, Rectangle, Tint }, .{});
    var iter = view.entityIterator();
    while (iter.next()) |entity| {
        const transform = view.getConst(Transform2, entity);
        const rectangle = view.getConst(Rectangle, entity);
        const tint = view.getConst(Tint, entity);
        raylib.drawRectangle(
            @as(i32, @intFromFloat(transform.position.x - rectangle.size.x / 2.0)),
            @as(i32, @intFromFloat(transform.position.y - rectangle.size.y / 2.0)),
            @as(i32, @intFromFloat(rectangle.size.x)),
            @as(i32, @intFromFloat(rectangle.size.y)),
            tint.color,
        );
    }
}
