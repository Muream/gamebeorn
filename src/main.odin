package main

import "base:intrinsics"
import "core:fmt"
import "core:log"
import "core:os"


import "cpu"
import "emulator"
import "memory"


main :: proc() {
    context.logger = log.create_console_logger()

    emu := emulator.init()

    {
        boot_rom_path := `roms\dmg_boot.bin`
        boot_rom, ok := os.read_entire_file(boot_rom_path)
        copy(emu.gb.mem.mem[0x00:0x0100], boot_rom[:])
    }

    // {
    //     rom_path := `roms\blargg\cpu_instrs\cpu_instrs.gb`
    //     data, ok := os.read_entire_file(rom_path)
    //     copy(emu.gb.mem.mem[0x00:0x3FFF], data[:])
    // }
    // emu.gb.cpu.pc = 0x100

    for true {
        cpu.step(&emu.gb.cpu, &emu.gb.mem)
    }
}
