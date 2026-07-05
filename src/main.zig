const std = @import("std");
const zsdl = @import("zsdl3");

pub fn main() !void {
    // 1. Initialize the wrapper bindings
    std.debug.print("Initializing SDL3...\n", .{});

    // Pass .{} for default initialization systems (video, audio, etc.)
    if (!zsdl.init(zsdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL Initialization failed!\n", .{});
        return error.SDLInitializationFailed;
    }
    // Clean up when the main function exits
    defer zsdl.quit();

    std.debug.print("SDL3 successfully initialized!\n", .{});

    // 2. Fetch the compiled version from the linked C binaries
    // const version = zsdl.getVersion();
    // std.debug.print("Successfully linked with SDL version: {d}.{d}.{d}\n", .{
    //     zsdl.versionMajor(version),
    //     zsdl.versionMinor(version),
    //     zsdl.versionMicro(version),
    // });

    // 3. Simple window creation test
    std.debug.print("Creating test window...\n", .{});
    const window = zsdl.createWindow("Zig + SDL3 Test", 800, 600, zsdl.SDL_WINDOW_RESIZABLE) orelse {
        std.debug.print("Failed to create window!\n", .{});
        return error.WindowCreationFailed;
    };
    defer zsdl.destroyWindow(window);

    const renderer = zsdl.createRenderer(window, null) orelse return;
    defer zsdl.destroyRenderer(renderer);

    while (true) {
        var event: zsdl.SDL_Event = undefined;
        while (zsdl.pollEvent(&event)) if (event.type == zsdl.SDL_EVENT_QUIT) return;
        _ = zsdl.setRenderDrawColor(renderer, 30, 60, 90, 255);
        _ = zsdl.renderClear(renderer);
        _ = zsdl.renderPresent(renderer);
        zsdl.delay(16);
    }
    // Keep it open for 2 seconds to make sure it functions before closing
    // std.debug.print("Window visible! Waiting 2 seconds...\n", .{});
    // zsdl.delay(2000);

    std.debug.print("Test completed successfully!\n", .{});
}
