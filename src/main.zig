const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

var p = c.SDL_Point{ .x = 0, .y = 0 };

const k_screen_width: i32 = 320;
const k_screen_height: i32 = 240;

var g_window: ?*c.SDL_Window = null;
var g_renderer: ?*c.SDL_Renderer = null;
var g_texture: ?*c.SDL_Texture = null;

var g_quit: bool = false;

fn events_process() void {
    c.SDL_PumpEvents();
    var event: c.SDL_Event = undefined;
    while (c.SDL_PollEvent(&event) != 0) {
        switch (event.type) {
            c.SDL_QUIT => {
                g_quit = true;
            },
            else => {},
        }
    }
}

fn game_update() void {}

fn game_draw() void {
    if (c.SDL_SetRenderDrawColor(g_renderer, 255, 255, 255, 255) != 0) {
        c.SDL_Log("Unable to set color for the rendering target: %s", c.SDL_GetError());
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLSetRenderDrawColorFailed;
    }
    if (c.SDL_RenderDrawLine(g_renderer, p.x, p.y, 160, 120) != 0) {
        c.SDL_Log("Unable to draw line on the rendering target: %s", c.SDL_GetError());
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLRenderDrawLineFailed;
    }
}

fn frame_present() void {
    c.SDL_RenderPresent(g_renderer);
    if (c.SDL_SetRenderDrawColor(g_renderer, 0, 0, 0, 255) != 0) {
        c.SDL_Log("Unable to set color for the rendering target: %s", c.SDL_GetError());
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLSetRenderDrawColorFailed;
    }
    if (c.SDL_RenderClear(g_renderer) != 0) {
        c.SDL_Log("Unable to clear the rendering target: %s", c.SDL_GetError());
        g_quit = true;
        //XXX: I don't yet understand how to handle return errors that aren't in main().
        //return error.SDLRenderClearFailed;
    }
}

pub fn main() !void {
    // The whole SDL init

    if (c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitFailed;
    }
    defer c.SDL_Quit();

    g_window = c.SDL_CreateWindow("", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, k_screen_width, k_screen_height, c.SDL_WINDOW_SHOWN | c.SDL_WINDOW_ALLOW_HIGHDPI) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLCreateWindowFailed;
    };
    defer c.SDL_DestroyWindow(g_window);

    g_renderer = c.SDL_CreateRenderer(g_window, -1, c.SDL_RENDERER_PRESENTVSYNC) orelse
        {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLCreateRendererFailed;
    };
    defer c.SDL_DestroyRenderer(g_renderer);

    if (c.SDL_RenderSetLogicalSize(g_renderer, k_screen_width, k_screen_height) != 0) {
        c.SDL_Log("Unable to set independent resolution for rendering: %s", c.SDL_GetError());
        //XXX: Not sure if execution should stop because of that.
        //return error.SDLRenderSetLogicalSizeFailed;
    }

    // Game loop
    while (!g_quit) {
        events_process();
        game_update();
        game_draw();
        frame_present();
    }
}
