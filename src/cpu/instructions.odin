package cpu

import "core:fmt"
import "core:log"
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

//// ---- 8-bit Arithmetic and Logic Instructions -------------------------------------

// Add the value in r8 plus the carry flag to A.
adc_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(&self.regs)
    v := cast(u16)get_r8(self, register)^
    r := a + v + c

    set_zero_flag(&self.regs, r & 0xFF == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, (a & 0xF) + (v & 0xF) + c > 0xF)
    set_carry_flag(&self.regs, r > 0xff)

    self.a = cast(u8)r
}

adc_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(&self.regs)

    addr := get_hl(&self.regs)
    v := cast(u16)memory.read(mem, addr)

    r := a + v + c

    set_zero_flag(&self.regs, r & 0xFF == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, (a & 0xF) + (v & 0xF) + c > 0xF)
    set_carry_flag(&self.regs, r > 0xff)

    self.a = cast(u8)r
}
adc_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(&self.regs)
    v := cast(u16)next_byte(self, mem)
    r := a + v + c

    set_zero_flag(&self.regs, r & 0xFF == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, (a & 0xF) + (v & 0xF) + c > 0xF)
    set_carry_flag(&self.regs, r > 0xff)

    self.a = cast(u8)r
}

add_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_add(self.a, reg^)

    half_carry := ((self.a & 0xf) + (reg^ & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

add_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(&self.regs)
    value := memory.read(mem, addr)

    res, carry := bits.overflowing_add(self.a, value)

    half_carry := ((self.a & 0xf) + (value & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

add_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    res, carry := bits.overflowing_add(self.a, v)

    half_carry := ((self.a & 0xf) + (v & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

and_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    self.a &= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, true)
    set_carry_flag(&self.regs, false)
}

and_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(&self.regs))

    self.a &= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, true)
    set_carry_flag(&self.regs, false)
}

and_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    self.a &= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, true)
    set_carry_flag(&self.regs, false)
}

cp_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    set_zero_flag(&self.regs, res == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

cp_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(&self.regs))

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    set_zero_flag(&self.regs, res == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

cp_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    set_zero_flag(&self.regs, res == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
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

dec_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(&self.regs)

    value := memory.read(mem, addr)
    res, carry := bits.overflowing_sub(value, 1)

    half_carry := ((value & 0xf) - (1 & 0xf)) & 0x10 == 0x10

    memory.write(mem, addr, res)

    set_zero_flag(&self.regs, res == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
}


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

inc_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(&self.regs)

    value := memory.read(mem, addr)
    res, carry := bits.overflowing_add(value, 1)

    half_carry := ((value & 0xf) + (1 & 0xf)) & 0x10 == 0x10

    memory.write(mem, addr, res)

    set_zero_flag(&self.regs, res == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
}

or_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    self.a |= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)
    set_carry_flag(&self.regs, false)
}

or_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(&self.regs))

    self.a |= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)
    set_carry_flag(&self.regs, false)
}
or_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    self.a |= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)
    set_carry_flag(&self.regs, false)
}

sbc_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(&self.regs)
    v := cast(u16)get_r8(self, register)^
    r := a - v - c

    set_zero_flag(&self.regs, r & 0xFF == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, (a & 0xF) - (v & 0xF) - c > 0xF)
    set_carry_flag(&self.regs, r > 0xff)

    self.a = cast(u8)r
}

sbc_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(&self.regs)

    addr := get_hl(&self.regs)
    v := cast(u16)memory.read(mem, addr)

    r := a - v - c

    set_zero_flag(&self.regs, r & 0xFF == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, (a & 0xF) - (v & 0xF) - c > 0xF)
    set_carry_flag(&self.regs, r > 0xff)

    self.a = cast(u8)r
}

sbc_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    a := cast(u16)self.a
    c := cast(u16)get_carry_flag(&self.regs)
    v := cast(u16)next_byte(self, mem)
    r := a - v - c

    set_zero_flag(&self.regs, r & 0xFF == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, (a & 0xF) - (v & 0xF) - c > 0xF)
    set_carry_flag(&self.regs, r > 0xff)

    self.a = cast(u8)r
}

sub_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

sub_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)

    res, carry := bits.overflowing_sub(self.a, reg^)

    half_carry := ((self.a & 0xf) - (reg^ & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

sub_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(&self.regs))

    res, carry := bits.overflowing_sub(self.a, v)

    half_carry := ((self.a & 0xf) - (v & 0xf)) & 0x10 == 0x10

    self.a = res

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, true)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

xor_a_r8 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    v := get_r8(self, register)^

    self.a ~= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)
    set_carry_flag(&self.regs, false)
}

xor_a_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := memory.read(mem, get_hl(&self.regs))

    self.a ~= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)
    set_carry_flag(&self.regs, false)
}

xor_a_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    v := next_byte(self, mem)

    self.a ~= v

    set_zero_flag(&self.regs, self.a == 0)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, false)
    set_carry_flag(&self.regs, false)
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
    case .SP:
        v1 = self.sp
    }

    v2: u16
    #partial switch r2 {
    case .BC:
        v2 = get_bc(&self.regs)
    case .DE:
        v2 = get_de(&self.regs)
    case .HL:
        v2 = get_hl(&self.regs)
    case .SP:
        v2 = self.sp
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
    case .SP:
        self.sp = res
    }

    // - 0 H C
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)
}

//// ---- Bit Operations Instructions -------------------------------------------------

bit_u3_r8 :: proc() {}
bit_u3_hl :: proc() {}
res_u3_r8 :: proc() {}
res_u3_hl :: proc() {}
set_u3_r8 :: proc() {}
set_u3_hl :: proc() {}
swap_r8 :: proc() {}
swap_hl :: proc() {}

//// ---- Bit Shift Instructions ------------------------------------------------------

rl_r8 :: proc() {}
rl_hl :: proc() {}
rla :: proc() {}
rlc_r8 :: proc() {}
rlc_hl :: proc() {}

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

rr_r8 :: proc() {}
rr_hl :: proc() {}
rra :: proc() {}
rrc_r8 :: proc() {}
rrc_hl :: proc() {}

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

sla_r8 :: proc() {}
sla_hl :: proc() {}
sra_r8 :: proc() {}
sra_hl :: proc() {}
srl_r8 :: proc() {}
srl_hl :: proc() {}

//// ---- Load Instructions -----------------------------------------------------------

// Load value n8 into register r8.
ld_r8_r8 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register, r2: Register) {
    reg1 := get_r8(self, r1)
    reg2 := get_r8(self, r2)

    reg1^ = reg2^
}

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
        self.sp = next_word(self, mem)
    }
}

ld_hl_r8 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    reg := get_r8(self, r1)
    addr := get_hl(&self.regs)
    memory.write(mem, addr, reg^)
}

ld_hl_n8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    value := next_byte(self, mem)
    addr := get_hl(&self.regs)
    memory.write(mem, addr, value)
}

ld_r8_hl :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    reg := get_r8(self, r1)

    addr := get_hl(&self.regs)
    value := memory.read(mem, addr)

    reg^ = value
}

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

ld_n16_a :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = next_word(self, mem)
    memory.write(mem, addr, self.a)
}

ldh_n16_a :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)next_byte(self, mem)
    memory.write(mem, addr, self.a)
}

ldh_c_a :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)self.c
    memory.write(mem, addr, self.a)
}

// Load value in register A from the byte pointed to by register r16.
ld_a_r16 :: proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    #partial switch r1 {
    case .BC:
        addr := get_bc(&self.regs)
        val := memory.read(mem, addr)
        self.a = val
    case .DE:
        addr := get_de(&self.regs)
        val := memory.read(mem, addr)
        self.a = val
    case .HL:
        addr := get_hl(&self.regs)
        val := memory.read(mem, addr)
        self.a = val
    }
}

ld_a_n16 :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr := next_word(self, mem)
    self.a = memory.read(mem, addr)
}

ldh_a_n16 :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)next_byte(self, mem)
    self.a = memory.read(mem, addr)
}

ldh_a_c :: proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)self.c
    self.a = memory.read(mem, addr)
}

// Store value in register A into the byte pointed by HL and increment HL afterwards.
ld_hli_a :: proc(self: ^CPU, mem: ^memory.Memory) {
    ld_r16_a(self, mem, .HL)
    inc_r16(self, mem, .HL)
}

ld_hld_a :: proc(self: ^CPU, mem: ^memory.Memory) {
    ld_r16_a(self, mem, .HL)
    dec_r16(self, mem, .HL)
}

ld_a_hli :: proc(self: ^CPU, mem: ^memory.Memory) {
    ld_a_r16(self, mem, .HL)
    inc_r16(self, mem, .HL)
}

ld_a_hld :: proc(self: ^CPU, mem: ^memory.Memory) {
    ld_a_r16(self, mem, .HL)
    dec_r16(self, mem, .HL)
}

//// ---- Jumps and Subroutines -------------------------------------------------------

jr_n16 :: proc(self: ^CPU, mem: ^memory.Memory) {
    //TODO: There might be a better way to do the addition than doing all this casting
    addr := transmute(i8)next_byte(self, mem)
    self.pc = cast(u16)(cast(i32)self.pc + cast(i32)addr)
}

jr_cc_n16 :: proc() {}

//// ---- Stack Operations Instructions -----------------------------------------------

add_hl_sp :: proc() {}

add_sp_e8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    value := cast(u16)cast(i16)transmute(i8)next_byte(self, mem)
    result, _ := bits.overflowing_add(self.sp, value)

    half_carry_mask: u16 = 0xF
    half_carry :=
        (self.sp & half_carry_mask) + (value & half_carry_mask) > half_carry_mask

    carry_mask: u16 = 0xff
    carry := (self.sp & carry_mask) + (value & carry_mask) > carry_mask

    set_zero_flag(&self.regs, false)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)

    self.sp = result
}

dec_sp :: proc() {}
inc_sp :: proc() {}
ld_sp_n16 :: proc() {}

ld_n16_sp :: proc(self: ^CPU, mem: ^memory.Memory) {
    // Store SP & $FF at address n16 and SP >> 8 at address n16 + 1.
    addr := next_word(self, mem)
    a := cast(u8)(self.sp & 0xFF)
    b := cast(u8)(self.sp >> 8)
    memory.write(mem, addr, a)
    memory.write(mem, addr + 1, b)
}

ld_hl_sp_e8 :: proc(self: ^CPU, mem: ^memory.Memory) {
    value := cast(u16)cast(i16)transmute(i8)next_byte(self, mem)
    result, _ := bits.overflowing_add(self.sp, value)

    half_carry_mask: u16 = 0xF
    half_carry :=
        (self.sp & half_carry_mask) + (value & half_carry_mask) > half_carry_mask

    carry_mask: u16 = 0xff
    carry := (self.sp & carry_mask) + (value & carry_mask) > carry_mask

    set_zero_flag(&self.regs, false)
    set_sub_flag(&self.regs, false)
    set_half_carry_flag(&self.regs, half_carry)
    set_carry_flag(&self.regs, carry)

    set_hl(&self.regs, result)
}

ld_sp_hl :: proc(self: ^CPU, mem: ^memory.Memory) {
    self.sp = get_hl(&self.regs)
}

pop_af :: proc(self: ^CPU, mem: ^memory.Memory) {
    self.f = memory.read(mem, self.sp) & 0b1111_0000
    self.sp += 1

    self.a = memory.read(mem, self.sp)
    self.sp += 1
}


pop_r16 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
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

push_af :: proc(self: ^CPU, mem: ^memory.Memory) {
    // dec sp
    // ld [sp], a
    // dec sp
    // ld [sp], flag_Z << 7 | flag_N << 6 | flag_H << 5 | flag_C << 4

    self.sp -= 1
    memory.write(mem, self.sp, self.a)

    self.sp -= 1
    memory.write(mem, self.sp, self.f)

}
push_r16 :: proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
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


//// ---- Miscellaneous Instructions --------------------------------------------------

// JR_cc_n16 :: proc(self: ^CPU, condition: bool, address: u16) {
//     if condition {
//         self.pc = address
//     }
// }
