package main

import "core:fmt"
import "core:log"
import "core:os"

import clay "clay-odin"
import rl "vendor:raylib"

import "cpu"
import "emulator"
import "memory"

TILE_COUNT :: 384

TILE_SIZE :: 16
TILE_ROW_SIZE :: 2

TILES_PER_ROW :: 24
COLUMN_COUNT :: TILE_COUNT / TILES_PER_ROW

PIXEL_SIZE :: 1
GAP :: 2
BORDER :: 15

FONT_ID_BODY_18 :: 0

palette := [?]rl.Color{rl.BLACK, rl.DARKGRAY, rl.GRAY, rl.WHITE}

main :: proc() {
    context.logger = log.create_console_logger()

    rl.SetConfigFlags({.VSYNC_HINT})

    width: i32 = TILES_PER_ROW * (PIXEL_SIZE * 8 + GAP) + BORDER * 2
    height: i32 = COLUMN_COUNT * (PIXEL_SIZE * 8 + GAP) + BORDER * 2
    rl.InitWindow(width, height, "GameBeorn")
    defer rl.CloseWindow()

    minMemorySize: u32 = clay.MinMemorySize()
    memory := make([^]u8, minMemorySize)
    arena: clay.Arena = clay.CreateArenaWithCapacityAndMemory(minMemorySize, memory)
    clay.Initialize(arena, {cast(f32)width, cast(f32)height})
    clay.SetMeasureTextFunction(measureText)

    font_path: cstring = `fonts\Roboto\Roboto-Regular.ttf`
    raylibFonts[FONT_ID_BODY_18] = RaylibFont {
        font   = rl.LoadFontEx(font_path, cast(i32)32 * 2, nil, 0),
        fontId = cast(u16)FONT_ID_BODY_18,
    }


    text_config: clay.TextElementConfig = {
        fontId    = FONT_ID_BODY_18,
        fontSize  = 32,
        textColor = {255, 255, 255, 255},
    }

    // This just makes sure your battery doesn't drain too fast in case VSYNC
    // is forced off.
    rl.SetTargetFPS(60)

    emu := emulator.init()

    // rom_path := `roms\dmg-acid2\dmg-acid2.gb`
    // rom_path := `roms\GB\Japan\Tetris (Japan) (En)\Tetris (Japan) (En).gb`
    rom_path := `roms\blargg\cpu_instrs\cpu_instrs.gb`
    rom, rom_ok := os.read_entire_file(rom_path)
    if !rom_ok {
        panic("Could not read ROM")
    }
    copy(emu.gb.mem.mem[:], rom[:])
    emu.gb.cpu.pc = 0x0100

    // boot_rom_path := `roms\dmg_boot.gb`
    // boot_rom, boot_rom_ok := os.read_entire_file(boot_rom_path)
    // if !boot_rom_ok {
    //     panic("Could not read Boot ROM")
    // }
    // copy(emu.gb.mem.mem[:], boot_rom[:])

    step: bool = false
    for !rl.WindowShouldClose() {
        clay.SetLayoutDimensions(
            {cast(f32)rl.GetScreenWidth(), cast(f32)rl.GetScreenHeight()},
        )

        if rl.IsKeyPressed(.F8) {step = true}

        if step {
            cpu.step(&emu.gb.cpu, &emu.gb.mem)
            step = false
        }

        clay.BeginLayout()
        if clay.UI(
            clay.Rectangle({color = {255, 0, 0, 255}}),
            clay.Layout(
                {sizing = {width = clay.SizingGrow({}), height = clay.SizingGrow({})}},
            ),
        ) {
            if clay.UI(
                clay.ID("Left Panel"),
                clay.Rectangle({color = {90, 90, 90, 255}}),
                clay.Layout(
                    {
                        layoutDirection = clay.LayoutDirection.TOP_TO_BOTTOM,
                        sizing = {
                            width = clay.SizingGrow({}),
                            height = clay.SizingGrow({}),
                        },
                    },
                ),
            ) {
                clay.Text("CPU", &text_config)
                z := "Z" if cpu.get_zero_flag(&emu.gb.cpu) else "-"
                n := "N" if cpu.get_sub_flag(&emu.gb.cpu) else "-"
                h := "H" if cpu.get_half_carry_flag(&emu.gb.cpu) else "-"
                c := "C" if cpu.get_carry_flag(&emu.gb.cpu) else "-"
                clay.Text(
                    fmt.aprintf(
                        "AF: %02X %02X %v %v %v %v",
                        emu.gb.cpu.a,
                        emu.gb.cpu.f,
                        z,
                        n,
                        h,
                        c,
                    ),
                    &text_config,
                )
                clay.Text(
                    fmt.aprintf("BC: %02X %02X", emu.gb.cpu.b, emu.gb.cpu.c),
                    &text_config,
                )
                clay.Text(
                    fmt.aprintf("DE: %02X %02X", emu.gb.cpu.d, emu.gb.cpu.e),
                    &text_config,
                )
                clay.Text(
                    fmt.aprintf("HL: %02X %02X", emu.gb.cpu.h, emu.gb.cpu.l),
                    &text_config,
                )
                clay.Text(fmt.aprintf("SP: %04X", emu.gb.cpu.sp), &text_config)
                clay.Text(fmt.aprintf("PC: %04X", emu.gb.cpu.pc), &text_config)
            }
        }
        render_commands := clay.EndLayout()

        rl.BeginDrawing()

        clayRaylibRender(&render_commands)

        rl.EndDrawing()
    }
}

draw_tiles :: proc(emu: ^emulator.Emulator) {
    // tile_addr := 0x8000
    // pos: rl.Vector2 = {0, 0}
    // for tile_idx in 0 ..< 384 {
    //     pos.x =
    //     cast(f32)((tile_idx % TILES_PER_ROW) * (PIXEL_SIZE * 8 + GAP) + BORDER)
    //     pos.y =
    //     cast(f32)((tile_idx / TILES_PER_ROW) * (PIXEL_SIZE * 8 + GAP) + BORDER)

    //     tile := emu.gb.mem.mem[tile_addr:tile_addr + TILE_SIZE]

    //     draw_tile(tile, pos)

    //     tile_addr += TILE_SIZE
    // }
}


draw_tile :: proc(tile: []u8, pos: rl.Vector2) {
    x: i32 = 0
    y: i32 = 0
    for row_idx in 0 ..< 8 {
        addr := row_idx * TILE_ROW_SIZE
        row := tile[addr:addr + TILE_ROW_SIZE]
        for byte in row {
            for pixel in 0 ..< 4 {
                offset := cast(uint)pixel * 2
                value := (byte & (0b1100_0000 >> offset)) >> offset
                color := palette[value]
                rl.DrawRectangle(
                    x + cast(i32)pos.x,
                    y + cast(i32)pos.y,
                    PIXEL_SIZE,
                    PIXEL_SIZE,
                    color,
                )
                x += PIXEL_SIZE
            }
        }
        x = 0
        y += PIXEL_SIZE
    }
}
