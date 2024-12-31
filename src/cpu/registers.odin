package cpu

import "core:fmt"
import "core:log"
import "core:math/bits"

Registers :: struct {
    a:  u8,
    f:  u8 `fmt:"8b"`,
    b:  u8,
    c:  u8,
    d:  u8,
    e:  u8,
    h:  u8,
    l:  u8,
    sp: u16,
    pc: u16,
}

Register :: enum {
    A,
    B,
    C,
    D,
    E,
    F,
    H,
    L,
    AF,
    BC,
    DE,
    HL,
    SP,
}

Condition :: enum {
    Z,
    NZ,
    C,
    NC,
}

set_zero_flag :: proc(self: ^CPU, value: bool) {
    if value {
        self.f |= 0b1000_0000
    } else {
        self.f &= 0b0111_0000
    }
}

set_sub_flag :: proc(self: ^CPU, value: bool) {
    if value {
        self.f |= 0b0100_0000
    } else {
        self.f &= 0b1011_0000
    }
}

set_half_carry_flag :: proc(self: ^CPU, value: bool) {
    if value {
        self.f |= 0b0010_0000
    } else {
        self.f &= 0b1101_0000
    }
}

set_carry_flag :: proc(self: ^CPU, value: bool) {
    if value {
        self.f |= 0b0001_0000
    } else {
        self.f &= 0b1110_0000
    }
}

get_zero_flag :: proc(self: ^CPU) -> bool {
    return self.f & 0b1000_0000 == 0b1000_0000
}

get_sub_flag :: proc(self: ^CPU) -> bool {
    return self.f & 0b0100_0000 == 0b0100_0000
}

get_half_carry_flag :: proc(self: ^CPU) -> bool {
    return self.f & 0b0010_0000 == 0b0010_0000
}

get_carry_flag :: proc(self: ^CPU) -> bool {
    return self.f & 0b0001_0000 == 0b0001_0000
}

reset_flags :: proc(self: ^CPU) {
    self.f = 0
}

get_bc :: proc(self: ^CPU) -> u16 {
    return (cast(u16)self.b << 8) | cast(u16)self.c
}

set_bc :: proc(self: ^CPU, value: u16) {
    self.b = cast(u8)(value >> 8)
    self.c = cast(u8)(value & 0xFF)
}

get_de :: proc(self: ^CPU) -> u16 {
    return (cast(u16)self.d << 8) | cast(u16)self.e
}

set_de :: proc(self: ^CPU, value: u16) {
    self.d = cast(u8)(value >> 8)
    self.e = cast(u8)(value & 0xFF)
}

get_hl :: proc(self: ^CPU) -> u16 {
    return (cast(u16)self.h << 8) | cast(u16)self.l
}

set_hl :: proc(self: ^CPU, value: u16) {
    self.h = cast(u8)(value >> 8)
    self.l = cast(u8)(value & 0xFF)
}

// Return a pointer to the matching r8 register
get_r8 :: proc(self: ^CPU, register: Register) -> ^u8 {
    reg: ^u8
    #partial switch register {
    case .A:
        reg = &self.a
    case .B:
        reg = &self.b
    case .C:
        reg = &self.c
    case .D:
        reg = &self.d
    case .E:
        reg = &self.e
    case .F:
        reg = &self.f
    case .H:
        reg = &self.h
    case .L:
        reg = &self.l
    case:
        fmt.panicf("Invalid r8 Register %v", register)
    }
    return reg
}

check_condition :: proc(self: ^CPU, cond: Condition) -> bool {

    cond_res: bool

    switch cond {
    case .Z:
        cond_res = get_zero_flag(self) == true
    case .NZ:
        cond_res = get_zero_flag(self) == false
    case .C:
        cond_res = get_carry_flag(self) == true
    case .NC:
        cond_res = get_carry_flag(self) == false
    }

    return cond_res
}
