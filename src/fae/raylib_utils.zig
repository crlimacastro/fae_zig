const raylib = @import("raylib");

pub fn getScreenWidthAsf32() f32 {
    return @as(f32, @floatFromInt(raylib.getScreenWidth()));
}

pub fn getScreenHeightAsf32() f32 {
    return @as(f32, @floatFromInt(raylib.getScreenHeight()));
}
