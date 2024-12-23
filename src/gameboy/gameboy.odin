
package gameboy

import "core:fmt"

import "../cpu"
import "../memory"

GameBoy :: struct {
    cpu: cpu.CPU,
    mem: memory.Memory,
}

init :: proc() -> GameBoy {
    fmt.println("Init GameBoy")

    c := cpu.init()

    m := memory.init()

    return {c, m}
}
