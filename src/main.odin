package main

import "core:fmt"
import "core:log"
import "core:os"

import rl "vendor:raylib"

import "cpu"
import "emulator"
import "memory"

TILE_COUNT :: 384

TILE_SIZE :: 16
TILE_ROW_SIZE :: 2

TILES_PER_ROW :: 24
COLUMN_COUNT :: TILE_COUNT / TILES_PER_ROW

PIXEL_SIZE :: 8
GAP :: 2
BORDER :: 15

palette := [?]rl.Color{rl.BLACK, rl.DARKGRAY, rl.GRAY, rl.WHITE}

main :: proc() {
    context.logger = log.create_console_logger()

    rl.SetConfigFlags({.VSYNC_HINT})
    rl.InitWindow(
        TILES_PER_ROW * (PIXEL_SIZE * 8 + GAP) + BORDER * 2,
        COLUMN_COUNT * (PIXEL_SIZE * 8 + GAP) + BORDER * 2,
        "GameBeorn",
    )
    defer rl.CloseWindow()

    // This just makes sure your battery doesn't drain too fast in case VSYNC
    // is forced off.
    rl.SetTargetFPS(160)

    emu := emulator.init()

    rom_path := `roms\dmg-acid2\dmg-acid2.gb`
    // rom_path := `roms\GB\Japan\Tetris (Japan) (En)\Tetris (Japan) (En).gb`
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

    for !rl.WindowShouldClose() {
        cpu.step(&emu.gb.cpu, &emu.gb.mem)

        rl.BeginDrawing()

        rl.ClearBackground(rl.DARKBLUE)

        tile_addr := 0x8000
        pos: rl.Vector2 = {0, 0}
        for tile_idx in 0 ..< 384 {
            pos.x =
            cast(f32)((tile_idx % TILES_PER_ROW) * (PIXEL_SIZE * 8 + GAP) + BORDER)
            pos.y =
            cast(f32)((tile_idx / TILES_PER_ROW) * (PIXEL_SIZE * 8 + GAP) + BORDER)

            tile := emu.gb.mem.mem[tile_addr:tile_addr + TILE_SIZE]

            draw_tile(tile, pos)

            tile_addr += TILE_SIZE
        }
        rl.EndDrawing()
    }
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
