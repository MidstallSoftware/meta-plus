const std = @import("std");

pub const fields = @import("enums/fields.zig");

pub fn fromDecls(comptime T: type) type {
    comptime {
        const decls = std.meta.declarations(T);
        var fieldsList: [decls.len]std.builtin.Type.EnumField = undefined;

        for (decls, 0..) |decl, i| {
            fieldsList[i] = .{
                .name = decl.name,
                .value = i,
            };
        }

        return @Type(.{
            .Enum = .{
                .tag_type = u8,
                .fields = &fieldsList,
                .decls = &.{},
                .is_exhaustive = true,
            },
        });
    }
}
