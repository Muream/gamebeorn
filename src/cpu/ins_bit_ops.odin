package cpu

import "core:math/bits"

import "../memory"

bit_u3_r8 :: proc(self: ^CPU, mem: ^memory.Memory, bit: u8, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    bit_u3(self, bit, v)
}

bit_u3_hl :: proc(self: ^CPU, mem: ^memory.Memory, bit: u8) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    bit_u3(self, bit, v)
}

bit_u3 :: proc(self: ^CPU, bit: u8, value: u8) {
    r := value & (1 << bit) == 0

    set_zero_flag(self, r)
    set_sub_flag(self, false)
    set_half_carry_flag(self, true)
}

res_u3_r8 :: proc(self: ^CPU, mem: ^memory.Memory, bit: int, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    r := res_u3(bit, v)
    reg^ = r
}

res_u3_hl :: proc(self: ^CPU, mem: ^memory.Memory, bit: int) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    r := res_u3(bit, v)
    memory.write(mem, addr, r)
}

res_u3 :: proc(bit: int, value: u8) -> u8 {
    mask: u8 = 0b1111_1110
    return value & bits.rotate_left8(mask, bit)
}

set_u3_r8 :: proc(self: ^CPU, mem: ^memory.Memory, bit: int, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    r := set_u3(bit, v)
    reg^ = r
}

set_u3_hl :: proc(self: ^CPU, mem: ^memory.Memory, bit: int) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    r := set_u3(bit, v)
    memory.write(mem, addr, r)
}

set_u3 :: proc(bit: int, value: u8) -> u8 {
    mask: u8 = 0b0000_0001
    return value | bits.rotate_left8(mask, bit)
}

swap_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    r := swap(self, v)
    reg^ = r
}

swap_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    r := swap(self, v)
    memory.write(mem, addr, r)
}

swap :: proc(self: ^CPU, value: u8) -> u8 {
    high := value & 0b1111_0000
    low := value & 0b0000_1111

    r := high >> 4 | low << 4

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, false)

    return r
}
