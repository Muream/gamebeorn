package cpu

import "core:math/bits"

import "../memory"

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

    set_zero_flag(self, false)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)

    set_carry_flag(self, carry)
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

    set_zero_flag(self, false)
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, carry)

}

sla_r8 :: proc() {}
sla_hl :: proc() {}
sra_r8 :: proc() {}
sra_hl :: proc() {}
srl_r8 :: proc() {}
srl_hl :: proc() {}
