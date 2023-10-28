const std = @import("std");
const testing = std.testing;

pub fn tag(comptime T: type) std.meta.Tag(std.builtin.Type) {
    return std.meta.activeTag(@typeInfo(T));
}

pub fn tagOf(value: anytype) std.meta.Tag(std.builtin.Type) {
    return tag(@TypeOf(value));
}

pub fn ensure(comptime T: type, comptime kind: std.meta.Tag(std.builtin.Type)) ?std.meta.TagPayloadByName(std.builtin.Type, @tagName(kind)) {
    if (std.meta.activeTag(@typeInfo(T)) == kind) {
        return @field(@typeInfo(T), @tagName(kind));
    }
    return null;
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
}
