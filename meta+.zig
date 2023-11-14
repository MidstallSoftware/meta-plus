//!zig-autodoc-guide: README.md

const stdTesting = @import("std").testing;

/// Module for enum types
pub const enums = @import("meta+/enums.zig");

/// Module for fields
pub const fields = @import("meta+/fields.zig");

/// Module for function types
pub const functions = @import("meta+/functions.zig");

/// Module for structure types
pub const structs = @import("meta+/structs.zig");

/// Module for testing
pub const testing = @import("meta+/testing.zig");

/// Module for types
pub const types = @import("meta+/types.zig");

/// Module for unions
pub const unions = @import("meta+/unions.zig");

test {
    stdTesting.refAllDecls(@This());
}
