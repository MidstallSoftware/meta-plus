const std = @import("std");

pub const EmptyStructField = std.builtin.Type.StructField{
    .name = "",
    .type = undefined,
    .default_value = null,
    .is_comptime = false,
    .alignment = 0,
};

pub fn renameEnum(comptime T: type, comptime needle: []const u8, comptime replacement: []const u8) type {
    const info = @typeInfo(T).Enum;
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

pub fn rename(comptime T: type, comptime needle: []const u8, comptime replacement: []const u8) type {
    return switch (@typeInfo(T)) {
        .Enum => rename(T, needle, replacement),
        else => |f| @compileError("Not supported: " + f),
    };
}

pub fn fieldIndexByName(comptime fields: []const std.builtin.Type.StructField, name: []const u8) ?usize {
    for (fields, 0..) |field, i| {
        if (std.mem.eql(u8, field.name, name)) return i;
    }
    return null;
}

pub fn mix(comptime Super: type, comptime Extend: type) type {
    const superInfo = @typeInfo(Super).Struct;
    const extendInfo = @typeInfo(Extend).Struct;

    if (extendInfo.layout != superInfo.layout) @compileError("Super and extend struct layouts must be the same");
    if (extendInfo.backing_integer != superInfo.backing_integer) @compileError("Super and extend struct backing integers must be the same");

    var totalFields = superInfo.fields.len;

    for (extendInfo.fields) |field| {
        if (fieldIndexByName(superInfo.fields, field.name) == null) totalFields += 1;
    }

    var fields: [totalFields]std.builtin.Type.StructField = [_]std.builtin.Type.StructField{EmptyStructField} ** totalFields;

    for (superInfo.fields, 0..) |src, i| {
        fields[i] = src;
    }

    var i: usize = 0;
    for (extendInfo.fields) |src| {
        const index = fieldIndexByName(&fields, src.name) orelse blk: {
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
