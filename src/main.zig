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
    rightWall: f32 = 500,
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

        game.cursorVelocity.y += 5;
        game.cursor.x += game.cursorVelocity.x * delta;
        game.cursor.y += game.cursorVelocity.y * delta;
        if (game.cursor.y < 0) {
            game.cursor.y = 0;
            game.cursorVelocity.y = std.math.max(game.cursorVelocity.y, 0);
        }
        if (game.cursor.y > 500) {
            game.cursor.y = 500;
            game.cursorVelocity.y = 0;
            game.cursorVelocity.y = std.math.min(game.cursorVelocity.y, 0);
        }
        if (game.cursor.x < 0) {
            game.cursor.x = 0;
            game.cursorVelocity.x = std.math.max(game.cursorVelocity.x, 0);
        }
        if (game.cursor.x > game.rightWall) {
            const diff = game.cursor.x - game.rightWall;
            game.rightWall += diff;
        }
        const rwOffset = game.rightWall - 500;
        game.rightWall -= rwOffset * 5 * delta;
        if (game.cursor.x > game.rightWall) {
            game.cursor.x = game.rightWall;
        }

        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(hex(0x222034));

        ray.BeginMode2D(camera);
        defer ray.EndMode2D();

        ray.DrawRectangle(@floatToInt(c_int, game.rightWall), 0, 500, 500, hex(0x660000));
        ray.DrawRectangle(0, 500, 1000, 500, hex(0x000066));
        ray.WDrawTextureV(mouse, .{ .x = game.cursor.x - 1, .y = game.cursor.y - 2 }, hex(0xFFFFFF));
    }
}
