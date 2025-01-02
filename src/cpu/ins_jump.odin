package cpu

import "../memory"

call_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    return_addr := self.pc + 1

    self.sp -= 1
    memory.write(mem, self.sp, cast(u8)(return_addr >> 8))

    self.sp -= 1
    memory.write(mem, self.sp, cast(u8)(return_addr & 0xFF))

    jp_n16(self, mem)

}

call_cc_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, cond: Condition) {
    cond_res := check_condition(self, cond)
    if cond_res {
        call_n16(self, mem)
    } else {
        // Consume the address without jumping
        next_word(self, mem)
    }
}

jp_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    self.pc = get_hl(self)
}

jp_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    self.pc = next_word(self, mem)
}

jp_cc_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, cond: Condition) {
    cond_res := check_condition(self, cond)

    if cond_res {
        jp_n16(self, mem)
    } else {
        // Consume the address without jumping
        next_word(self, mem)
    }
}

jr_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    //TODO: There might be a better way to do the addition than doing all this casting
    addr := transmute(i8)next_byte(self, mem)
    self.pc = cast(u16)(cast(i32)self.pc + cast(i32)addr)
}

jr_cc_n16 :: #force_inline proc(
    self: ^CPU,
    mem: ^memory.Memory,
    cond: Condition,
) -> bool {

    cond_res := check_condition(self, cond)

    if cond_res {
        jr_n16(self, mem)
    } else {
        // Consume the address without jumping
        next_byte(self, mem)
    }

    return cond_res
}

ret_cc :: #force_inline proc(
    self: ^CPU,
    mem: ^memory.Memory,
    cond: Condition,
) -> bool {

    cond_res := check_condition(self, cond)

    if cond_res {
        ret(self, mem)
    }

    return cond_res
}

ret :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    low := memory.read(mem, self.sp)
    self.sp += 1

    high := memory.read(mem, self.sp)
    self.sp += 1

    self.pc = (cast(u16)high << 8) | cast(u16)low
}

reti :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {

    // FIXME: This might not be correct because the ime flag is typically 
    // set after the next instruction
    if self.ime == .Disabled {
        self.ime = .Enabled
    }

    ret(self, mem)
}

rst_vec :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, addr: u16) {
    return_addr := self.pc + 1

    self.sp -= 1
    memory.write(mem, self.sp, cast(u8)(return_addr >> 8))

    self.sp -= 1
    memory.write(mem, self.sp, cast(u8)(return_addr & 0xFF))

    self.pc = addr
    // jp_n16(self, mem)
}
