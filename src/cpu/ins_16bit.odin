package cpu

import "core:math/bits"

import "../memory"

// Increment value in register r16 by 1.
inc_r16 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    #partial switch register {
    case .BC:
        val := get_bc(self)
        set_bc(self, val + 1)
    case .DE:
        val := get_de(self)
        set_de(self, val + 1)
    case .HL:
        val := get_hl(self)
        set_hl(self, val + 1)
    case .SP:
        self.sp += 1
    }
}

// Decrement value in register r16 by 1.
dec_r16 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    #partial switch register {
    case .BC:
        val := get_bc(self)
        set_bc(self, val - 1)
    case .DE:
        val := get_de(self)
        set_de(self, val - 1)
    case .HL:
        val := get_hl(self)
        set_hl(self, val - 1)
    case .SP:
        self.sp -= 1
    }
}

add_r16_r16 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register, r2: Register) {

    v1: u16
    #partial switch r1 {
    case .BC:
        v1 = get_bc(self)
    case .DE:
        v1 = get_de(self)
    case .HL:
        v1 = get_hl(self)
    case .SP:
        v1 = self.sp
    }

    v2: u16
    #partial switch r2 {
    case .BC:
        v2 = get_bc(self)
    case .DE:
        v2 = get_de(self)
    case .HL:
        v2 = get_hl(self)
    case .SP:
        v2 = self.sp
    }

    res, carry := bits.overflowing_add(v1, v2)

    half_carry := (v1 & 0xFFF) > (res & 0xFFF)

    #partial switch r1 {
    case .BC:
        set_bc(self, res)
    case .DE:
        set_de(self, res)
    case .HL:
        set_hl(self, res)
    case .SP:
        self.sp = res
    }

    // - 0 H C
    set_sub_flag(self, false)
    set_half_carry_flag(self, half_carry)
    set_carry_flag(self, carry)
}
