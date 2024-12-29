package cpu

import "core:math/bits"

import "../memory"

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

// Return a pointer to the matching r8 register
get_r8 :: proc(self: ^CPU, register: Register) -> ^u8 {
    reg: ^u8
    #partial switch register {
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
    }
    return reg
}

//// ---- 8-bit Arithmetic and Logic Instructions -------------------------------------

// Increment value in register r8 by 1.
inc_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_add(reg^, 1)

    half_carry := ((reg^ & 0xf) + (1 & 0xf)) & 0x10 == 0x10

    reg^ = res

    set_zero_flag(&self.regs, reg^ == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
}

// Decrement value in register r8 by 1.
dec_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_sub(reg^, 1)
    half_carry := ((reg^ & 0xf) - (1 & 0xf)) & 0x10 == 0x10

    reg^ = res

    set_zero_flag(&self.regs, reg^ == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
}

//// ---- 16-bit Arithmetic Instructions ----------------------------------------------

// Increment value in register r16 by 1.
inc_r16 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    #partial switch register {
    case .BC:
        val := get_bc(&self.regs)
        set_bc(&self.regs, val + 1)
    case .DE:
        val := get_de(&self.regs)
        set_de(&self.regs, val + 1)
    case .HL:
        val := get_hl(&self.regs)
        set_hl(&self.regs, val + 1)
    case .SP:
        self.sp += 1
    }
}

// Decrement value in register r16 by 1.
dec_r16 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    #partial switch register {
    case .BC:
        val := get_bc(&self.regs)
        set_bc(&self.regs, val - 1)
    case .DE:
        val := get_de(&self.regs)
        set_de(&self.regs, val - 1)
    case .HL:
        val := get_hl(&self.regs)
        set_hl(&self.regs, val - 1)
    case .SP:
        self.sp -= 1
    }
}

add_r16_r16 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register, r2: Register) {

    v1: u16
    #partial switch r1 {
    case .BC:
        v1 = get_bc(&self.regs)
    case .DE:
        v1 = get_de(&self.regs)
    case .HL:
        v1 = get_hl(&self.regs)
    }

    v2: u16
    #partial switch r2 {
    case .BC:
        v2 = get_bc(&self.regs)
    case .DE:
        v2 = get_de(&self.regs)
    case .HL:
        v2 = get_hl(&self.regs)
    }

    res, carry := bits.overflowing_add(v1, v2)

    half_carry := (v1 & 0xFFF) > (res & 0xFFF)

    #partial switch r1 {
    case .BC:
        set_bc(&self.regs, res)
    case .DE:
        set_de(&self.regs, res)
    case .HL:
        set_hl(&self.regs, res)
    }

    // - 0 H C
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

//// ---- Bit Operations Instructions -------------------------------------------------
//// ---- Bit Shift Instructions ------------------------------------------------------

rlca :: proc(self: ^CPU, mem: ^memory.Memory) {
    // The carry flag is set to the leftmost bit
    // (the one that wraps around during the rotate)
    mask: u8 = 0b1000_0000
    carry := self.a & mask == mask

    self.a = bits.rotate_left8(self.a, 1)

    set_zero_flag(&self.regs, false)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)

    set_carry_flag(&self.regs, carry)
}

rrca :: proc(self: ^CPU, mem: ^memory.Memory) {
    // The carry flag is set to the leftmost bit
    // (the one that wraps around during the rotate)
    mask: u8 = 0b0000_0001
    carry := self.a & mask == mask

    // self.a = bits.rotate_right8(self.a, 1)
    self.a = (self.a >> 1) | (self.a << 7)

    set_zero_flag(&self.regs, false)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)
    set_carry_flag(&self.regs, carry)

}


//// ---- Load Instructions -----------------------------------------------------------

// Load value n8 into register r8.
ld_r8_r8 :: proc() {}

// Load value n8 into register r8.
ld_r8_n8 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    reg := get_r8(self, r1)
    reg^ = next_byte(self, mem)
}

// Load value n16 into register r16.
ld_r16_n16 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    #partial switch r1 {
    case .AF:
        self.f = next_byte(self, mem)
        self.a = next_byte(self, mem)
    case .BC:
        self.c = next_byte(self, mem)
        self.b = next_byte(self, mem)
    case .DE:
        self.e = next_byte(self, mem)
        self.d = next_byte(self, mem)
    case .HL:
        self.l = next_byte(self, mem)
        self.h = next_byte(self, mem)
    case .SP:
        panic("Not Implemented")
    }
}

ld_hl_r8 :: proc() {}
ld_hl_n8 :: proc() {}
ld_r8_hl :: proc() {}

// Store value in register A into the byte pointed to by register r16.
ld_r16_a :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    addr: u16
    #partial switch r1 {
    case .BC:
        addr := get_bc(&self.regs)
    case .DE:
        addr := get_de(&self.regs)
    }
    memory.write(mem, addr, self.a)
}

ld_n16_a :: proc() {}
ldh_n16_a :: proc() {}
ldh_c_a :: proc() {}

// Load value in register A from the byte pointed to by register r16.
ld_a_r16 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    #partial switch r1 {
    case .DE:
        addr := get_de(&self.regs)
        val := memory.read(mem, addr)
        self.a = val
    }
}

ld_a_n16 :: proc() {}
ldh_a_n16 :: proc() {}
ldh_a_c :: proc() {}
ld_hli_a :: proc() {}
ld_hld_a :: proc() {}
ld_a_hli :: proc() {}
ld_a_hld :: proc() {}

ld_n16_sp :: proc(self: ^CPU, mem: ^memory.Memory) {
    // Store SP & $FF at address n16 and SP >> 8 at address n16 + 1.
    addr := next_word(self, mem)
    a := cast(u8)(self.sp & 0xFF)
    b := cast(u8)(self.sp >> 8)
    memory.write(mem, addr, a)
    memory.write(mem, addr + 1, b)
}
//// ---- Jumps and Subroutines -------------------------------------------------------
//// ---- Stack Operations Instructions -----------------------------------------------
//// ---- Miscellaneous Instructions --------------------------------------------------


// JR_cc_n16 :: proc(self: ^CPU, condition: bool, address: u16) {
//     if condition {
//         self.pc = address
//     }
// }
