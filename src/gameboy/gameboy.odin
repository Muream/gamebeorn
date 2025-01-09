
package gameboy

import "core:fmt"
import "core:log"

import "../cpu"
import "../memory"

GameBoy :: struct {
    cpu: cpu.CPU,
    mem: memory.Memory,
}

init :: proc() -> GameBoy {
    c := cpu.init()
    m := memory.init()
    return {c, m}
}
