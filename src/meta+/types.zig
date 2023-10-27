const std = @import("std");
const testing = std.testing;

pub fn tag(comptime T: type) std.meta.Tag(std.builtin.Type) {
    return std.meta.activeTag(@typeInfo(T));
}

pub fn tagOf(value: anytype) std.meta.Tag(std.builtin.Type) {
    return tag(@TypeOf(value));
}

test "tag" {
    try testing.expectEqual(tag(u8), .Int);
    try testing.expectEqual(tag(f32), .Float);
}

test "tagOf" {
    try testing.expectEqual(tagOf(@as(u8, 0)), .Int);
    try testing.expectEqual(tagOf(@as(f32, 0)), .Float);
}
