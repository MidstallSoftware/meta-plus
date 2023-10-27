const std = @import("std");
const testing = std.testing;

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

test "fromDecls using a struct" {
    const decls = struct {
        pub const a = 1;
        pub const b = 2;
        pub const c = 3;
    };

    const value = fromDecls(decls);

    const expected = enum(u8) {
        a = 0,
        b = 1,
        c = 2,
    };

    try testing.expectEqual(@typeInfo(value).Enum.fields.len, @typeInfo(expected).Enum.fields.len);

    inline for (@typeInfo(value).Enum.fields, @typeInfo(expected).Enum.fields) |a, b| {
        try testing.expectEqualStrings(a.name, b.name);
        try testing.expectEqual(a.value, b.value);
    }
}
