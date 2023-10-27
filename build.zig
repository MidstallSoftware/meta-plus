const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vizops = b.addModule("meta+", .{
        .source_file = .{ .path = b.pathFromRoot("src/meta+.zig") },
    });

    const exe_example = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{
            .path = b.pathFromRoot("src/example.zig"),
        },
        .target = target,
        .optimize = optimize,
    });

    exe_example.addModule("meta+", vizops);
    b.installArtifact(exe_example);
}
