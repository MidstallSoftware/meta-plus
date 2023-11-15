const std = @import("std");
const testing = std.testing;
const metaTesting = @import("testing.zig").unions;
const enums = @import("enums.zig");

/// Generates a union from the declarations of a type
pub fn fromDecls(comptime T: type) type {
    comptime {
        const decls = std.meta.declarations(T);
        var fieldsList: [decls.len]std.builtin.Type.UnionField = undefined;

        for (decls, 0..) |decl, i| {
            const f = @field(T, decl.name);
            fieldsList[i] = .{
                .name = decl.name,
                .type = if (@typeInfo(@TypeOf(f)) == .Type) f else @TypeOf(f),
                .alignment = i,
            };
        }

        return @Type(.{
            .Union = .{
                .layout = .Auto,
                .tag_type = null,
                .fields = &fieldsList,
                .decls = &.{},
            },
        });
    }
}

/// Sets the tag type of a union
pub fn useTag(comptime T: type, comptime V: ?type) type {
    comptime {
        var info = @typeInfo(T).Union;
        info.tag_type = V;
        return @Type(.{
            .Union = info,
        });
    }
}

test "fromDecls using a struct" {
    const decls = struct {
        pub const a: u8 = 1;
        pub const b: u32 = 2;
        pub const c: u16 = 3;
    };

    const expected = union {
        a: u8,
        b: u32,
        c: u16,
    };

    try metaTesting.expectEqual(fromDecls(decls), expected);
}

test "useTag with fromDecls on a struct" {
    const decls = struct {
        pub const a: u8 = 1;
        pub const b: u32 = 2;
        pub const c: u16 = 3;
    };

    const tag = enums.fromDecls(decls);

    const expected = union(tag) {
        a: u8,
        b: u32,
        c: u16,
    };

    try metaTesting.expectEqual(useTag(fromDecls(decls), tag), expected);
}
