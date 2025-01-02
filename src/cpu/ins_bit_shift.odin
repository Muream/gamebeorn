package cpu

import "core:math/bits"

import "../memory"

// Rotate bits in register r8 left, through the carry flag.
//   ┏━ Flags ━┓ ┏━━━━━━━ r8 ━━━━━━┓
// ┌─╂─   C   ←╂─╂─ b7 ← ... ← b0 ←╂─┐
// │ ┗━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━┛ │
// └─────────────────────────────────┘
rl_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^

    old_carry := cast(u8)get_carry_flag(self)
    carry := v & 0b1000_0000 == 0b1000_0000

    r := (v << 1) | old_carry

    reg^ = r

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)
}


// Rotate the byte pointed to by HL left, through the carry flag.
//   ┏━ Flags ━┓ ┏━━━━━━━ HL^ ━━━━━┓
// ┌─╂─   C   ←╂─╂─ b7 ← ... ← b0 ←╂─┐
// │ ┗━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━┛ │
// └─────────────────────────────────┘
rl_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {

    addr := get_hl(self)
    v := memory.read(mem, addr)

    old_carry := cast(u8)get_carry_flag(self)
    carry := v & 0b1000_0000 == 0b1000_0000

    r := (v << 1) | old_carry

    memory.write(mem, addr, r)

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)
}

rla :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    // The carry flag is set to the leftmost bit of A before the rotate
    mask: u8 = 0b1000_0000
    carry := self.a & mask == mask

    old_carry := cast(u8)(get_carry_flag(self))

    self.a = self.a << 1

    self.a |= old_carry

    // 0 0 0 C
    set_zero_flag(self, false)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)

}


// Rotate register r8 left.
// ┏━ Flags ━┓   ┏━━━━━━━ r8 ━━━━━━┓
// ┃    C   ←╂─┬─╂─ b7 ← ... ← b0 ←╂─┐
// ┗━━━━━━━━━┛ │ ┗━━━━━━━━━━━━━━━━━┛ │
//             └─────────────────────┘
rlc_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^

    carry := v & 0b1000_0000 == 0b1000_0000

    r := bits.rotate_left8(v, 1)

    reg^ = r

    set_zero_flag(self, reg^ == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)
}


// Rotate the byte pointed to by HL left.
// ┏━ Flags ━┓   ┏━━━━━━━ HL^ ━━━━━┓
// ┃    C   ←╂─┬─╂─ b7 ← ... ← b0 ←╂─┐
// ┗━━━━━━━━━┛ │ ┗━━━━━━━━━━━━━━━━━┛ │
//             └─────────────────────┘
rlc_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    v := memory.read(mem, addr)

    carry := v & 0b1000_0000 == 0b1000_0000

    r := bits.rotate_left8(v, 1)
    memory.write(mem, addr, r)

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)
}

rlca :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    rlc_r8(self, mem, .A)
    set_zero_flag(self, false)
}


// Rotate register r8 right, through the carry flag.
//   ┏━━━━━━━ r8 ━━━━━━┓ ┏━ Flags ━┓
// ┌─╂→ b7 → ... → b0 ─╂─╂→   C   ─╂─┐
// │ ┗━━━━━━━━━━━━━━━━━┛ ┗━━━━━━━━━┛ │
// └─────────────────────────────────┘
rr_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    r := rr(self, mem, v)
    reg^ = r
}

// Rotate the byte pointed to by HL right, through the carry flag.
//   ┏━━━━━━━ HL^ ━━━━━┓ ┏━ Flags ━┓
// ┌─╂→ b7 → ... → b0 ─╂─╂→   C   ─╂─┐
// │ ┗━━━━━━━━━━━━━━━━━┛ ┗━━━━━━━━━┛ │
// └─────────────────────────────────┘
rr_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    r := rr(self, mem, v)
    memory.write(mem, addr, r)
}

rra :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    rr_r8(self, mem, .A)
    set_zero_flag(self, false)
}

rr :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, value: u8) -> u8 {
    old_carry := cast(u8)get_carry_flag(self) << 7
    carry := value & 0b0000_0001 == 0b0000_0001

    r := (value >> 1) | old_carry

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)

    return r
}

// Rotate register r8 right.
//   ┏━━━━━━━ r8 ━━━━━━┓   ┏━ Flags ━┓
// ┌─╂→ b7 → ... → b0 ─╂─┬─╂→   C    ┃
// │ ┗━━━━━━━━━━━━━━━━━┛ │ ┗━━━━━━━━━┛
// └─────────────────────┘
rrc_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^

    carry := v & 0b0000_0001 == 0b0000_0001

    r := bits.rotate_left8(v, 7)

    reg^ = r

    set_zero_flag(self, reg^ == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)
}


// Rotate the byte pointed to by HL right.
//   ┏━━━━━━━ HL^ ━━━━━┓   ┏━ Flags ━┓
// ┌─╂→ b7 → ... → b0 ─╂─┬─╂→   C    ┃
// │ ┗━━━━━━━━━━━━━━━━━┛ │ ┗━━━━━━━━━┛
// └─────────────────────┘
rrc_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    v := memory.read(mem, addr)

    carry := v & 0b0000_0001 == 0b0000_0001

    r := bits.rotate_left8(v, 7)
    memory.write(mem, addr, r)

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)
}

rrca :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    rrc_r8(self, mem, .A)
    set_zero_flag(self, false)
}

// Shift Left Arithmetically register r8.
// ┏━ Flags ━┓ ┏━━━━━━━ r8 ━━━━━━┓
// ┃    C   ←╂─╂─ b7 ← ... ← b0 ←╂─ 0
// ┗━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━┛
sla_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    r := sla(self, v)
    reg^ = r
}

// Shift Left Arithmetically the byte pointed to by HL.
// ┏━ Flags ━┓ ┏━━━━━━ HL^ ━━━━━━┓
// ┃    C   ←╂─╂─ b7 ← ... ← b0 ←╂─ 0
// ┗━━━━━━━━━┛ ┗━━━━━━━━━━━━━━━━━┛
sla_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    r := sla(self, v)
    memory.write(mem, addr, r)
}

sra_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    r := sra(self, v)
    reg^ = r
}

sra_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    r := sra(self, v)
    memory.write(mem, addr, r)
}

// Shift Right Logically register r8.
//    ┏━━━━━━━ r8 ━━━━━━┓ ┏━ Flags ━┓
// 0 ─╂→ b7 → ... → b0 ─╂─╂→   C    ┃
//    ┗━━━━━━━━━━━━━━━━━┛ ┗━━━━━━━━━┛
srl_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, register: Register) {
    reg := get_r8(self, register)
    v := reg^
    r := srl(self, v)
    reg^ = r
}

srl_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr := get_hl(self)
    v := memory.read(mem, addr)
    r := srl(self, v)
    memory.write(mem, addr, r)
}


srl :: #force_inline proc(self: ^CPU, value: u8) -> u8 {
    c := value & 0b0000_0001 == 0b0000_0001
    r := value >> 1

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, c)

    return r
}

sla :: #force_inline proc(self: ^CPU, value: u8) -> u8 {
    c := value & 0b1000_0000 == 0b1000_0000
    r := value << 1

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, c)

    return r
}

sra :: #force_inline proc(self: ^CPU, value: u8) -> u8 {
    c := value & 0b0000_0001 == 0b0000_0001
    b7 := value & 0b1000_0000
    r := value >> 1 | b7

    set_zero_flag(self, r == 0)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, c)

    return r
}
