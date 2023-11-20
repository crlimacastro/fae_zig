const raylib = @import("raylib");
const raylib_math = @import("raylib-math");

pub const Transform2 = struct {
    position: raylib.Vector2,

    pub fn init(position: raylib.Vector2) @This() {
        return @This(){
            .position = position,
        };
    }

    pub fn default() @This() {
        return @This(){
            .position = raylib_math.vector2Zero(),
        };
    }
};

pub const RigidBody2 = struct {
    acceleration: raylib.Vector2,
    velocity: raylib.Vector2,

    pub fn init(acceleration: raylib.Vector2, velocity: raylib.Vector2) @This() {
        return .{
            .acceleration = acceleration,
            .velocity = velocity,
        };
    }

    pub fn default() @This() {
        return .{
            .acceleration = raylib_math.vector2Zero(),
            .velocity = raylib_math.vector2Zero(),
        };
    }
};
