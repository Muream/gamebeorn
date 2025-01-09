package cpu

import "core:fmt"

import "../memory"

// Load value n8 into register r8.
ld_r8_r8 :: #force_inline proc(
    self: ^CPU,
    mem: ^memory.Memory,
    r1: Register,
    r2: Register,
) {
    reg1 := get_r8(self, r1)
    reg2 := get_r8(self, r2)

    reg1^ = reg2^
}

// Load value n8 into register r8.
ld_r8_n8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    reg := get_r8(self, r1)
    reg^ = next_byte(self, mem)
}

// Load value n16 into register r16.
ld_r16_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
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

ld_hl_r8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    reg := get_r8(self, r1)
    addr := get_hl(self)
    memory.write(mem, addr, reg^)
}

ld_hl_n8 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    value := next_byte(self, mem)
    addr := get_hl(self)
    memory.write(mem, addr, value)
}

ld_r8_hl :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    reg := get_r8(self, r1)

    addr := get_hl(self)
    value := memory.read(mem, addr)

    reg^ = value
}

// Store value in register A into the byte pointed to by register r16.
ld_r16_a :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    addr: u16
    #partial switch r1 {
    case .BC:
        addr = get_bc(self)
    case .DE:
        addr = get_de(self)
    case .HL:
        addr = get_hl(self)
    case:
        fmt.panicf("Invalid Register %v", r1)
    }
    memory.write(mem, addr, self.a)
}

ld_n16_a :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = next_word(self, mem)
    memory.write(mem, addr, self.a)
}

ldh_n16_a :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)next_byte(self, mem)
    memory.write(mem, addr, self.a)
}

ldh_c_a :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)self.c
    memory.write(mem, addr, self.a)
}

// Load value in register A from the byte pointed to by register r16.
ld_a_r16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory, r1: Register) {
    #partial switch r1 {
    case .BC:
        addr := get_bc(self)
        val := memory.read(mem, addr)
        self.a = val
    case .DE:
        addr := get_de(self)
        val := memory.read(mem, addr)
        self.a = val
    case .HL:
        addr := get_hl(self)
        val := memory.read(mem, addr)
        self.a = val
    }
}

ld_a_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr := next_word(self, mem)
    self.a = memory.read(mem, addr)
}

ldh_a_n16 :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)next_byte(self, mem)
    self.a = memory.read(mem, addr)
}

ldh_a_c :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    addr: u16 = 0xFF00 + cast(u16)self.c
    self.a = memory.read(mem, addr)
}

// Store value in register A into the byte pointed by HL and increment HL afterwards.
ld_hli_a :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    ld_r16_a(self, mem, .HL)
    inc_r16(self, mem, .HL)
}

ld_hld_a :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    ld_r16_a(self, mem, .HL)
    dec_r16(self, mem, .HL)
}

ld_a_hli :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    ld_a_r16(self, mem, .HL)
    inc_r16(self, mem, .HL)
}

ld_a_hld :: #force_inline proc(self: ^CPU, mem: ^memory.Memory) {
    ld_a_r16(self, mem, .HL)
    dec_r16(self, mem, .HL)
}
