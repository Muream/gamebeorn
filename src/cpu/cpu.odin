package cpu

import "core:fmt"

import "../memory"

CPU :: struct {
    regs: Registers,
}

init :: proc() -> CPU {
    fmt.println("Init CPU")
    cpu := CPU{{pc = 0x0100}}
    fmt.println(cpu)
    return cpu
}

next_byte :: proc(self: ^CPU, ram: ^memory.Memory) -> u8 {
    b := memory.read(ram, self.regs.pc)
    self.regs.pc += 1
    return b
}

read_addr :: proc(self: ^CPU, mem: ^memory.Memory) -> u16 {
    a := cast(u16)next_byte(self, mem)
    b := cast(u16)next_byte(self, mem)
    addr := (b << 8) | a
    return addr
}


step :: proc(self: ^CPU, mem: ^memory.Memory) -> uint {
    fmt.printfln("PC: %X", self.regs.pc)
    opcode := next_byte(self, mem)
    switch opcode {
    case 0x0:
        // NOP
        fmt.println("NOP")
        return 4
    case 0xC3:
        //JP a16 3 16 
        fmt.println("JP a16 3  16 ")
        addr := read_addr(self, mem)
        self.regs.pc = addr
        return 4
    case:
        fmt.panicf("Unknown Opcode: 0x{:02X} @ 0x{:04X}", opcode, self.regs.pc - 1)
    }
}
