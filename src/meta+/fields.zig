const std = @import("std");

pub fn rename(comptime T: type, comptime needle: []const u8, comptime replacement: []const u8) type {
    return switch (@typeInfo(T)) {
        .Enum => @import("enums/fields.zig").rename(T, needle, replacement),
        .Struct => @import("structs/fields.zig").rename(T, needle, replacement),
        else => |f| @compileError("Not supported: " + f),
    };
}

pub fn mix(comptime Super: type, comptime Extend: type) type {
    if (std.meta.activeTag(@typeInfo(Extend)) != std.meta.activeTag(@typeInfo(Super))) @compileError("Super and Extend must be same type");
    return switch (@typeInfo(Super)) {
        .Struct => @import("structs/fields.zig").mix(Super, Extend),
        else => |f| @compileError("Not supported: " + f),
    };
}
