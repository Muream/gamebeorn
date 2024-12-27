package cpu

import "core:fmt"
import "core:log"

import "../memory"

CPU :: struct {
    using regs: Registers,
    ime:        bool,
}

init :: proc() -> CPU {
    log.debug("Init CPU")
    cpu := CPU{{pc = 0x0100}, false}
    return cpu
}

next_byte :: proc(self: ^CPU, mem: ^memory.Memory) -> u8 {
    b := memory.read(mem, self.regs.pc)
    self.regs.pc += 1
    return b
}

next_word :: proc(self: ^CPU, mem: ^memory.Memory) -> u16 {
    a := cast(u16)next_byte(self, mem)
    b := cast(u16)next_byte(self, mem)
    addr := (b << 8) | a
    return addr
}


step :: proc(self: ^CPU, mem: ^memory.Memory) -> uint {

    op_addr := self.regs.pc
    opcode := next_byte(self, mem)

    log.debugf("PC: 0x%08X, OP: 0x%02X", op_addr, opcode)

    switch opcode {

    // NOP
    case 0x00:
        log.debug("NOP")
        return 4

    //JP a16
    case 0xC3:
        log.debug("JP a16 3  16 ")
        addr := next_word(self, mem)
        self.regs.pc = addr
        return 4

    // DI
    case 0xF3:
        self.ime = false
        return 1

    // // JR NC, e8 
    // case 0x30:
    //     offset_addr := transmute(i8)next_byte(self, mem) // FIXME: I this correct?
    //     addr := cast(u16)(cast(i16)self.regs.pc + cast(i16)offset_addr) // FIXME: I this correct?
    //     self.regs.pc = addr
    //     return 3

    //LD SP, n16
    case 0x31:
        val := next_word(self, mem)
        self.regs.sp = val
        return 3

    // LD A, n8
    case 0x3A:
        val := next_byte(self, mem)
        self.regs.a = val
        return 4

    // LD [a16], A
    case 0xEA:
        val := self.regs.a
        addr := next_word(self, mem)
        memory.write(mem, addr, val)
        return 4

    // LD A, n8 
    case 0x3E:
        val := next_byte(self, mem)
        self.regs.a = val
        return 4

    // LDH [a8], A 
    case 0xE0:
        val := self.regs.a
        addr := 0xFF00 + cast(u16)next_byte(self, mem) // FIXME: Is this how the byte should be added?
        memory.write(mem, addr, val)

        return 4
    case:
        fmt.panicf("Unknown Opcode: 0x{:02X} @ 0x{:04X}", opcode, self.regs.pc - 1)
    }
}
