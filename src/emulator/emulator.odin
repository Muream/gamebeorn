package emulator

import "core:fmt"

import "../gameboy"

Emulator :: struct {
    gb: gameboy.GameBoy,
}

init :: proc() -> Emulator {
    fmt.println("Init Emulator")
    return Emulator{gameboy.init()}
}
