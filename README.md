# Meta+

## Introduction

### What is Meta+?

Meta+ is an extension to Zig's `std.meta` module. It provides many comptime based functions
for defining and manipulating types from other types. This has the advantage of smarter code
and typing in Zig. It also provides functions for `std.testing` which allow for testing how
Zig sees the types you write. This can be helpful for debugging more complex types.

### Features

- [x] VTable generation from declarations
- [x] Enum generation from declarations and fields
- [ ] Type checking at comptime and testing
- [ ] Complete type field manipulation (mixing, removal, adding, etc.)
- [ ] Complete function parameter manipulation
- [ ] Enhanced type printing
