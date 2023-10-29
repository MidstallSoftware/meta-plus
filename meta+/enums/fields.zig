const std = @import("std");
const types = @import("../types.zig");

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
