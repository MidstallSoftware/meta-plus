const std = @import("std");

pub fn tag(comptime T: type) std.meta.Tag(std.builtin.Type) {
    return std.meta.activeTag(@typeInfo(T));
}

pub fn tagOf(value: anytype) std.meta.Tag(std.builtin.Type) {
    return tag(@TypeOf(value));
}
