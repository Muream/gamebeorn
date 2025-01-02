package cpu

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

daa :: #force_inline proc() {}

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
scf :: #force_inline proc() {}
stop :: #force_inline proc() {}
