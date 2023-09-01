const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const k_screen_width: i32 = 320;
const k_screen_height: i32 = 320;

var g_window: ?*c.SDL_Window = null;
var g_renderer: ?*c.SDL_Renderer = null;
var g_texture: ?*c.SDL_Texture = null;

pub fn main() !void {
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
}
