package memory

WRAM_SIZE :: 16 * 1024

WRAM :: struct {
    bytes: [WRAM_SIZE]u8,
}

make_wram :: proc() -> WRAM {
    return WRAM{[WRAM_SIZE]u8{}}
}

read_wram :: proc(m: ^WRAM, address: u16) -> u8 {
    return m.bytes[address]
}

write_wram :: proc(m: ^WRAM, address: u16, value: u8) {
    m.bytes[address] = value
}
