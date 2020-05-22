const std = @import("std");
const ray = @import("workaround.zig");

pub extern fn GetMousePosition() ray.Vector2;

pub fn hex(comptime color: u24) ray.Color {
    return ray.Color{
        .r = (color >> 16),
        .g = (color >> 8) & 0xFF,
        .b = color & 0xFF,
        .a = 0xFF,
    };
}

const Game = struct {
    cursor: ray.Vector2 = ray.Vector2{ .x = 200, .y = 100 },
};

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 400;

    ray.InitWindow(screenWidth, screenHeight, "window");
    defer ray.CloseWindow();
    ray.SetExitKey(0);

    ray.SetTargetFPS(240);

    ray.DisableCursor();

    const mouse = ray.LoadTexture("src/mouse.png");
    defer ray.UnloadTexture(mouse);
    var camera: ray.Camera2D = std.mem.zeroes(ray.Camera2D);
    camera.target = .{ .x = 0, .y = 0 };
    camera.offset = .{ .x = 0, .y = 0 };
    camera.rotation = 0;
    camera.zoom = 2;

    const game: Game = .{};

    while (!ray.WindowShouldClose()) {
        const delta = ray.GetFrameTime();

        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(hex(0x222034));

        ray.BeginMode2D(camera);
        defer ray.EndMode2D();

        ray.WDrawTextureV(mouse, game.cursor, hex(0xFFFFFF));

        const mousePos = ray.WGetScreenToWorld2D(GetMousePosition(), camera);
        std.debug.warn("mpos: {}\n", .{mousePos});
    }
}
