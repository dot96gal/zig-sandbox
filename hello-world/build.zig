const std = @import("std");

pub fn build(b: *std.Build) void {
    // build
    const exe = b.addExecutable(.{
        .name = "hello-world",
        .root_source_file = b.path("main.zig"),
        .target = b.host,
    });
    b.installArtifact(exe);

    // run
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
