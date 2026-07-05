const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 1. Create your executable step
    // 1. Create your executable step (Updated for Zig 0.16.0)
    const exe = b.addExecutable(.{
        .name = "my_game",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    // Change 'exe.linkLibC' -> 'exe.root_module.link_libc = true;' (Note: linkLibC remains on the 'exe' compilation step itself)
    exe.root_module.link_libc = true;

    // 2. Fetch the 'zsdl3' Zig source dependency and import it
    const zsdl3_dep = b.dependency("zsdl3", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zsdl3", zsdl3_dep.module("zsdl3"));

    // 3. Fetch the raw 'sdl' MinGW binary package
    const sdl_bin_dep = b.dependency("sdl", .{});

    const sdl_image_bin_dep = b.dependency("sdl_image", .{});
    const sdl_mixer_bin_dep = b.dependency("sdl_mixer", .{});

    // 4. Point Zig to the include headers inside the extracted MinGW zip
    const target_info = target.result;
    if (target_info.os.tag == .windows) {
        // Change 'exe.addIncludePath' -> 'exe.root_module.addIncludePath'
        // exe.root_module.addIncludePath(sdl_bin_dep.path("x86_64-w64-mingw32/include"));
        // Change 'exe.addLibraryPath' -> 'exe.root_module.addLibraryPath'
        // exe.root_module.addLibraryPath(sdl_bin_dep.path("x86_64-w64-mingw32/lib"));
        // exe.root_module.addLibraryPath(sdl_bin_dep.path("x86_64-w64-mingw32/bin"));

        // exe.root_module.addIncludePath(sdl_image_bin_dep.path("x86_64-w64-mingw32/include"));
        // exe.root_module.addLibraryPath(sdl_image_bin_dep.path("x86_64-w64-mingw32/lib"));
        // exe.root_module.addLibraryPath(sdl_image_bin_dep.path("x86_64-w64-mingw32/bin"));

        // VC dlevel
        exe.root_module.addIncludePath(sdl_bin_dep.path("include"));
        exe.root_module.addLibraryPath(sdl_bin_dep.path("lib/x64"));

        exe.root_module.addIncludePath(sdl_image_bin_dep.path("include"));
        exe.root_module.addLibraryPath(sdl_image_bin_dep.path("lib/x64"));

        exe.root_module.addIncludePath(sdl_mixer_bin_dep.path("include"));
        exe.root_module.addLibraryPath(sdl_mixer_bin_dep.path("lib/x64"));
    }

    // 5. Link the system library dynamically or statically
    // Change 'exe.linkSystemLibrary' -> 'exe.root_module.linkSystemLibrary'
    exe.root_module.linkSystemLibrary("SDL3", .{}); // Note: Zig 0.16.0 requires a configuration struct argument, pass .{}



    // 6. Copy the SDL3.dll to your output directory so the game runs on double-click
    if (target_info.os.tag == .windows) {
        const wf = b.addUpdateSourceFiles();
        // wf.addCopyFileToSource(
        //     sdl_bin_dep.path("x86_64-w64-mingw32/bin/SDL3.dll"),
        //     "SDL3.dll",
        // );

        // wf.addCopyFileToSource(
        //     sdl_image_bin_dep.path("x86_64-w64-mingw32/bin/SDL3_image.dll"),
        //     "SDL3_image.dll",
        // );
        wf.addCopyFileToSource(
            sdl_bin_dep.path("lib/x64/SDL3.dll"),
            "SDL3.dll",
        );

        wf.addCopyFileToSource(
            sdl_image_bin_dep.path("lib/x64/SDL3_image.dll"),
            "SDL3_image.dll",
        );

        wf.addCopyFileToSource(
            sdl_mixer_bin_dep.path("lib/x64/SDL3_mixer.dll"),
            "SDL3_mixer.dll",
        );
        exe.step.dependOn(&wf.step);
    }

    // Standard installer boilerplate
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
