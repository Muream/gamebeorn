package cpu

import "core:fmt"

import "../memory"

dbg_msg: [1024]u8 = {}
msg_size := 0

dbg_update :: proc(cpu: ^CPU, mem: ^memory.Memory) {
    if memory.read(mem, 0xff02) == 0x81 {
        c := memory.read(mem, 0xff01)
        msg_size += 1
        dbg_msg[msg_size] = c

        memory.write(mem, 0xff02, 0)
    }
}

dbg_print :: proc(cpu: ^CPU, mem: ^memory.Memory) {
    if dbg_msg[0] != 0 {
        fmt.printfln("DBG: %v", dbg_msg[:])
    }
}
