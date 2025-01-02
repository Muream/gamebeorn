package emulator

import "core:fmt"
import "core:log"

import "../gameboy"

Emulator :: struct {
    gb:         gameboy.GameBoy,
    state:      EmuState,
    frame_time: f32,
}

EmuState :: enum {
    Paused,
    Playing,
    Stepping,
}

init :: proc() -> Emulator {
    log.debug("Init Emulator")
    return Emulator{gameboy.init(), .Paused, 0}
}
