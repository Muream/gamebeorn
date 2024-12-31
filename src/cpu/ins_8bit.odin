package cpu

import "core:fmt"
import "core:log"
import "core:math/bits"

import "../memory"

// Add the value in r8 plus the carry flag to A.
adc_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(self)
    v := cast(u16)get_r8(self, register)^
    r := a + v + c

    set_zero_flag(self, r & 0xFF == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, (a & 0xF) + (v & 0xF) + c > 0xF)
    set_carry_flag(self, r > 0xff)

    self.a = cast(u8)r
}

adc_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(self)

    addr := get_hl(self)
    v := cast(u16)memory.read(mem, addr)

    r := a + v + c

    set_zero_flag(self, r & 0xFF == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, (a & 0xF) + (v & 0xF) + c > 0xF)
    set_carry_flag(self, r > 0xff)

    self.a = cast(u8)r
}
adc_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(self)
    v := cast(u16)next_byte(self, mem)
    r := a + v + c

    set_zero_flag(self, r & 0xFF == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, (a & 0xF) + (v & 0xF) + c > 0xF)
    set_carry_flag(self, r > 0xff)

    self.a = cast(u8)r
}

add_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_add(self.a, reg^)

    half_carry := ((self.a & 0xf) + (reg^ & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

add_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    value := memory.read(mem, addr)

    res, carry := bits.overflowing_add(self.a, value)

    half_carry := ((self.a & 0xf) + (value & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

add_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    res, carry := bits.overflowing_add(self.a, v)

    half_carry := ((self.a & 0xf) + (v & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

and_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    self.a &= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, true)
    set_carry_flag(self, false)
}

and_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(self))

    self.a &= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, true)
    set_carry_flag(self, false)
}

and_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    self.a &= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, true)
    set_carry_flag(self, false)
}

cp_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    set_zero_flag(self, res == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

cp_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(self))

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    set_zero_flag(self, res == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

cp_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    set_zero_flag(self, res == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

// Decrement value in register r8 by 1.
dec_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_sub(reg^, 1)
    half_carry := ((reg^ & 0xf) - (1 & 0xf)) & 0x10 == 0x10

    reg^ = res

    set_zero_flag(self, reg^ == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
}

dec_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)

    value := memory.read(mem, addr)
    res, carry := bits.overflowing_sub(value, 1)

    half_carry := ((value & 0xf) - (1 & 0xf)) & 0x10 == 0x10

    memory.write(mem, addr, res)

    set_zero_flag(self, res == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
}


// Increment value in register r8 by 1.
inc_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_add(reg^, 1)

    half_carry := ((reg^ & 0xf) + (1 & 0xf)) & 0x10 == 0x10

    reg^ = res

    set_zero_flag(self, reg^ == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
}

inc_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)

    value := memory.read(mem, addr)
    res, carry := bits.overflowing_add(value, 1)

    half_carry := ((value & 0xf) + (1 & 0xf)) & 0x10 == 0x10

    memory.write(mem, addr, res)

    set_zero_flag(self, res == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
}

or_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    self.a |= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, false)
}

or_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(self))

    self.a |= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, false)
}
or_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    self.a |= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, false)
}

sbc_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(self)
    v := cast(u16)get_r8(self, register)^
    r := a - v - c

    set_zero_flag(self, r & 0xFF == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, (a & 0xF) - (v & 0xF) - c > 0xF)
    set_carry_flag(self, r > 0xff)

    self.a = cast(u8)r
}

sbc_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(self)

    addr := get_hl(self)
    v := cast(u16)memory.read(mem, addr)

    r := a - v - c

    set_zero_flag(self, r & 0xFF == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, (a & 0xF) - (v & 0xF) - c > 0xF)
    set_carry_flag(self, r > 0xff)

    self.a = cast(u8)r
}

sbc_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(self)
    v := cast(u16)next_byte(self, mem)
    r := a - v - c

    set_zero_flag(self, r & 0xFF == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, (a & 0xF) - (v & 0xF) - c > 0xF)
    set_carry_flag(self, r > 0xff)

    self.a = cast(u8)r
}

sub_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

sub_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_sub(self.a, reg^)

    half_carry := ((self.a & 0xf) - (reg^ & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

sub_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(self))

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, true)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}

xor_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    self.a ~= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, false)
}

xor_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(self))

    self.a ~= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, false)
}

xor_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    self.a ~= v

    set_zero_flag(self, self.a == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, false)
}
