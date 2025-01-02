package ui

import "core:fmt"

import clay "../clay-odin"

import "../cpu"
import "../emulator"


cpu_panel :: proc(emu: ^emulator.Emulator) {
    if clay.UI(
        clay.Layout(
            {sizing = {width = clay.SizingGrow({}), height = clay.SizingGrow({})}},
        ),
    ) {
        if clay.UI(
            clay.ID("Left Panel"),
            clay.Rectangle({color = {90, 90, 90, 50}}),
            clay.Layout(
                {
                    layoutDirection = clay.LayoutDirection.TOP_TO_BOTTOM,
                    sizing = {width = clay.SizingFit({}), height = clay.SizingFit({})},
                },
            ),
        ) {
            clay.Text("CPU", &text_config)
            z := "Z" if cpu.get_zero_flag(&emu.gb.cpu) else "_"
            n := "N" if cpu.get_sub_flag(&emu.gb.cpu) else "_"
            h := "H" if cpu.get_half_carry_flag(&emu.gb.cpu) else "_"
            c := "C" if cpu.get_carry_flag(&emu.gb.cpu) else "_"
            clay.Text(
                fmt.aprintf(
                    "AF: %02x %02x %v %v %v %v",
                    emu.gb.cpu.a,
                    emu.gb.cpu.f,
                    z,
                    n,
                    h,
                    c,
                ),
                &text_config,
            )
            clay.Text(
                fmt.aprintf("BC: %02x %02x", emu.gb.cpu.b, emu.gb.cpu.c),
                &text_config,
            )
            clay.Text(
                fmt.aprintf("DE: %02x %02x", emu.gb.cpu.d, emu.gb.cpu.e),
                &text_config,
            )
            clay.Text(
                fmt.aprintf("HL: %02x %02x", emu.gb.cpu.h, emu.gb.cpu.l),
                &text_config,
            )
            clay.Text(fmt.aprintf("SP: %04x", emu.gb.cpu.sp), &text_config)
            clay.Text(fmt.aprintf("PC: %04x", emu.gb.cpu.pc), &text_config)
            clay.Text(fmt.aprintf("Frame Time: %.5fs", emu.frame_time), &text_config)
        }
    }
}
