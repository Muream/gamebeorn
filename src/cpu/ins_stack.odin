package cpu

import "core:fmt"
import "core:math/bits"

import "../memory"

add_hl_sp :: #force_inline proc() {}

add_sp_e8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    value := cast(u16)cast(i16)transmute(i8)next_byte(self, mem)
    result, _ := bits.overflowing_add(self.sp, value)

    half_carry_mask: u16 = 0xF
    half_carry :=
        (self.sp & half_carry_mask) + (value & half_carry_mask) > half_carry_mask

    carry_mask: u16 = 0xff
    carry := (self.sp & carry_mask) + (value & carry_mask) > carry_mask

    set_zero_flag(self, false)
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)

    self.sp = result
}

dec_sp :: #force_inline proc() {}
inc_sp :: #force_inline proc() {}
ld_sp_n16 :: #force_inline proc() {}

ld_n16_sp :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    // Store SP & $FF at address n16 and SP >> 8 at address n16 + 1.
    addr := next_word(self, mem)
    a := cast(u8)(self.sp & 0xFF)
    b := cast(u8)(self.sp >> 8)
    memory.write(mem, addr, a)
    memory.write(mem, addr + 1, b)
}

ld_hl_sp_e8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    value := cast(u16)cast(i16)transmute(i8)next_byte(self, mem)
    result, _ := bits.overflowing_add(self.sp, value)

    half_carry_mask: u16 = 0xF
    half_carry :=
        (self.sp & half_carry_mask) + (value & half_carry_mask) > half_carry_mask

    carry_mask: u16 = 0xff
    carry := (self.sp & carry_mask) + (value & carry_mask) > carry_mask

    set_zero_flag(self, false)
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)

    set_hl(self, result)
}

ld_sp_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    self.sp = get_hl(self)
}

pop_af :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    self.f = memory.read(mem, self.sp) & 0b1111_0000
    self.sp += 1

    self.a = memory.read(mem, self.sp)
    self.sp += 1
}


pop_r16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    // ld LOW(r16), [sp] ; C, E or L
    // inc sp
    // ld HIGH(r16), [sp] ; B, D or H
    // inc sp

    low_reg: ^u8
    high_reg: ^u8
    #partial switch register {
    case .BC:
        low_reg = &self.c
        high_reg = &self.b
    case .DE:
        low_reg = &self.e
        high_reg = &self.d
    case .HL:
        low_reg = &self.l
        high_reg = &self.h
    case:
        fmt.panicf("Invalid Register %v", register)
    }

    low_reg^ = memory.read(mem, self.sp)
    self.sp += 1

    high_reg^ = memory.read(mem, self.sp)
    self.sp += 1
}

push_af :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    // dec sp
    // ld [sp], a
    // dec sp
    // ld [sp], flag_Z << 7 | flag_N << 6 | flag_H << 5 | flag_C << 4

    self.sp -= 1
    memory.write(mem, self.sp, self.a)

    self.sp -= 1
    memory.write(mem, self.sp, self.f)

}
push_r16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    // dec sp
    // ld [sp], HIGH(r16) ; B, D or H
    // dec sp
    // ld [sp], LOW(r16) ; C, E or L

    low_reg: ^u8
    high_reg: ^u8
    #partial switch register {
    case .BC:
        low_reg = &self.c
        high_reg = &self.b
    case .DE:
        low_reg = &self.e
        high_reg = &self.d
    case .HL:
        low_reg = &self.l
        high_reg = &self.h
    case:
        fmt.panicf("Invalid Register %v", register)
    }

    self.sp -= 1
    memory.write(mem, self.sp, low_reg^)

    self.sp -= 1
    memory.write(mem, self.sp, high_reg^)
}
