const std = @import("std");
const types = @import("../types.zig");

/// Generates a tuple type out of the parameters of a function type
pub fn tuple(comptime T: type) type {
    const info = types.ensure(T, .Fn) orelse @panic("Type is not a function");

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
                .alignment = if (@sizeOf(t) > 0) @alignOf(t) else 0,
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
