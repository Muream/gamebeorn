package cpu

import "base:intrinsics"
import "core:fmt"
import "core:log"
import "core:math/bits"

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
        return 4

    // LD BC, n16
    case 0x01:
        ld_r16_n16(self, mem, .BC)
        return 3

    // LD [BC], A
    case 0x02:
        ld_r16_a(self, mem, .BC)
        return 2

    // INC BC
    case 0x03:
        inc_r16(self, mem, .BC)
        return 2

    // INC B 
    case 0x04:
        inc_r8(self, mem, .B)
        return 1

    // DEC B 
    case 0x05:
        dec_r8(self, mem, .B)
        return 1

    // LD B, n8
    case 0x06:
        ld_r8_n8(self, mem, .B)
        return 2

    // RLCA
    case 0x07:
        rlca(self, mem)
        return 1

    // LD [a16], SP
    case 0x08:
        ld_n16_sp(self, mem)
        return 5

    // ADD HL, BC 
    case 0x09:
        // Add the value in r16 to HL.
        bc := get_bc(&self.regs)
        hl := get_hl(&self.regs)

        res, carry := bits.overflowing_add(bc, hl)

        half_carry := (hl & 0xFFF) > (res & 0xFFF)

        set_hl(&self.regs, cast(u16)(hl + bc))

        // - 0 H C
        set_sub_flag(&self.regs, false)
        set_half_carry_flag(&self.regs, half_carry)
        set_carry_flag(&self.regs, carry)

        return 2

    // LD A, [BC]
    case 0x0A:
        // Load value in register A from the byte pointed to by register r16.
        addr := get_bc(&self.regs)
        val := memory.read(mem, addr)
        self.a = val
        return 2

    // DEC BC
    case 0x0B:
        dec_r16(self, mem, .BC)
        return 2

    // INC C 
    case 0x0C:
        inc_r8(self, mem, .C)
        return 1

    // DEC C 
    case 0x0D:
        dec_r8(self, mem, .C)
        return 1

    // LD C, n8
    case 0x0E:
        ld_r8_n8(self, mem, .C)
        return 2

    // RRCA
    case 0x0F:
        rrca(self, mem)
        return 1

    // STOP
    case 0x10:
        // TODO: should this do something else?
        return 0

    // LD DE, n16 
    case 0x11:
        ld_r16_n16(self, mem, .DE)
        return 3

    // LD [DE], A 
    case 0x12:
        ld_r16_a(self, mem, .DE)
        return 2

    // INC DE
    case 0x13:
        inc_r16(self, mem, .DE)
        return 2

    // INC D
    case 0x14:
        inc_r8(self, mem, .D)
        return 1

    // DEC D 
    case 0x15:
        dec_r8(self, mem, .D)
        return 1

    // LD D, n8
    case 0x16:
        ld_r8_n8(self, mem, .D)
        return 2

    // TODO:
    // // RLA
    // case 0x17:
    //     // The carry flag is set to the leftmost bit of A before the rotate
    //     mask: u8 = 0b1000_0000
    //     carry := self.a & mask == mask
    //
    //     old_carry := cast(u8)(get_carry_flag(&self.regs))
    //
    //     self.a = self.a << 1

    //     log.warnf("C: %08b, A: %08b", old_carry, self.a)
    //     self.a |= old_carry
    //     log.warnf("A: %08b", self.a)

    //     // 0 0 0 C
    //     set_zero_flag(&self.regs, false)
    //     set_sub_flag(&self.regs, false)
    //     set_half_carry_flag(&self.regs, false)
    //     set_carry_flag(&self.regs, carry)

    //     return 1

    // JR e8 
    case 0x18:
        //TODO: There might be a better way to do the addition than doing all this casting
        addr := transmute(i8)next_byte(self, mem)
        self.pc = cast(u16)(cast(i32)self.pc + cast(i32)addr)

        return 3

    // ADD HL, DE 
    case 0x19:
        add_r16_r16(self, mem, .HL, .DE)
        return 2

    // LD A, [DE] 
    case 0x1A:
        ld_a_r16(self, mem, .DE)
        return 2

    // DEC DE 
    case 0x1B:
        dec_r16(self, mem, .DE)
        return 2

    // INC E 
    case 0x1C:
        inc_r8(self, mem, .E)
        return 1

    // DEC E 
    case 0x1D:
        dec_r8(self, mem, .E)
        return 1

    // LD E, n8 
    case 0x1E:
        val := next_byte(self, mem)
        self.e = val
        return 2

    // TODO:
    // // RRA
    // case 0x1F:

    // // JR NZ, e8 
    // case 0x20:


    // //JP a16
    // case 0xC3:
    //     log.debug("JP a16 3  16 ")
    //     addr := next_word(self, mem)
    //     self.regs.pc = addr
    //     return 4

    // // DI
    // case 0xF3:
    //     self.ime = false
    //     return 1

    // // // JR NC, e8 
    // // case 0x30:
    // //     offset_addr := transmute(i8)next_byte(self, mem) // FIXME: I this correct?
    // //     addr := cast(u16)(cast(i16)self.regs.pc + cast(i16)offset_addr) // FIXME: I this correct?
    // //     self.regs.pc = addr
    // //     return 3

    // //LD SP, n16
    // case 0x31:
    //     val := next_word(self, mem)
    //     self.regs.sp = val
    //     return 3

    // // LD A, n8
    // case 0x3A:
    //     val := next_byte(self, mem)
    //     self.regs.a = val
    //     return 4

    // // LD [a16], A
    // case 0xEA:
    //     val := self.regs.a
    //     addr := next_word(self, mem)
    //     memory.write(mem, addr, val)
    //     return 4

    // // LD A, n8 
    // case 0x3E:
    //     val := next_byte(self, mem)
    //     self.regs.a = val
    //     return 4

    // // LDH [a8], A 
    // case 0xE0:
    //     val := self.regs.a
    //     addr := 0xFF00 + cast(u16)next_byte(self, mem) // FIXME: Is this how the byte should be added?
    //     memory.write(mem, addr, val)

    //     return 4
    case:
        fmt.panicf("Unknown Opcode: 0x{:02X} @ 0x{:04X}", opcode, self.regs.pc - 1)
    }

}
// {
//     "name":"05 0000",
//     "initial":  {"a":149, "b":179, "c":99, "d":60, "e":134, "f":176, "h":129, "l":116, "pc":15508, "sp":56720, "ime":0, "ie":1, "ram":[[15508,5]]},
//     "final":    {"a":149, "b":178, "c":99, "d":60, "e":134, "f":80,  "h":129, "l":116, "pc":15509, "sp":56720, "ime":0, "ram":[[15508,5]]},
//     "cycles":[[15508,5,"r-m"]]
// }
