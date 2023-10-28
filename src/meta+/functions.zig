pub const params = @import("functions/params.zig");

pub fn returnOf(comptime T: type) type {
    return @typeInfo(T).Fn.return_type orelse @TypeOf(null);
}
