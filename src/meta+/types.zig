const std = @import("std");
const testing = std.testing;

pub inline fn tag(comptime T: type) std.meta.Tag(std.builtin.Type) {
    return std.meta.activeTag(@typeInfo(T));
}

pub inline fn tagOf(value: anytype) std.meta.Tag(std.builtin.Type) {
    return tag(@TypeOf(value));
}

pub inline fn ensure(comptime T: type, comptime kind: std.builtin.TypeId) ?std.meta.TagPayload(std.builtin.Type, kind) {
    return if (@typeInfo(T) == kind) @field(@typeInfo(T), @tagName(kind)) else null;
}

pub inline fn fields(comptime T: type) ?[]const @field(std.builtin.Type, @tagName(tag(T)) ++ "Field") {
    return if (ensure(T, tag(T))) |info| (if (@hasField(@TypeOf(info), "fields")) @field(info, "fields") else null) else null;
}

test "tag" {
    try testing.expectEqual(tag(u8), .Int);
    try testing.expectEqual(tag(f32), .Float);
}

test "tagOf" {
    try testing.expectEqual(tagOf(@as(u8, 0)), .Int);
    try testing.expectEqual(tagOf(@as(f32, 0)), .Float);
}

test "ensure type is what is wanted" {
    try testing.expect(ensure(struct {}, .Struct) != null);
    try testing.expect(ensure(u8, .Int) != null);
    try testing.expect(ensure(f32, .Float) != null);
    try testing.expect(ensure(void, .Float) == null);
}
