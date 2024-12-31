package cpu

ccf :: proc(self: ^CPU) {
    set_sub_flag(self, false)
    set_half_carry_flag(self, false)
    set_carry_flag(self, !get_carry_flag(self))
}

cpl :: proc(self: ^CPU) {
    self.a = ~self.a
    set_sub_flag(self, true)
    set_half_carry_flag(self, true)
}

daa :: proc() {}

di :: proc(self: ^CPU) {
    self.ime = .Disabled
}

ei :: proc(self: ^CPU) {
    if self.ime == .Disabled {
        self.ime = .ToEnable
    }
}

halt :: proc() {}
nop :: proc() {}
scf :: proc() {}
stop :: proc() {}
