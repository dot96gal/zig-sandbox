const std = @import("std");

const test_targets = [_]std.Target.Query{
    .{}, // native
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

pub fn build(b: *std.Build) void {
    // build
    const exe = b.addExecutable(.{
        .name = "call-go",
        .root_source_file = b.path("src-zig/main.zig"),
        .target = b.graph.host,
    });
    exe.addIncludePath(.{ .cwd_relative = "./build" });
    exe.addLibraryPath(.{ .cwd_relative = "./build" });
    exe.linkSystemLibrary("calc");
    b.installArtifact(exe);

    // run
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);

    if (b.args) |args| {
        run_exe.addArgs(args);
    }

    // test
    const test_step = b.step("test", "Run unit tests");
    for (test_targets) |target| {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("src-zig/main.zig"),
            .target = b.resolveTargetQuery(target),
        });
        unit_tests.addIncludePath(.{
            .cwd_relative = "./build",
        });
        unit_tests.addLibraryPath(.{ .cwd_relative = "./build" });
        unit_tests.linkSystemLibrary("calc");

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_unit_tests.step);
    }
}
