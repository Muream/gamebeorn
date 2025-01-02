package ui

import rl "vendor:raylib"

import clay "../clay-odin"

FONT_ID_BODY_18 :: 0

text_config: clay.TextElementConfig = {
    fontId    = FONT_ID_BODY_18,
    fontSize  = 32,
    textColor = {255, 255, 255, 255},
}

init_clay :: proc(width: f32, height: f32) {
    minMemorySize: u32 = clay.MinMemorySize()
    memory := make([^]u8, minMemorySize)
    arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(minMemorySize, memory)
    clay.Initialize(arena, {width, height})
    clay.SetMeasureTextFunction(measureText)

    font_path: cstring = `fonts\Roboto\Roboto-Regular.ttf`
    raylibFonts[FONT_ID_BODY_18] = RaylibFont {
        font   = rl.LoadFontEx(font_path, cast(i32)32 * 2, nil, 0),
        fontId = cast(u16)FONT_ID_BODY_18,
    }

}
