package memory

HRAM_SIZE :: 32

HRAM :: struct {
    bytes: [HRAM_SIZE]u8,
}

make_hram :: proc() -> HRAM {
    return HRAM{[HRAM_SIZE]u8{}}
}

read_hram :: proc(m: ^HRAM, address: u16) -> u8 {
    return m.bytes[address]
}
