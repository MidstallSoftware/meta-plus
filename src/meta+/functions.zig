/// Function parameters module
pub const params = @import("functions/params.zig");

/// Returns the type of return value a function type produces
pub fn returnOf(comptime T: type) type {
    return @typeInfo(T).Fn.return_type orelse @TypeOf(null);
}
