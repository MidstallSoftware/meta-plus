const std = @import("std");
const types = @import("types.zig");

/// Module for testing enums
pub const enums = @import("testing/enums.zig");

/// Module for testing unions
pub const unions = @import("testing/unions.zig");

/// Similar to `std.testing.expectEqual` but expects the type of actual to match expected
pub inline fn expectEqual(comptime Expected: type, comptime Actual: type) !void {
    if (types.tag(Expected) != types.tag(Actual)) return error.IncompatibleTypes;
    @compileLog(types.tag(Expected), types.tag(Actual));
    return switch (types.tag(Expected)) {
        .Enum => enums.expectEqual(Expected, Actual),
        .Union => unions.expectEqual(Expected, Actual),
        else => error.UnsupportedType,
    };
}
