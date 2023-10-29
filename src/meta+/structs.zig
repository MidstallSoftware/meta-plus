const std = @import("std");

pub const fields = @import("structs/fields.zig");

/// Generates a virtual vtable type from the declarations of a type
pub fn vTable(comptime T: type) type {
    comptime {
        const decls = std.meta.declarations(T);

        var count: usize = 0;
        for (decls) |decl| {
            const func = @field(T, decl.name);
            const info = @typeInfo(@TypeOf(func));
            if (std.meta.activeTag(info) == .Fn) count += 1;

            const funcInfo = info.Fn;
            if (funcInfo.params.len < 1) continue;
        }

        var fieldsList: [count]std.builtin.Type.StructField = undefined;

        var i: usize = 0;
        for (decls) |decl| {
            const func = @field(T, decl.name);
            const info = @typeInfo(@TypeOf(func));
            if (std.meta.activeTag(info) != .Fn) continue;

            const funcInfo = info.Fn;
            if (funcInfo.params.len < 1) continue;
            var params: [funcInfo.params.len]std.builtin.Type.Fn.Param = undefined;

            for (funcInfo.params, &params) |param, *p| {
                p.* = .{
                    .is_generic = param.is_generic,
                    .is_noalias = param.is_noalias,
                    .type = if (param.type == *T) *anyopaque else if (param.type == *const T) *const anyopaque else param.type,
                };
            }

            fieldsList[i] = .{
                .name = decl.name,
                .type = @Type(.{
                    .Pointer = .{
                        .size = .One,
                        .is_const = true,
                        .is_volatile = false,
                        .alignment = 0,
                        .address_space = .generic,
                        .child = @Type(.{
                            .Fn = .{
                                .calling_convention = .Unspecified,
                                .alignment = funcInfo.alignment,
                                .is_generic = funcInfo.is_generic,
                                .is_var_args = funcInfo.is_var_args,
                                .return_type = funcInfo.return_type,
                                .params = &params,
                            },
                        }),
                        .is_allowzero = false,
                        .sentinel = null,
                    },
                }),
                .default_value = null,
                .is_comptime = false,
                .alignment = 0,
            };

            i += 1;
        }

        return @Type(.{
            .Struct = .{
                .layout = .Auto,
                .fields = &fieldsList,
                .decls = &.{},
                .is_tuple = false,
            },
        });
    }
}
