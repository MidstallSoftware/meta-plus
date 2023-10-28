const std = @import("std");

pub fn tuple(comptime T: type) type {
    if (std.meta.activeTag(@typeInfo(T)) != .Fn) @compileError("Type is not a function");

    const info = @typeInfo(T).Fn;

    var count: usize = 0;
    for (info.params) |param| {
        if (param.type) |_| count += 1;
    }

    var fields: [info.params.len]std.builtin.Type.StructField = undefined;

    var i: usize = 0;
    for (info.params) |param| {
        if (param.type) |t| {
            fields[i] = .{
                .name = std.fmt.comptimePrint("{}", .{i}),
                .type = t,
                .default_value = null,
                .is_comptime = false,
                .alignment = i,
            };
            i += 1;
        }
    }

    return @Type(.{
        .Struct = .{
            .layout = .Auto,
            .fields = &fields,
            .decls = &.{},
            .is_tuple = true,
        },
    });
}
