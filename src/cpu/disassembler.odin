package cpu

import "core:fmt"

import "../memory"

peek_byte :: proc(self: ^CPU, mem: ^memory.Memory) -> u8 {
    return memory.read(mem, self.regs.pc)
}

peek_word :: proc(self: ^CPU, mem: ^memory.Memory) -> u16 {
    a := cast(u16)memory.read(mem, self.regs.pc)
    b := cast(u16)memory.read(mem, self.regs.pc + 1)
    addr := (b << 8) | a
    return addr
}

disassemble_flags :: proc(self: ^CPU) -> string {
    z := "Z" if get_zero_flag(self) else "_"
    n := "N" if get_sub_flag(self) else "_"
    h := "H" if get_half_carry_flag(self) else "_"
    c := "C" if get_carry_flag(self) else "_"
    return fmt.aprintf("%v %v %v %v", z, n, h, c)
}

disassemble :: proc(self: ^CPU, mem: ^memory.Memory, instruction: OpCode) -> string {
    switch _ in instruction {
    case Unprefixed_OpCode:
        return disassemble_unprefixed(self, mem, instruction.(Unprefixed_OpCode))
    case Prefixed_OpCode:
        return disassemble_prefixed(self, mem, instruction.(Prefixed_OpCode))
    case:
        return "INVALID"
    }
}


disassemble_unprefixed :: proc(
    self: ^CPU,
    mem: ^memory.Memory,
    instruction: Unprefixed_OpCode,
) -> string {

    opcode := instruction
    #partial switch opcode {
    case .NOP:
        return fmt.aprintf("%v ", opcode)
    case .LD_BC_n16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .LD_BC_A:
        return fmt.aprintf("%v ", opcode)
    case .INC_BC:
        return fmt.aprintf("%v ", opcode)
    case .INC_B:
        return fmt.aprintf("%v ", opcode)
    case .DEC_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RLCA:
        return fmt.aprintf("%v ", opcode)
    case .LD_a16_SP:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .ADD_HL_BC:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_BC:
        return fmt.aprintf("%v ", opcode)
    case .DEC_BC:
        return fmt.aprintf("%v ", opcode)
    case .INC_C:
        return fmt.aprintf("%v ", opcode)
    case .DEC_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RRCA:
        return fmt.aprintf("%v ", opcode)
    case .STOP_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .LD_DE_n16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .LD_DE_A:
        return fmt.aprintf("%v ", opcode)
    case .INC_DE:
        return fmt.aprintf("%v ", opcode)
    case .INC_D:
        return fmt.aprintf("%v ", opcode)
    case .DEC_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RLA:
        return fmt.aprintf("%v ", opcode)
    case .JR_e8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .ADD_HL_DE:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_DE:
        return fmt.aprintf("%v ", opcode)
    case .DEC_DE:
        return fmt.aprintf("%v ", opcode)
    case .INC_E:
        return fmt.aprintf("%v ", opcode)
    case .DEC_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RRA:
        return fmt.aprintf("%v ", opcode)
    case .JR_NZ_e8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .LD_HL_n16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .LD_HLi_A:
        return fmt.aprintf("%v ", opcode)
    case .INC_HL:
        return fmt.aprintf("%v ", opcode)
    case .INC_H:
        return fmt.aprintf("%v ", opcode)
    case .DEC_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .DAA:
        return fmt.aprintf("%v ", opcode)
    case .JR_Z_e8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .ADD_HL_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_HLi:
        return fmt.aprintf("%v ", opcode)
    case .DEC_HL:
        return fmt.aprintf("%v ", opcode)
    case .INC_L:
        return fmt.aprintf("%v ", opcode)
    case .DEC_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .CPL:
        return fmt.aprintf("%v ", opcode)
    case .JR_NC_e8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .LD_SP_n16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .LD_HLd_A:
        return fmt.aprintf("%v ", opcode)
    case .INC_SP:
        return fmt.aprintf("%v ", opcode)
    case .INC_aHL:
        return fmt.aprintf("%v ", opcode)
    case .DEC_aHL:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .SCF:
        return fmt.aprintf("%v ", opcode)
    case .JR_C_e8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .ADD_HL_SP:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_HLd:
        return fmt.aprintf("%v ", opcode)
    case .DEC_SP:
        return fmt.aprintf("%v ", opcode)
    case .INC_A:
        return fmt.aprintf("%v ", opcode)
    case .DEC_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .CCF:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_B_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_C_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_D_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_E_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_H_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_L_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_L:
        return fmt.aprintf("%v ", opcode)
    case .HALT:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_A:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_B:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_C:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_D:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_E:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_H:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_L:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_A:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_B:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_C:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_D:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_E:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_H:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_L:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_A:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_B:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_C:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_D:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_E:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_H:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_L:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .ADC_A_A:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_B:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_C:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_D:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_E:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_H:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_L:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_A:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_B:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_C:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_D:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_E:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_H:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_L:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .SBC_A_A:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_B:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_C:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_D:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_E:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_H:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_L:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_A:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_B:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_C:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_D:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_E:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_H:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_L:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .XOR_A_A:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_B:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_C:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_D:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_E:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_H:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_L:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_A:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_B:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_C:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_D:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_E:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_H:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_L:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_HL:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_A:
        return fmt.aprintf("%v ", opcode)
    case .RET_NZ:
        return fmt.aprintf("%v ", opcode)
    case .POP_BC:
        return fmt.aprintf("%v ", opcode)
    case .JP_NZ_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .JP_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .CALL_NZ_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .PUSH_BC:
        return fmt.aprintf("%v ", opcode)
    case .ADD_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_00:
        return fmt.aprintf("%v ", opcode)
    case .RET_Z:
        return fmt.aprintf("%v ", opcode)
    case .RET:
        return fmt.aprintf("%v ", opcode)
    case .JP_Z_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .PREFIX:
        return fmt.aprintf("%v ", opcode)
    case .CALL_Z_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .CALL_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .ADC_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_08:
        return fmt.aprintf("%v ", opcode)
    case .RET_NC:
        return fmt.aprintf("%v ", opcode)
    case .POP_DE:
        return fmt.aprintf("%v ", opcode)
    case .JP_NC_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .CALL_NC_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .PUSH_DE:
        return fmt.aprintf("%v ", opcode)
    case .SUB_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_10:
        return fmt.aprintf("%v ", opcode)
    case .RET_C:
        return fmt.aprintf("%v ", opcode)
    case .RETI:
        return fmt.aprintf("%v ", opcode)
    case .JP_C_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .CALL_C_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .SBC_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_18:
        return fmt.aprintf("%v ", opcode)
    case .LDH_a8_A:
        b := 0xFF00 + cast(u16)peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .POP_HL:
        return fmt.aprintf("%v ", opcode)
    case .LDH_C_A:
        return fmt.aprintf("%v ", opcode)
    case .PUSH_HL:
        return fmt.aprintf("%v ", opcode)
    case .AND_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_20:
        return fmt.aprintf("%v ", opcode)
    case .ADD_SP_e8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .JP_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_a16_A:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .XOR_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_28:
        return fmt.aprintf("%v ", opcode)
    case .LDH_A_a8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .POP_AF:
        return fmt.aprintf("%v ", opcode)
    case .LDH_A_C:
        return fmt.aprintf("%v ", opcode)
    case .DI:
        return fmt.aprintf("%v ", opcode)
    case .PUSH_AF:
        return fmt.aprintf("%v ", opcode)
    case .OR_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_30:
        return fmt.aprintf("%v ", opcode)
    case .LD_HL_SPi_e8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .LD_SP_HL:
        return fmt.aprintf("%v ", opcode)
    case .LD_A_a16:
        w := peek_word(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, w)
    case .EI:
        return fmt.aprintf("%v ", opcode)
    case .CP_A_n8:
        b := peek_byte(self, mem)
        return fmt.aprintf("%v 	$%X", opcode, b)
    case .RST_38:
        return fmt.aprintf("%v ", opcode)
    }
    return "INVALID"
}

disassemble_prefixed :: proc(
    self: ^CPU,
    mem: ^memory.Memory,
    instruction: Prefixed_OpCode,
) -> string {
    return fmt.aprintf("%v ", instruction)
}
