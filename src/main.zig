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
    cursorVelocity: ray.Vector2 = ray.Vector2{ .x = 0, .y = 0 },
};

pub fn main() !void {
    const screenWidth = 1920;
    const screenHeight = 1080;

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
    var previousMousePos: ray.Vector2 = .{ .x = 0, .y = 0 };

    var game: Game = .{};

    while (!ray.WindowShouldClose()) {
        const delta = ray.GetFrameTime();

        const currentMousePos = ray.WGetScreenToWorld2D(GetMousePosition(), camera);
        const mousePos: ray.Vector2 = .{
            .x = currentMousePos.x - previousMousePos.x,
            .y = currentMousePos.y - previousMousePos.y,
        };
        previousMousePos = currentMousePos;

        game.cursor.x += std.math.clamp(mousePos.x, -10_000 * delta, 10_000 * delta);
        game.cursor.y += std.math.clamp(mousePos.y, -10_000 * delta, 10_000 * delta);

        game.cursorVelocity.y += 1 * delta;
        game.cursor.x += game.cursorVelocity.x;
        game.cursor.y += game.cursorVelocity.y;
        if (game.cursor.y > 500) {
            game.cursor.y = 500;
            game.cursorVelocity.y = 0;
        }

        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(hex(0x222034));

        ray.BeginMode2D(camera);
        defer ray.EndMode2D();

        ray.WDrawTextureV(mouse, game.cursor, hex(0xFFFFFF));
    }
}
