package cpu

import "core:fmt"
import "core:log"

import "../memory"

CPU :: struct {
    using regs: Registers,
    ime:        ImeState,
}

ImeState :: enum {
    Disabled,
    Enabled,
    ToEnable,
}

init :: proc() -> CPU {
    log.debug("Init CPU")
    cpu := CPU{{pc = 0x0100}, .Disabled}
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

    if self.ime == .ToEnable {
        self.ime = .Enabled
    }

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
        add_r16_r16(self, mem, .HL, .BC)
        return 2

    // LD A, [BC]
    case 0x0A:
        ld_a_r16(self, mem, .BC)
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
        jr_n16(self, mem)
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
        ld_r8_n8(self, mem, .E)
        return 2

    // TODO:
    // // RRA
    // case 0x1F:

    // JR NZ, e8
    case 0x20:
        taken := jr_cc_n16(self, mem, .NZ)
        return 3 if taken else 2

    // LD HL, n16
    case 0x21:
        ld_r16_n16(self, mem, .HL)
        return 3

    // LD [HL+], A
    case 0x22:
        ld_hli_a(self, mem)
        return 2

    // INC HL
    case 0x23:
        inc_r16(self, mem, .HL)
        return 2

    // INC H
    case 0x24:
        inc_r8(self, mem, .H)
        return 1

    // DEC H
    case 0x25:
        dec_r8(self, mem, .H)
        return 1

    // LD H, n8
    case 0x26:
        ld_r8_n8(self, mem, .H)
        return 1

    // TODO:
    // // DAA
    // case 0x27:
    //     daa()
    //     return 1

    // JR Z, e8
    case 0x28:
        taken := jr_cc_n16(self, mem, .Z)
        return 3 if taken else 2

    // ADD HL, HL
    case 0x29:
        add_r16_r16(self, mem, .HL, .HL)
        return 2

    // LD A, [HL+]
    case 0x2A:
        ld_a_hli(self, mem)
        return 2

    // DEC HL
    case 0x2B:
        dec_r16(self, mem, .HL)
        return 2

    // INC L
    case 0x2C:
        inc_r8(self, mem, .L)
        return 1

    // DEC L
    case 0x2D:
        dec_r8(self, mem, .L)
        return 1

    // LD L, n8
    case 0x2E:
        ld_r8_n8(self, mem, .L)
        return 2

    // // TODO:
    // // CPL
    // case 0x2F:
    //     return 1

    // JR NC, e8
    case 0x30:
        jr_cc_n16(self, mem, .NC)
        return 1

    // LD SP, n16
    case 0x31:
        ld_r16_n16(self, mem, .SP)
        return 4

    // LD [HL-], A
    case 0x32:
        ld_hld_a(self, mem)
        return 4

    // INC SP
    case 0x33:
        inc_r16(self, mem, .SP)
        return 2

    //  INC [HL]
    case 0x34:
        inc_hl(self, mem)
        return 4

    //  DEC [HL]
    case 0x35:
        dec_hl(self, mem)
        return 4

    // LD [HL], n8
    case 0x36:
        ld_hl_n8(self, mem)
        return 4

    // SCF
    case 0x37:
        return 1

    // JR C, e8
    case 0x38:
        return 1

    // ADD HL, SP
    case 0x39:
        add_r16_r16(self, mem, .HL, .SP)
        return 2

    // LD A, [HL-]
    case 0x3A:
        ld_a_hld(self, mem)
        return 2

    // DEC SP
    case 0x3B:
        dec_r16(self, mem, .SP)
        return 2

    // INC A
    case 0x3C:
        inc_r8(self, mem, .A)
        return 1

    // DEC A
    case 0x3D:
        dec_r8(self, mem, .A)
        return 1

    // LD A, n8
    case 0x3E:
        ld_r8_n8(self, mem, .A)
        return 2

    // TODO:
    // // CCF
    // case 0x3F:
    //     return 1

    // LD B, B
    case 0x40:
        ld_r8_r8(self, mem, .B, .B)
        return 1

    // LD B, C
    case 0x41:
        ld_r8_r8(self, mem, .B, .C)
        return 1

    // LD B, D
    case 0x42:
        ld_r8_r8(self, mem, .B, .D)
        return 1

    // LD B, E
    case 0x43:
        ld_r8_r8(self, mem, .B, .E)
        return 1

    // LD B, H
    case 0x44:
        ld_r8_r8(self, mem, .B, .H)
        return 1

    // LD B, L
    case 0x45:
        ld_r8_r8(self, mem, .B, .L)
        return 1

    // LD B, [HL]
    case 0x46:
        ld_r8_hl(self, mem, .B)
        return 2

    // LD B, A
    case 0x47:
        ld_r8_r8(self, mem, .B, .A)
        return 1

    // LD C, B
    case 0x48:
        ld_r8_r8(self, mem, .C, .B)
        return 1

    // LD C, C
    case 0x49:
        ld_r8_r8(self, mem, .C, .C)
        return 1

    // LD C, D
    case 0x4A:
        ld_r8_r8(self, mem, .C, .D)
        return 1

    // LD C, E
    case 0x4B:
        ld_r8_r8(self, mem, .C, .E)
        return 1

    // LD C, H
    case 0x4C:
        ld_r8_r8(self, mem, .C, .H)
        return 1

    // LD C, L
    case 0x4D:
        ld_r8_r8(self, mem, .C, .L)
        return 1

    // LD C, [HL]
    case 0x4E:
        ld_r8_hl(self, mem, .C)
        return 2

    // LD C, A
    case 0x4F:
        ld_r8_r8(self, mem, .C, .A)
        return 1

    // LD D, B
    case 0x50:
        ld_r8_r8(self, mem, .D, .B)
        return 1

    // LD D, C
    case 0x51:
        ld_r8_r8(self, mem, .D, .C)
        return 1

    // LD D, D
    case 0x52:
        ld_r8_r8(self, mem, .D, .D)
        return 1

    // LD D, E
    case 0x53:
        ld_r8_r8(self, mem, .D, .E)
        return 1

    // LD D, H
    case 0x54:
        ld_r8_r8(self, mem, .D, .H)
        return 1

    // LD D, L
    case 0x55:
        ld_r8_r8(self, mem, .D, .L)
        return 1

    // LD D, [HL]
    case 0x56:
        ld_r8_hl(self, mem, .D)
        return 2

    // LD D, A
    case 0x57:
        ld_r8_r8(self, mem, .D, .A)
        return 1

    // LD E, B
    case 0x58:
        ld_r8_r8(self, mem, .E, .B)
        return 1

    // LD E, C
    case 0x59:
        ld_r8_r8(self, mem, .E, .C)
        return 1

    // LD E, D
    case 0x5A:
        ld_r8_r8(self, mem, .E, .D)
        return 1

    // LD E, E
    case 0x5B:
        ld_r8_r8(self, mem, .E, .E)
        return 1

    // LD E, H
    case 0x5C:
        ld_r8_r8(self, mem, .E, .H)
        return 1

    // LD E, L
    case 0x5D:
        ld_r8_r8(self, mem, .E, .L)
        return 1

    // LD E, [HL]
    case 0x5E:
        ld_r8_hl(self, mem, .E)
        return 2

    // LD E, A
    case 0x5F:
        ld_r8_r8(self, mem, .E, .A)
        return 1

    // LD H, B
    case 0x60:
        ld_r8_r8(self, mem, .H, .B)
        return 1

    // LD H, C
    case 0x61:
        ld_r8_r8(self, mem, .H, .C)
        return 1

    // LD H, D
    case 0x62:
        ld_r8_r8(self, mem, .H, .D)
        return 1

    // LD H, E
    case 0x63:
        ld_r8_r8(self, mem, .H, .E)
        return 1

    // LD H, H
    case 0x64:
        ld_r8_r8(self, mem, .H, .H)
        return 1

    // LD H, L
    case 0x65:
        ld_r8_r8(self, mem, .H, .L)
        return 1

    // LD H, [HL]
    case 0x66:
        ld_r8_hl(self, mem, .H)
        return 2

    // LD H, A
    case 0x67:
        ld_r8_r8(self, mem, .H, .A)
        return 1

    // LD L, B
    case 0x68:
        ld_r8_r8(self, mem, .L, .B)
        return 1

    // LD L, C
    case 0x69:
        ld_r8_r8(self, mem, .L, .C)
        return 1

    // LD L, D
    case 0x6A:
        ld_r8_r8(self, mem, .L, .D)
        return 1

    // LD L, E
    case 0x6B:
        ld_r8_r8(self, mem, .L, .E)
        return 1

    // LD L, H
    case 0x6C:
        ld_r8_r8(self, mem, .L, .H)
        return 1

    // LD L, L
    case 0x6D:
        ld_r8_r8(self, mem, .L, .L)
        return 1

    // LD L, [HL]
    case 0x6E:
        ld_r8_hl(self, mem, .L)
        return 2

    // LD L, A
    case 0x6F:
        ld_r8_r8(self, mem, .L, .A)
        return 1

    // LD [HL], B
    case 0x70:
        ld_hl_r8(self, mem, .B)
        return 1

    // LD [HL], C
    case 0x71:
        ld_hl_r8(self, mem, .C)
        return 1

    // LD [HL], D
    case 0x72:
        ld_hl_r8(self, mem, .D)
        return 1

    // LD [HL], E
    case 0x73:
        ld_hl_r8(self, mem, .E)
        return 1

    // LD [HL], H
    case 0x74:
        ld_hl_r8(self, mem, .H)
        return 1

    // LD [HL], L
    case 0x75:
        ld_hl_r8(self, mem, .L)
        return 1

    // // TODO:
    // // HALT
    // case 0x76:
    //     return 1

    // LD [HL], A
    case 0x77:
        ld_hl_r8(self, mem, .A)
        return 1

    // LD A, B
    case 0x78:
        ld_r8_r8(self, mem, .A, .B)
        return 1

    // LD A, C
    case 0x79:
        ld_r8_r8(self, mem, .A, .C)
        return 1

    // LD A, D
    case 0x7A:
        ld_r8_r8(self, mem, .A, .D)
        return 1

    // LD A, E
    case 0x7B:
        ld_r8_r8(self, mem, .A, .E)
        return 1

    // LD A, H
    case 0x7C:
        ld_r8_r8(self, mem, .A, .H)
        return 1

    // LD A, L
    case 0x7D:
        ld_r8_r8(self, mem, .A, .L)
        return 1

    // LD A, [HL]
    case 0x7E:
        ld_r8_hl(self, mem, .A)
        return 2

    // LD A, A
    case 0x7F:
        ld_r8_r8(self, mem, .A, .A)
        return 1

    // ADD A, B
    case 0x80:
        add_a_r8(self, mem, .B)
        return 1

    // ADD A, C
    case 0x81:
        add_a_r8(self, mem, .C)
        return 1

    // ADD A, D
    case 0x82:
        add_a_r8(self, mem, .D)
        return 1

    // ADD A, E
    case 0x83:
        add_a_r8(self, mem, .E)
        return 1

    // ADD A, H
    case 0x84:
        add_a_r8(self, mem, .H)
        return 1

    // ADD A, L
    case 0x85:
        add_a_r8(self, mem, .L)
        return 1

    // ADD A, [HL]
    case 0x86:
        add_a_hl(self, mem)
        return 2

    // ADD A, A
    case 0x87:
        add_a_r8(self, mem, .A)
        return 1

    // ADC A, B
    case 0x88:
        adc_a_r8(self, mem, .B)
        return 1

    // ADC A, C
    case 0x89:
        adc_a_r8(self, mem, .C)
        return 1

    // ADC A, D
    case 0x8A:
        adc_a_r8(self, mem, .D)
        return 1

    // ADC A, E
    case 0x8B:
        adc_a_r8(self, mem, .E)
        return 1

    // ADC A, H
    case 0x8C:
        adc_a_r8(self, mem, .H)
        return 1

    // ADC A, L
    case 0x8D:
        adc_a_r8(self, mem, .L)
        return 1

    // ADC A, [HL]
    case 0x8E:
        adc_a_hl(self, mem)
        return 2

    // ADC A, A
    case 0x8F:
        adc_a_r8(self, mem, .A)
        return 1

    // SUB A, B
    case 0x90:
        sub_a_r8(self, mem, .B)
        return 1

    // SUB A, C
    case 0x91:
        sub_a_r8(self, mem, .C)
        return 1

    // SUB A, D
    case 0x92:
        sub_a_r8(self, mem, .D)
        return 1

    // SUB A, E
    case 0x93:
        sub_a_r8(self, mem, .E)
        return 1

    // SUB A, H
    case 0x94:
        sub_a_r8(self, mem, .H)
        return 1

    // SUB A, L
    case 0x95:
        sub_a_r8(self, mem, .L)
        return 1

    // SUB A, [HL]
    case 0x96:
        sub_a_hl(self, mem)
        return 2

    // SUB A, A
    case 0x97:
        sub_a_r8(self, mem, .A)
        return 1

    // SBC A, B
    case 0x98:
        sbc_a_r8(self, mem, .B)
        return 1

    // SBC A, C
    case 0x99:
        sbc_a_r8(self, mem, .C)
        return 1

    // SBC A, D
    case 0x9a:
        sbc_a_r8(self, mem, .D)
        return 1

    // SBC A, E
    case 0x9b:
        sbc_a_r8(self, mem, .E)
        return 1

    // SBC A, H
    case 0x9c:
        sbc_a_r8(self, mem, .H)
        return 1

    // SBC A, L
    case 0x9d:
        sbc_a_r8(self, mem, .L)
        return 1

    // SBC A, [HL]
    case 0x9e:
        sbc_a_hl(self, mem)
        return 2

    // SBC A, A
    case 0x9f:
        sbc_a_r8(self, mem, .A)
        return 1

    // AND A, B
    case 0xA0:
        and_a_r8(self, mem, .B)
        return 1

    // AND A, C
    case 0xA1:
        and_a_r8(self, mem, .C)
        return 1

    // AND A, D
    case 0xA2:
        and_a_r8(self, mem, .D)
        return 1

    // AND A, E
    case 0xA3:
        and_a_r8(self, mem, .E)
        return 1

    // AND A, H
    case 0xA4:
        and_a_r8(self, mem, .H)
        return 1

    // AND A, L
    case 0xA5:
        and_a_r8(self, mem, .L)
        return 1

    // AND A, [HL]
    case 0xA6:
        and_a_hl(self, mem)
        return 1

    // AND A, A
    case 0xA7:
        and_a_r8(self, mem, .A)
        return 1

    // XOR A, B
    case 0xA8:
        xor_a_r8(self, mem, .B)
        return 1

    // XOR A, C
    case 0xA9:
        xor_a_r8(self, mem, .C)
        return 1

    // XOR A, D
    case 0xAA:
        xor_a_r8(self, mem, .D)
        return 1

    // XOR A, E
    case 0xAB:
        xor_a_r8(self, mem, .E)
        return 1

    // XOR A, H
    case 0xAC:
        xor_a_r8(self, mem, .H)
        return 1

    // XOR A, L
    case 0xAD:
        xor_a_r8(self, mem, .L)
        return 1

    // XOR A, [HL]
    case 0xAE:
        xor_a_hl(self, mem)
        return 1

    // XOR A, A
    case 0xAF:
        xor_a_r8(self, mem, .A)
        return 1

    // OR A, B
    case 0xB0:
        or_a_r8(self, mem, .B)
        return 1

    // OR A, C
    case 0xB1:
        or_a_r8(self, mem, .C)
        return 1

    // OR A, D
    case 0xB2:
        or_a_r8(self, mem, .D)
        return 1

    // OR A, E
    case 0xB3:
        or_a_r8(self, mem, .E)
        return 1

    // OR A, H
    case 0xB4:
        or_a_r8(self, mem, .H)
        return 1

    // OR A, L
    case 0xB5:
        or_a_r8(self, mem, .L)
        return 1

    // OR A, [HL]
    case 0xB6:
        or_a_hl(self, mem)
        return 2

    // OR A, A
    case 0xB7:
        or_a_r8(self, mem, .A)
        return 1

    // CP A, B
    case 0xB8:
        cp_a_r8(self, mem, .B)
        return 1

    // CP A, C
    case 0xB9:
        cp_a_r8(self, mem, .C)
        return 1

    // CP A, D
    case 0xBA:
        cp_a_r8(self, mem, .D)
        return 1

    // CP A, E
    case 0xBB:
        cp_a_r8(self, mem, .E)
        return 1

    // CP A, H
    case 0xBC:
        cp_a_r8(self, mem, .H)
        return 1

    // CP A, L
    case 0xBD:
        cp_a_r8(self, mem, .L)
        return 1

    // CP A, [HL]
    case 0xBE:
        cp_a_hl(self, mem)
        return 1

    // CP A, A
    case 0xBF:
        cp_a_r8(self, mem, .A)
        return 1

    // RET NZ
    case 0xC0:
        ret_cc(self, mem, .NZ)
        return 5

    // POP BC
    case 0xC1:
        pop_r16(self, mem, .BC)
        return 3

    // JP NZ, a16
    case 0xC2:
        jp_cc_n16(self, mem, .NZ)
        return 4

    // JP a16
    case 0xC3:
        jp_n16(self, mem)
        return 4

    // CALL NZ, a16
    case 0xC4:
        call_cc_n16(self, mem, .NZ)
        return 6

    // PUSH BC
    case 0xC5:
        push_r16(self, mem, .BC)
        return 4

    // ADD A,n8
    case 0xC6:
        add_a_n8(self, mem)
        return 2

    // RST $00 
    case 0xC7:
        rst_vec(self, mem, 0x00)
        return 4

    // RET Z
    case 0xC8:
        ret_cc(self, mem, .Z)
        return 5

    // RET
    case 0xC9:
        ret(self, mem)
        return 4

    // JP Z,a16
    case 0xCA:
        jp_cc_n16(self, mem, .Z)
        return 4

    // TODO:
    // // PREFIX
    // case 0xCB:
    //     return 1

    // CALL Z,a16
    case 0xCC:
        call_cc_n16(self, mem, .Z)
        return 6

    // CALL a16
    case 0xCD:
        call_n16(self, mem)
        return 6

    // ADC A,n8
    case 0xCE:
        adc_a_n8(self, mem)
        return 2

    // RST $08
    case 0xCF:
        rst_vec(self, mem, 0x08)
        return 4

    // RET NC
    case 0xD0:
        ret_cc(self, mem, .NC)
        return 5

    // POP DE
    case 0xD1:
        pop_r16(self, mem, .DE)
        return 3

    // JP NC, a16
    case 0xD2:
        jp_cc_n16(self, mem, .NC)
        return 4

    // ILLEGAL_D3
    case 0xD3:
        panic("Illegal Instruction: 0xD3")

    // CALL NC, a16
    case 0xD4:
        call_cc_n16(self, mem, .NC)
        return 6

    // PUSH DE 
    case 0xD5:
        push_r16(self, mem, .DE)
        return 4

    // SUB A, n8
    case 0xD6:
        sub_a_n8(self, mem)
        return 2

    // RST $10
    case 0xD7:
        rst_vec(self, mem, 0x10)
        return 4

    // RET C 
    case 0xD8:
        ret_cc(self, mem, .C)
        return 5

    // RETI
    case 0xD9:
        reti(self, mem)
        return 4

    // JP C, a16
    case 0xDA:
        jp_cc_n16(self, mem, .C)
        return 4

    // ILLEGAL_DB
    case 0xDB:
        panic("Illegal Instruction: 0xDB")

    //  CALL C, a16 
    case 0xDC:
        call_cc_n16(self, mem, .C)
        return 6

    // ILLEGAL_DD
    case 0xDD:
        panic("Illegal Instruction: 0xDD")

    // SBC A, n8
    case 0xDE:
        sbc_a_n8(self, mem)
        return 2

    // RST $18
    case 0xDF:
        rst_vec(self, mem, 0x18)
        return 4

    // LDH [a8], A
    case 0xE0:
        ldh_n16_a(self, mem)
        return 3

    // POP HL
    case 0xE1:
        pop_r16(self, mem, .HL)
        return 3

    // LDH [C], A
    case 0xE2:
        ldh_c_a(self, mem)
        return 2

    // ILLEGAL_E3
    case 0xE3:
        panic("Illegal Instruction: 0xE3")

    // ILLEGAL_E4
    case 0xE4:
        panic("Illegal Instruction: 0xE4")

    // PUSH HL
    case 0xE5:
        push_r16(self, mem, .HL)
        return 4

    // AND A, n8
    case 0xE6:
        and_a_n8(self, mem)
        return 2

    // RST $20
    case 0xE7:
        rst_vec(self, mem, 0x20)
        return 4

    // ADD SP, e8
    case 0xE8:
        add_sp_e8(self, mem)
        return 4

    // JP HL
    case 0xE9:
        jp_hl(self, mem)
        return 1

    // LD [a16], A
    case 0xEA:
        ld_n16_a(self, mem)
        return 4

    // ILLEGAL_EB
    case 0xEB:
        panic("Illegal Instruction: 0xEB")

    // ILLEGAL_EC
    case 0xEC:
        panic("Illegal Instruction: 0xEC")

    // ILLEGAL_ED
    case 0xED:
        panic("Illegal Instruction: 0xED")

    // XOR A, n8
    case 0xEE:
        xor_a_n8(self, mem)
        return 2

    // RST $28
    case 0xEF:
        rst_vec(self, mem, 0x28)
        return 4

    // LDH A, [a8]
    case 0xF0:
        ldh_a_n16(self, mem)
        return 3

    // POP AF
    case 0xF1:
        pop_af(self, mem)
        return 3

    // LDH A, [C]
    case 0xF2:
        ldh_a_c(self, mem)
        return 2

    // TODO:
    // // DI
    // case 0xF3:
    //     return 1

    // ILLEGAL_F4
    case 0xF4:
        panic("Illegal Instruction: 0xF4")

    // PUSH AF 
    case 0xF5:
        push_af(self, mem)
        return 4

    // OR A, n8
    case 0xF6:
        or_a_n8(self, mem)
        return 2

    // RST $30
    case 0xF7:
        rst_vec(self, mem, 0x30)
        return 4

    // LD HL, SP + e8
    case 0xF8:
        ld_hl_sp_e8(self, mem)
        return 3

    // LD SP, HL
    case 0xF9:
        ld_sp_hl(self, mem)
        return 2

    // LD A, [a16]
    case 0xFA:
        ld_a_n16(self, mem)
        return 4

    // EI
    case 0xFB:
        ei(self)
        return 1

    // ILLEGAL_FC
    case 0xFC:
        panic("Illegal Instruction: 0xFC")

    // ILLEGAL_FD
    case 0xFD:
        panic("Illegal Instruction: 0xFD")

    // CP
    case 0xFE:
        cp_a_n8(self, mem)
        return 2

    // RST $38
    case 0xFF:
        rst_vec(self, mem, 0x38)
        return 4

    case:
        fmt.panicf("Unknown Opcode: 0x{:02X} @ 0x{:04X}", opcode, self.regs.pc - 1)
    }
}
