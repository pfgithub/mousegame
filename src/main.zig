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
    rightWallTarget: f32 = 500,
    cube: ray.Rectangle = ray.Rectangle{ .x = 240, .y = 240, .width = 60, .height = 60 },

    fn moveCursor(game: *Game, x: f32, y: f32) void {
        // I want this to eg support slopes. it will check line collision
        // to see if moving the cursor hit any lines, and then handle slopes
        // somehow? like if --- hits /, it will end up going /
        // we're already doing that for horizontal and vertical slopes, but
        // that is easy
        // var resX: f32 = x;
        // var resY: f32 = y;
        game.cursor.x += x;
        game.cursor.y += y;

        if (game.cursor.y < 0) {
            game.cursor.y = 0;
            game.cursorVelocity.y = std.math.max(game.cursorVelocity.y, 0);
        }
        if (game.cursor.y > game.rightWallTarget) {
            game.cursor.y = game.rightWallTarget;
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
            game.cursor.x -= diff / 2;
        }
    }
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

        game.cursorVelocity.y += 5;
        const rwOffset = game.rightWall - game.rightWallTarget;
        game.rightWall -= rwOffset * 5 * delta;

        game.moveCursor(
            std.math.clamp(mousePos.x, -10_000 * delta, 10_000 * delta),
            std.math.clamp(mousePos.y, -10_000 * delta, 10_000 * delta),
        );

        game.moveCursor(
            game.cursorVelocity.x * delta,
            game.cursorVelocity.y * delta,
        );

        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(hex(0x222034));

        ray.BeginMode2D(camera);
        defer ray.EndMode2D();

        ray.WDrawRectangleRec(.{ .x = game.rightWall, .y = 0, .width = 500, .height = 500 }, hex(0x660000));
        ray.WDrawRectangleRec(game.cube, hex(0x000066));
        ray.WDrawRectangleRec(.{ .x = 0, .y = 500, .width = 1000, .height = 500 }, hex(0x000066));
        ray.WDrawTextureV(mouse, .{ .x = game.cursor.x - 1, .y = game.cursor.y - 2 }, hex(0xFFFFFF));
    }
}
