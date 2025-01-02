package main

import "core:fmt"
import "core:log"
import "core:os"

import clay "clay-odin"
import rl "vendor:raylib"

import "cpu"
import "emulator"
import "memory"
import "ui"

TILE_COUNT :: 384

TILE_SIZE :: 16
TILE_ROW_SIZE :: 2

TILES_PER_ROW :: 24
COLUMN_COUNT :: TILE_COUNT / TILES_PER_ROW

PIXEL_SIZE :: 7
GAP :: 2
BORDER :: 15

palette := [?]rl.Color{rl.BLACK, rl.DARKGRAY, rl.GRAY, rl.WHITE}

main :: proc() {
    context.logger = log.create_console_logger(opt = {.Level, .Terminal_Color, .Line})

    // rl.SetConfigFlags({.VSYNC_HINT})

    width: i32 = TILES_PER_ROW * (PIXEL_SIZE * 8 + GAP) + BORDER * 2
    height: i32 = COLUMN_COUNT * (PIXEL_SIZE * 8 + GAP) + BORDER * 2
    rl.InitWindow(width, height, "GameBeorn")
    defer rl.CloseWindow()

    ui.init_clay(cast(f32)width, cast(f32)height)

    // This just makes sure your battery doesn't drain too fast in case VSYNC
    // is forced off.
    // rl.SetTargetFPS(60)

    emu := emulator.init()

    // rom_path := `roms\dmg-acid2\dmg-acid2.gb`
    // rom_path := `roms\GB\Japan\Tetris (Japan) (En)\Tetris (Japan) (En).gb`
    // rom_path := `roms\blargg\cpu_instrs\individual\01-special.gb`
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
    // emu.gb.cpu.pc = 0x0000

    emu.state = .Paused
    for !rl.WindowShouldClose() {
        emu.frame_time = rl.GetFrameTime()
        clay.SetLayoutDimensions(
            {cast(f32)rl.GetScreenWidth(), cast(f32)rl.GetScreenHeight()},
        )

        if rl.IsKeyPressed(.F8) {emu.state = .Stepping}
        if rl.IsKeyPressed(.F9) {emu.state = .Playing}

        if emu.state != .Paused {
            cpu.step(&emu.gb.cpu, &emu.gb.mem)
        }

        if emu.state == .Stepping {
            emu.state = .Paused
        }

        clay.BeginLayout()
        ui.cpu_panel(&emu)
        render_commands := clay.EndLayout()

        rl.BeginDrawing()
        rl.ClearBackground(rl.DARKBLUE)

        draw_tiles(&emu)

        // ui.clayRaylibRender(&render_commands)

        rl.EndDrawing()
    }
}


draw_tiles :: proc(emu: ^emulator.Emulator) {
    tile_addr := 0x8000
    pos: rl.Vector2 = {0, 0}
    for tile_idx in 0 ..< 384 {
        pos.x = cast(f32)((tile_idx % TILES_PER_ROW) * (PIXEL_SIZE * 8 + GAP) + BORDER)
        pos.y = cast(f32)((tile_idx / TILES_PER_ROW) * (PIXEL_SIZE * 8 + GAP) + BORDER)

        tile := emu.gb.mem.mem[tile_addr:tile_addr + TILE_SIZE]
        // fmt.printfln("%02x: %02x", tile_addr, tile)

        draw_tile(tile, pos)

        tile_addr += TILE_SIZE
    }
}


draw_tile :: proc(tile: []u8, pos: rl.Vector2) {
    x: i32 = 0
    y: i32 = 0
    for row_idx in 0 ..< 8 {
        addr := row_idx * TILE_ROW_SIZE
        row := tile[addr:addr + TILE_ROW_SIZE]
        byte1 := tile[0] // 0b1100_1100
        byte2 := tile[1] // 0b0110_1010

        for pixel in 0 ..< 8 {
            mask: u8 = 1 < (7 - pixel)
            lsb := byte1 & mask
            msb := byte2 & mask
            // offset := cast(uint)pixel * 2
            // mask: u8 = 0b1100_0000 >> offset
            // value := (byte & (mask)) >> (6 - offset)
            asdf: struct {
                _: bool,
                _: bool,
            } = {lsb != 0, msb != 0}

            color: rl.Color
            switch asdf {
            case {true, true}:
                color = palette[0]
            case {true, false}:
                color = palette[1]
            case {false, true}:
                color = palette[2]
            case {false, false}:
                color = palette[3]
            }
            rl.DrawRectangle(
                x + cast(i32)pos.x,
                y + cast(i32)pos.y,
                PIXEL_SIZE,
                PIXEL_SIZE,
                color,
            )
            x += PIXEL_SIZE
        }

        x = 0
        y += PIXEL_SIZE
    }
}
