package memory

VRAM_SIZE :: 16 * 1024

VRAM :: struct {
    bytes: [VRAM_SIZE]u8,
}

make_vram :: proc() -> VRAM {
    return VRAM{[VRAM_SIZE]u8{}}
}

read_vram :: proc(m: ^VRAM, address: u16) -> u8 {
    return m.bytes[address]
}
