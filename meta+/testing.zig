const std = @import("std");
const types = @import("types.zig");

/// Module for testing enums
pub const enums = @import("testing/enums.zig");

/// Similar to `std.testing.expectEqual` but expects the type of actual to match expected
pub inline fn expectEqual(comptime Expected: type, comptime Actual: type) !void {
    if (types.tag(Expected) != types.tag(Actual)) return error.IncompatibleTypes;
    return switch (types.tag(Expected)) {
        .Enum => enums.expectEqual(Expected, Actual),
        else => error.UnsupportedType,
    };
}
