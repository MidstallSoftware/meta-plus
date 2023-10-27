const std = @import("std");

pub const Empty = std.builtin.Type.StructField{
    .name = "",
    .type = undefined,
    .default_value = null,
    .is_comptime = false,
    .alignment = 0,
};

pub fn indexByName(comptime fields: []const std.builtin.Type.StructField, name: []const u8) ?usize {
    for (fields, 0..) |field, i| {
        if (std.mem.eql(u8, field.name, name)) return i;
    }
    return null;
}

pub fn mix(comptime Super: type, comptime Extend: type) type {
    if (std.meta.activeTag(@typeInfo(Extend)) != std.meta.activeTag(@typeInfo(Super))) @compileError("Super and Extend must be same type");
    if (std.meta.activeTag(@typeInfo(Super)) != .Struct) @compileError("Types must be structs");

    const superInfo = @typeInfo(Super).Struct;
    const extendInfo = @typeInfo(Extend).Struct;

    if (extendInfo.layout != superInfo.layout) @compileError("Super and extend struct layouts must be the same");
    if (extendInfo.backing_integer != superInfo.backing_integer) @compileError("Super and extend struct backing integers must be the same");

    var totalFields = superInfo.fields.len;

    for (extendInfo.fields) |field| {
        if (indexByName(superInfo.fields, field.name) == null) totalFields += 1;
    }

    var fields: [totalFields]std.builtin.Type.StructField = [_]std.builtin.Type.StructField{Empty} ** totalFields;

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
    }

    return @Type(.{
        .Struct = .{
            .layout = superInfo.layout,
            .backing_integer = superInfo.backing_integer,
            .fields = &fields,
            .decls = &.{},
            .is_tuple = false,
        },
    });
}
