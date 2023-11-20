const zig_ecs = @import("zig-ecs");

pub const Entity = struct {
    entity: zig_ecs.Entity,
    registry: *zig_ecs.Registry,

    pub fn init(entity: zig_ecs.Entity, registry: *zig_ecs.Registry) @This() {
        return @This(){
            .entity = entity,
            .registry = registry,
        };
    }

    pub fn valid(self: @This()) bool {
        return self.registry.valid(self.entity);
    }

    pub fn add(self: *@This(), value: anytype) void {
        self.registry.add(self.entity, value);
    }

    pub fn has(self: @This(), comptime T: type) bool {
        return self.registry.has(T, self.entity);
    }

    pub fn get(self: *@This(), comptime T: type) *T {
        return self.registry.get(T, self.entity);
    }

    pub fn getConst(self: @This(), comptime T: type) T {
        return self.registry.getConst(T, self.entity);
    }

    pub fn getOrAdd(self: *@This(), comptime T: type) *T {
        return self.registry.getOrAdd(T, self.entity);
    }

    pub fn tryGet(self: *@This(), comptime T: type) ?*T {
        return self.registry.tryGet(T, self.entity);
    }

    pub fn tryGetConst(self: @This(), comptime T: type) ?T {
        return self.registry.tryGetConst(T, self.entity);
    }

    pub fn notifyUpdated(self: *@This(), comptime T: type) void {
        self.registry.notifyUpdated(T, self.entity);
    }

    pub fn remove(self: *@This(), comptime T: type) void {
        self.registry.remove(T, self.entity);
    }

    pub fn removeIfExists(self: *@This(), comptime T: type) void {
        self.registry.removeIfExists(T, self.entity);
    }

    pub fn fetchRemove(self: *@This(), comptime T: type) ?T {
        self.registry.fetchRemove(T, self.entity);
    }
};
