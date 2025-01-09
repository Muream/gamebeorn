package cpu

import "../memory"

ccf :: #force_inline proc(self: ^CPU) {
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, !get_carry_flag(self))
}

cpl :: #force_inline proc(self: ^CPU) {
    self.a = ~self.a
    set_sub_flag(self, true)
    set_half_carry_flag(self, true)
}

daa :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    if get_sub_flag(self) {
        adj: u8 = 0
        if get_half_carry_flag(self) {adj += 0x6}
        if get_carry_flag(self) {adj += 0x60}
        self.a -= adj
    } else {
        adj: u8 = 0
        if get_half_carry_flag(self) || self.a & 0xF > 0x9 {adj += 0x6}
        if get_carry_flag(self) || self.a > 0x99 {
            adj += 0x60
            set_carry_flag(self, true)
        }

        self.a += adj
    }

    set_zero_flag(self, self.a == 0)
    set_half_carry_flag(self, false)
}

di :: #force_inline proc(self: ^CPU) {
    self.ime = .Disabled
}

ei :: #force_inline proc(self: ^CPU) {
    if self.ime == .Disabled {
        self.ime = .ToEnable
    }
}

halt :: #force_inline proc() {}
nop :: #force_inline proc() {}

scf :: #force_inline proc(self: ^CPU) {
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, true)
}

stop :: #force_inline proc() {}
