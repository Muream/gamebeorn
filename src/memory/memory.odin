package memory

import "core:fmt"
import "core:log"

ROM_START :: 0x0000
// ROM_END :: 0x3FFF // 16 KiB ROM bank 00
ROM_END :: 0x7FFF // 16 KiB ROM Bank 01–NN

VRAM_START :: 0x8000
VRAM_END :: 0x9FFF

ERAM_START :: 0xA000
ERAM_END :: 0xBFFF

WRAM_START :: 0xC000
WRAM_END :: 0xDFFF

ECHO_START :: 0xE000
ECHO_END :: 0xFDFF

OAM_START :: 0xFE00
OAM_END :: 0xFE9F

HRAM_START :: 0xFF80
HRAM_END :: 0xFFFE

Memory :: struct {
    rom:  ROM,
    vram: VRAM,
    wram: WRAM,
    hram: HRAM,
}

init :: proc() -> Memory {
    log.debug("Init Memory")
    return {make_rom(), make_vram(), make_wram(), make_hram()}
}

read :: proc(self: ^Memory, address: u16) -> u8 {
    switch address {
    case ROM_START ..= ROM_END:
        return read_rom(&self.rom, address)
    case VRAM_START ..= VRAM_END:
        return read_vram(&self.vram, address - VRAM_START)
    case ERAM_START ..= ERAM_END:
        return read_rom(&self.rom, address)
    case WRAM_START ..= WRAM_END:
        return read_wram(&self.wram, address - WRAM_START)
    case ECHO_START ..= ECHO_END:
        return read_wram(&self.wram, address - ECHO_START)
    case OAM_START ..= OAM_END:
        return read_vram(&self.vram, address - OAM_START)
    case HRAM_START ..= HRAM_END:
        return read_hram(&self.hram, address - HRAM_START)
    case:
        fmt.panicf("Invalid Read: %016X", address)
    }
}

write :: proc(self: ^Memory, address: u16, value: u8) {
    switch address {
    case ROM_START ..= ROM_END:
        write_rom(&self.rom, address, value)
    case VRAM_START ..= VRAM_END:
        write_vram(&self.vram, address - VRAM_START, value)
    case ERAM_START ..= ERAM_END:
        write_rom(&self.rom, address, value)
    case WRAM_START ..= WRAM_END:
        write_wram(&self.wram, address - WRAM_START, value)
    case ECHO_START ..= ECHO_END:
        write_wram(&self.wram, address - ECHO_START, value)
    case OAM_START ..= OAM_END:
        write_vram(&self.vram, address - OAM_START, value)
    case HRAM_START ..= HRAM_END:
        write_hram(&self.hram, address - HRAM_START, value)
    case:
        fmt.panicf("Invalid Write: 0x%X, 0x%X", address, value)
    }
}
