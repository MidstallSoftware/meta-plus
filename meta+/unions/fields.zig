const std = @import("std");

pub fn remove(comptime T: type, comptime name: []const u8) type {
    if (std.meta.activeTag(@typeInfo(T)) != .Union) @compileError("Type must be a union");

    const info = @typeInfo(T).Union;
    var count: usize = 0;

    inline for (info.fields) |field| {
        if (!std.mem.eql(u8, field.name, name)) count += 1;
    }

    var fields: [count]std.builtin.Type.UnionField = undefined;
    var i: usize = 0;

    inline for (info.fields) |field| {
        if (!std.mem.eql(u8, field.name, name)) {
            fields[i] = field;
            i += 1;
        }
    }

    return @Type(.{
        .Union = .{
            .layout = info.layout,
            .tag_type = info.tag_type,
            .fields = &fields,
            .decls = &.{},
        },
    });
}
