const std = @import("std");
const testing = std.testing;
const metaTesting = @import("testing.zig").enums;
const types = @import("types.zig");

pub const fields = @import("enums/fields.zig");

/// Generates an enum from the fields of a type
pub fn fromFields(comptime T: type) type {
    comptime {
        const f = types.fields(T) orelse @compileError("Incompatible type: " ++ @tagName(types.tag(T)));
        var fieldsList: [f.len]std.builtin.Type.EnumField = undefined;

        for (f, 0..) |field, i| {
            fieldsList[i] = .{
                .name = field.name,
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

/// Generates an enum from the declarations of a type
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

test "fromFields using a struct" {
    const decls = struct {
        a: u8,
        b: u8,
        c: u8,
    };

    const expected = enum(u8) {
        a = 0,
        b = 1,
        c = 2,
    };

    try metaTesting.expectEqual(fromFields(decls), expected);
}

test "fromDecls using a struct" {
    const decls = struct {
        pub const a = 1;
        pub const b = 2;
        pub const c = 3;
    };

    const expected = enum(u8) {
        a = 0,
        b = 1,
        c = 2,
    };

    try metaTesting.expectEqual(fromDecls(decls), expected);
}
