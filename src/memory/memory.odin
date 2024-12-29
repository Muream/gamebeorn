package memory

import "core:fmt"
import "core:log"


Memory :: struct {
    mem: []u8,
}


init :: proc() -> Memory {
    log.debug("Init Memory")
    mem := make([]u8, 64 * 1024)
    return {mem}
}

read :: proc(self: ^Memory, address: u16) -> u8 {
    if cast(uint)address >= len(self.mem) {
        fmt.panicf("Invalid write @ %X", address)
    }
    return self.mem[address]
}

write :: proc(self: ^Memory, address: u16, value: u8) {

    if cast(uint)address >= len(self.mem) {
        fmt.panicf("Invalid write @ %X", address)
    }

    self.mem[address] = value

}
