const std = @import("std");
const metaplus = @import("meta+");

fn printDecl(comptime T: type) void {
    inline for (@typeInfo(T).Struct.decls) |decl| {
        const field = @field(T, decl.name);
        const fieldInfo = @typeInfo(@TypeOf(field));

        switch (fieldInfo) {
            .Fn => std.debug.print("{s}\n", .{decl.name}),
            .Struct => {
                std.debug.print("{}\n", .{field});
                printDecl(field);
            },
            else => std.debug.print("{}\n", .{field}),
        }
    }
}

const VTable = metaplus.structs.vTable(struct {
    pub fn print(_: @This()) void {}
});

const Mixed = metaplus.fields.mix(struct {
    a: u8 = 0,
}, struct {
    b: u16 = 1,
});

pub fn main() void {
    printDecl(metaplus);

    std.debug.print("{}\n", .{VTable});
    std.debug.print("{}\n{}\n", .{ Mixed{}, metaplus.fields.rename(Mixed, "a", "x"){} });
}
