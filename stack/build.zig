const std = @import("std");

const test_targets = [_]std.Target.Query{
    .{}, // native
    .{
        .cpu_arch = .x86_64,
        .os_tag = .linux,
    },
    .{
        .cpu_arch = .aarch64,
        .os_tag = .macos,
    },
};

pub fn build(b: *std.Build) void {
    // build
    const exe = b.addExecutable(.{
        .name = "stack",
        .root_source_file = b.path("main.zig"),
        .target = b.graph.host,
    });
    b.installArtifact(exe);

    // run
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);

    // test
    const test_step = b.step("test", "Run unit tests");
    for (test_targets) |target| {
        const unit_tests = b.addTest(.{
            .root_source_file = b.path("main.zig"),
            .target = b.resolveTargetQuery(target),
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        run_unit_tests.skip_foreign_checks = true;
        test_step.dependOn(&run_unit_tests.step);
    }
}
