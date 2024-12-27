package emulator

import "core:fmt"
import "core:log"

import "../gameboy"

Emulator :: struct {
    gb: gameboy.GameBoy,
}

init :: proc() -> Emulator {
    log.debug("Init Emulator")
    return Emulator{gameboy.init()}
}
