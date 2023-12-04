const std = @import("std");
const functions = @import("functions.zig");

const types = struct {
    /// Fields type module for enums
    pub const enums = @import("enums/fields.zig");

    /// Fields type module for structs
    pub const structs = @import("structs/fields.zig");

    /// Field type module for unions
    pub const unions = @import("unions/fields.zig");
};

pub usingnamespace types;

/// Returns the fields type module for the type specified
pub fn of(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .Enum => types.enums,
        .Struct => types.structs,
        .Union => types.unions,
        else => |f| @compileError("Not supported: " + @tagName(f)),
    };
}

/// Calls a method from a type
pub fn method(comptime T: type, comptime name: []const u8, args: functions.params.tuple(@TypeOf(@field(of(T), name)))) functions.returnOf(@TypeOf(@field(of(T), name))) {
    const m = of(T);
    if (!@hasDecl(m, name)) @compileError("Not supported: " + @tagName(std.meta.activeTag(@typeInfo(T))));
    return @call(.auto, @field(m, name), args);
}

/// Removes the field which matches name
pub fn remove(comptime T: type, comptime name: []const u8) type {
    return method(T, "remove", .{ T, name });
}

/// Renames the field which matches name
pub fn rename(comptime T: type, comptime needle: []const u8, comptime replacement: []const u8) type {
    return method(T, "rename", .{ T, needle, replacement });
}

/// Mixes fields from extend into super
pub fn mix(comptime Super: type, comptime Extend: type) type {
    if (std.meta.activeTag(@typeInfo(Extend)) != std.meta.activeTag(@typeInfo(Super))) @compileError("Super and Extend must be same type");
    return method(Super, "mix", .{ Super, Extend });
}
