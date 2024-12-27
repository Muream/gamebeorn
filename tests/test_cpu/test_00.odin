package test_cpu

import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"
import "core:testing"

import "../../src/cpu"
import "../../src/emulator"
import "../../src/memory"

get_tests :: proc(path: string) -> json.Array {

    log.info(path)
    data, ok := os.read_entire_file_from_filename(path)
    if !ok {
        panic("Failed to load the file!")
    }
    defer delete(data) // Free the memory at the end

    // Parse the json file.
    json_data, err := json.parse(data)
    if err != .None {
        panic("Failed to parse the json file.")
    }

    // Access the Root Level Object
    tests := json_data.(json.Array)

    return tests
}


configure_state :: proc(emu: ^emulator.Emulator, config: json.Object) {

    emu.gb.cpu.a = cast(u8)(config["a"].(json.Float))
    emu.gb.cpu.b = cast(u8)(config["b"].(json.Float))
    emu.gb.cpu.c = cast(u8)(config["c"].(json.Float))
    emu.gb.cpu.d = cast(u8)(config["d"].(json.Float))
    emu.gb.cpu.e = cast(u8)(config["e"].(json.Float))
    emu.gb.cpu.f = cast(u8)(config["f"].(json.Float))
    emu.gb.cpu.h = cast(u8)(config["h"].(json.Float))
    emu.gb.cpu.sp = cast(u16)(config["sp"].(json.Float))
    emu.gb.cpu.pc = cast(u16)(config["pc"].(json.Float))


    for mem_data in config["ram"].(json.Array) {
        addr := cast(u16)mem_data.(json.Array)[0].(json.Float)
        val := cast(u8)mem_data.(json.Array)[1].(json.Float)
        memory.write(&emu.gb.mem, addr, val)
    }

}


verify_state :: proc(t: ^testing.T, emu: ^emulator.Emulator, config: json.Object) {
    testing.expect_value(t, emu.gb.cpu.a, cast(u8)config["a"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.b, cast(u8)config["b"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.c, cast(u8)config["c"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.d, cast(u8)config["d"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.e, cast(u8)config["e"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.f, cast(u8)config["f"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.h, cast(u8)config["h"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.sp, cast(u16)config["sp"].(json.Float))
    testing.expect_value(t, emu.gb.cpu.pc, cast(u16)config["pc"].(json.Float))
}


@(test)
opcode_00 :: proc(t: ^testing.T) {
    tests := get_tests("deps/sm83/v1/00.json")
    defer json.destroy_value(tests)


    emu := emulator.init()
    rom: [64 * 1024]u8 = {}
    emu.gb.mem.rom = memory.load_rom(rom[:])

    for test in tests {

        initial := test.(json.Object)["initial"].(json.Object)
        final := test.(json.Object)["final"].(json.Object)
        cycles := test.(json.Object)["cycles"].(json.Array)

        configure_state(&emu, initial)

        for cycle in cycles {
            cpu.step(&emu.gb.cpu, &emu.gb.mem)
        }

        verify_state(t, &emu, final)

        // break
    }
}
