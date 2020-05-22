const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("mousegame", "src/main.zig");

    exe.linkLibC();
    exe.linkSystemLibrary("raylib");
    exe.addCSourceFile("lib/raylib-zig/lib/workaround.c", &[_][]const u8{});
    exe.addPackagePath("raylib", "lib/raylib-zig/lib/raylib-zig.zig");
    exe.addPackagePath("raylib-math", "lib/raylib-zig/lib/raylib-zig-math.zig");

    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
