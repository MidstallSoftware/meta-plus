const std = @import("std");

pub fn fromDecls(comptime T: type) type {
    comptime {
        const decls = std.meta.declarations(T);
        var fields: [decls.len]std.builtin.Type.EnumField = undefined;

        for (decls, 0..) |decl, i| {
            fields[i] = .{
                .name = decl.name,
                .value = i,
            };
        }

        return @Type(.{
            .Enum = .{
                .tag_type = u8,
                .fields = &fields,
                .decls = &.{},
                .is_exhaustive = true,
            },
        });
    }
}
