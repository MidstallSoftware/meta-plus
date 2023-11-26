const std = @import("std");
const metaTesting = @import("../testing.zig").enums;
const types = @import("../types.zig");

/// Constant which represents an empty enum field
pub const Empty = std.builtin.Type.EnumField{
    .name = "",
    .value = 0,
};

/// Renames the fields in type which has needle with replacement
pub fn rename(comptime T: type, comptime needle: []const u8, comptime replacement: []const u8) type {
    const info = types.ensure(T, .Enum) orelse @panic("Type must be an enum");
    var fields: [info.fields.len]std.builtin.Type.EnumField = undefined;

    for (info.fields, &fields) |src, *dst| {
        var name: [src.name.len]u8 = undefined;
        _ = std.mem.replace(u8, src.name, needle, replacement, &name);
        dst.* = .{
            .name = &name,
            .value = src.value,
        };
    }

    return @Type(.{
        .Enum = .{
            .tag_type = info.tag_type,
            .fields = &fields,
            .decls = info.decls,
            .is_exhaustive = info.is_exhaustive,
        },
    });
}

/// Returns the index of the field by name which is in an array of enum fields.
/// If the field cannot be found, returns null.
pub fn indexByName(comptime fields: []const std.builtin.Type.EnumField, name: []const u8) ?usize {
    for (fields, 0..) |field, i| {
        if (std.mem.eql(u8, field.name, name)) return i;
    }
    return null;
}

/// Mixes the fields from two enums
pub fn mix(comptime Super: type, comptime Extend: type) type {
    const superInfo = types.ensure(Super, .Enum) orelse @panic("Super type must be a enum");
    const extendInfo = types.ensure(Extend, .Enum) orelse @panic("Extend type must be a enum");

    if (extendInfo.is_exhaustive != superInfo.is_exhaustive) @compileError("Super and extend enums tag types must both be exhaustive or not");

    if (extendInfo.tag_type == u0 and extendInfo.fields.len == 0) return Super;
    if (superInfo.tag_type == u0 and superInfo.fields.len == 0) return Extend;

    var totalFields = superInfo.fields.len;

    for (extendInfo.fields) |field| {
        if (indexByName(superInfo.fields, field.name) == null) totalFields += 1;
    }

    var fields: [totalFields]std.builtin.Type.EnumField = [_]std.builtin.Type.EnumField{Empty} ** totalFields;

    for (superInfo.fields, 0..) |src, i| {
        fields[i] = src;
    }

    var i: usize = 0;
    for (extendInfo.fields) |src| {
        const index = indexByName(&fields, src.name) orelse blk: {
            i += 1;
            break :blk (i + superInfo.fields.len - 1);
        };

        fields[index] = src;
        // TODO: we should have a better way of doing this.
        fields[index].value += superInfo.fields.len;
    }

    return @Type(.{
        .Enum = .{
            .tag_type = std.math.IntFittingRange(0, fields.len - 1),
            .fields = &fields,
            .decls = &.{},
            .is_exhaustive = superInfo.is_exhaustive,
        },
    });
}

test "Mixing enums" {
    const A = enum { a, b, c };
    const B = enum { x, y, z };
    const expected = enum { a, b, c, x, y, z };

    try metaTesting.expectEqual(mix(A, B), expected);
}
