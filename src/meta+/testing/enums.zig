const std = @import("std");
const testing = std.testing;
const types = @import("../types.zig");

pub fn expectEqual(comptime Expected: type, comptime Actual: type) !void {
    if (types.tag(Expected) != types.tag(Actual) or types.tag(Expected) != .Enum) return error.InvalidType;

    const expectedInfo = @typeInfo(Expected).Enum;
    const actualInfo = @typeInfo(Actual).Enum;

    try testing.expectEqual(expectedInfo.tag_type, actualInfo.tag_type);
    try testing.expectEqual(expectedInfo.fields.len, actualInfo.fields.len);
    try testing.expectEqual(expectedInfo.decls.len, actualInfo.decls.len);
    try testing.expectEqual(expectedInfo.is_exhaustive, actualInfo.is_exhaustive);

    inline for (expectedInfo.fields, actualInfo.fields) |a, b| {
        try testing.expectEqualStrings(a.name, b.name);
        try testing.expectEqual(a.value, b.value);
    }
}
