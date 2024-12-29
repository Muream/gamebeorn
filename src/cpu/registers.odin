package cpu

import "core:log"
import "core:math/bits"

// Registers :: struct {
//     a:  u8 `fmt:"8b"`,
//     f:  u8 `fmt:"8b"`,
//     b:  u8 `fmt:"8b"`,
//     c:  u8 `fmt:"8b"`,
//     d:  u8 `fmt:"8b"`,
//     e:  u8 `fmt:"8b"`,
//     h:  u8 `fmt:"8b"`,
//     l:  u8 `fmt:"8b"`,
//     sp: u16 `fmt:"16b"`,
//     pc: u16 `fmt:"16b"`,
// }

Registers :: struct {
    a:  u8,
    f:  u8,
    b:  u8,
    c:  u8,
    d:  u8,
    e:  u8,
    h:  u8,
    l:  u8,
    sp: u16,
    pc: u16,
}

// 7	z	Zero flag
// 6	n	Subtraction flag (BCD)
// 5	h	Half Carry flag (BCD)
// 4	c	Carry flag
set_zero_flag :: proc(self: ^Registers, value: bool) {
    if value {
        self.f |= 0b1000_0000
    } else {
        self.f &= 0b0111_0000
    }
}

set_sub_flag :: proc(self: ^Registers, value: bool) {
    if value {
        self.f |= 0b0100_0000
    } else {
        self.f &= 0b1011_0000
    }
}

set_half_carry_flag :: proc(self: ^Registers, value: bool) {
    if value {
        self.f |= 0b0010_0000
    } else {
        self.f &= 0b1101_0000
    }
}

set_carry_flag :: proc(self: ^Registers, value: bool) {
    if value {
        self.f |= 0b0001_0000
    } else {
        self.f &= 0b1110_0000
    }
}

get_carry_flag :: proc(self: ^Registers) -> bool {
    return self.f & 0b1000_0000 == 0b1000_0000
}


reset_flags :: proc(self: ^Registers) {
    self.f = 0
}

get_bc :: proc(self: ^Registers) -> u16 {
    return (cast(u16)self.b << 8) | cast(u16)self.c
}

set_bc :: proc(self: ^Registers, value: u16) {
    self.b = cast(u8)(value >> 8)
    self.c = cast(u8)(value & 0xFF)
}

get_de :: proc(self: ^Registers) -> u16 {
    return (cast(u16)self.d << 8) | cast(u16)self.e
}

set_de :: proc(self: ^Registers, value: u16) {
    self.d = cast(u8)(value >> 8)
    self.e = cast(u8)(value & 0xFF)
}

get_hl :: proc(self: ^Registers) -> u16 {
    return (cast(u16)self.h << 8) | cast(u16)self.l
}

set_hl :: proc(self: ^Registers, value: u16) {
    self.h = cast(u8)(value >> 8)
    self.l = cast(u8)(value & 0xFF)
}
