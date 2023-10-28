const std = @import("std");
const types = @import("types.zig");

pub const enums = @import("testing/enums.zig");

pub fn expectEqual(comptime Expected: type, comptime Actual: type) !void {
    if (types.tag(Expected) != types.tag(Actual)) return error.IncompatibleTypes;
    return switch (types.tag(Expected)) {
        .Enum => enums.expectEqual(Expected, Actual),
        else => error.UnsupportedType,
    };
}
