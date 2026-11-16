const std = @import("std");

pub fn build(b: *std.Build) void {
    const zine_dep = b.dependency("zine", .{
        .optimize = .ReleaseFast,
        // Zine reads its version from `git describe`, which fails because the
        // package sits inside this repo. Keep this in sync with build.zig.zon.
        .version = @as([]const u8, "0.14.1"),
    });
    const zine_exe = zine_dep.artifact("zine");

    // `zig build` installs the binary to zig-out/bin/zine.
    b.installArtifact(zine_exe);
}
