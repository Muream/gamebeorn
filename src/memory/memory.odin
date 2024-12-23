package memory

import "core:fmt"

ROM_START :: 0x0000
ROM_END :: 0x3FFF

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
    fmt.println("Init Memory")
    return {make_rom(), make_vram(), make_wram(), make_hram()}
}

read :: proc(self: ^Memory, address: u16) -> u8 {
    switch address {
    case ROM_START ..= ROM_END:
        return read_rom(&self.rom, address)
    case VRAM_START ..= VRAM_END:
        return read_vram(&self.vram, address)
    case ERAM_START ..= ERAM_END:
        return read_rom(&self.rom, address)
    case WRAM_START ..= WRAM_END:
        return read_wram(&self.wram, address)
    case ECHO_START ..= ECHO_END:
        return read_wram(&self.wram, address)
    case OAM_START ..= OAM_END:
        return read_vram(&self.vram, address)
    case HRAM_START ..= HRAM_END:
        return read_hram(&self.hram, address)
    case:
        panic("Invalid Read")
    }
}
