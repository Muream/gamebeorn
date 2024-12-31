package cpu

ccf :: proc() {}
cpl :: proc() {}
daa :: proc() {}
di :: proc() {}

ei :: proc(self: ^CPU) {
    if self.ime == .Disabled {
        self.ime = .ToEnable
    }
}

halt :: proc() {}
nop :: proc() {}
scf :: proc() {}
stop :: proc() {}
