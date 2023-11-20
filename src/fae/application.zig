const std = @import("std");
const raylib = @import("raylib");
const zig_ecs = @import("zig-ecs");
const entity = @import("entity.zig");
const Entity = entity.Entity;

pub const Plugin = fn (*Application) void;

pub const ApplicationStep = struct {
    registry: *zig_ecs.Registry,
    dispatcher: *zig_ecs.Dispatcher,

    pub fn init(registry: *zig_ecs.Registry, dispatcher: *zig_ecs.Dispatcher) @This() {
        return @This(){
            .registry = registry,
            .dispatcher = dispatcher,
        };
    }

    pub fn createEntity(self: *@This()) Entity {
        return Entity.init(self.registry.create(), self.registry);
    }

    pub fn addSingleton(self: *@This(), instance: anytype) void {
        self.registry.singletons().*.add(instance);
    }

    pub fn hasSingleton(self: @This(), comptime T: type) bool {
        return self.registry.singletons().*.has(T);
    }

    pub fn getSingleton(self: @This(), comptime T: type) *T {
        return self.registry.singletons().*.get(T);
    }

    pub fn getConstSingleton(self: @This(), comptime T: type) T {
        return self.registry.singletons().*.getConst(T);
    }

    pub fn getOrAddSingleton(self: *@This(), comptime T: type) *T {
        return self.registry.singletons().*.getOrAdd(T);
    }

    pub fn removeSingleton(self: *@This(), comptime T: type) void {
        return self.registry.singletons().*.remove(T);
    }

    pub fn invoke(self: @This(), comptime T: type, value: T) void {
        self.dispatcher.trigger(T, value);
    }

    pub fn query(self: @This(), comptime includes: anytype, comptime excludes: anytype) zig_ecs.Registry.ViewType(includes, excludes) {
        return self.registry.view(includes, excludes);
    }
};

pub const StartStep = struct {
    step: ApplicationStep,

    pub fn init(registry: *zig_ecs.Registry, dispatcher: *zig_ecs.Dispatcher) @This() {
        return @This(){
            .step = ApplicationStep.init(registry, dispatcher),
        };
    }
};

pub const UpdateStep = struct {
    step: ApplicationStep,

    pub fn init(registry: *zig_ecs.Registry, dispatcher: *zig_ecs.Dispatcher) @This() {
        return @This(){
            .step = ApplicationStep.init(registry, dispatcher),
        };
    }
};

pub const Application = struct {
    registry: zig_ecs.Registry,
    dispatcher: zig_ecs.Dispatcher,

    pub fn init(allocator: std.mem.Allocator) @This() {
        raylib.setConfigFlags(raylib.ConfigFlags.flag_window_resizable);
        raylib.initWindow(1920, 1080, "");
        // rl.setExitKey(rl.KeyboardKey.key_null);
        // rl.setTargetFPS(60);
        return .{
            .registry = zig_ecs.Registry.init(allocator),
            .dispatcher = zig_ecs.Dispatcher.init(allocator),
        };
    }

    pub fn deinit(self: @This()) void {
        _ = self;
        defer raylib.closeWindow();
    }

    pub fn isRunning(self: @This()) bool {
        _ = self;
        return !raylib.windowShouldClose();
    }

    pub fn createEntity(self: *@This()) Entity {
        return Entity.init(self.registry.create(), &self.registry);
    }

    pub fn addSystem(self: *@This(), comptime T: type, system: *const fn (T) void) void {
        self.dispatcher.sink(T).connect(system);
    }

    pub fn addSingleton(self: *@This(), instance: anytype) void {
        self.registry.singletons().*.add(instance);
    }

    pub fn hasSingleton(self: @This(), comptime T: type) bool {
        return self.registry.singletons().*.has(T);
    }

    pub fn getSingleton(self: *@This(), comptime T: type) *T {
        return self.registry.singletons().*.get(T);
    }

    pub fn getConstSingleton(self: @This(), comptime T: type) T {
        return self.registry.singletons().*.getConst(T);
    }

    pub fn getOrAddSingleton(self: *@This(), comptime T: type) *T {
        return self.registry.singletons().*.getOrAdd(T);
    }

    pub fn removeSingleton(self: *@This(), comptime T: type) void {
        return self.registry.singletons().*.remove(T);
    }

    pub fn addPlugin(self: *@This(), comptime plugin: *const Plugin) void {
        plugin.*(self);
    }

    pub fn run(self: *@This()) void {
        self.dispatcher.trigger(StartStep, StartStep.init(&self.registry, &self.dispatcher));
        while (self.isRunning()) {
            self.dispatcher.trigger(UpdateStep, UpdateStep.init(&self.registry, &self.dispatcher));
        }
    }
};
