package main

import "core:fmt"
import "core:os"


import "cpu"
import "emulator"
import "memory"


main :: proc() {
    emu := emulator.init()

    filepath := `roms\blargg\cpu_instrs\cpu_instrs.gb`
    data, ok := os.read_entire_file(filepath, context.allocator)
    emu.gb.mem.rom = memory.load_rom(data)

    for true {
        cpu.step(&emu.gb.cpu, &emu.gb.mem)
    }
}
