const std = @import("std");
const functions = @import("functions.zig");

const types = struct {
    pub const enums = @import("enums/fields.zig");
    pub const structs = @import("structs/fields.zig");
};

pub usingnamespace types;

pub fn of(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .Enum => types.enums,
        .Struct => types.structs,
        else => |f| @compileError("Not supported: " + @tagName(f)),
    };
}

pub fn method(comptime T: type, comptime name: []const u8, args: functions.params.tuple(@TypeOf(@field(of(T), name)))) functions.returnOf(@TypeOf(@field(of(T), name))) {
    const m = of(T);
    if (!@hasDecl(m, name)) @compileError("Not supported: " + @tagName(std.meta.activeTag(@typeInfo(T))));
    return @call(.auto, @field(m, name), args);
}

pub fn remove(comptime T: type, comptime name: []const u8) type {
    return method(T, "name", .{ T, name });
}

pub fn rename(comptime T: type, comptime needle: []const u8, comptime replacement: []const u8) type {
    return method(T, "rename", .{ T, needle, replacement });
}

pub fn mix(comptime Super: type, comptime Extend: type) type {
    if (std.meta.activeTag(@typeInfo(Extend)) != std.meta.activeTag(@typeInfo(Super))) @compileError("Super and Extend must be same type");
    return method(Super, "mix", .{ Super, Extend });
}
