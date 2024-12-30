package test_cpu

import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"
import "core:testing"

import "../../src/cpu"
import "../../src/emulator"
import "../../src/memory"

Test :: struct {
    name:    string,
    initial: State,
    final:   State,
    cycles:  [][3]Cycle,
}


Cycle :: union {
    u16,
    u8,
    string,
}

State :: struct {
    a:   u8,
    f:   u8,
    b:   u8,
    c:   u8,
    d:   u8,
    e:   u8,
    h:   u8,
    l:   u8,
    sp:  u16,
    pc:  u16,
    ime: u8,
    ei:  u8,
    ram: [][2]int,
}

get_tests :: proc(path: string) -> []Test {
    data, ok := os.read_entire_file_from_filename(path)
    if !ok {
        log.error("Failed to load the file!")
    }
    defer delete(data) // Free the memory at the end

    tests: []Test
    err := json.unmarshal(data, &tests, allocator = context.temp_allocator)
    if err != nil {
        log.error(err)
    }
    // // Parse the json file.
    // json_data, err := json.parse(data)
    // if err != .None {
    //     panic("Failed to parse the json file.")
    // }

    // // Access the Root Level Object
    // tests := json_data.(json.Array)

    return tests
}

configure_state :: proc(emu: ^emulator.Emulator, state: State) {

    emu.gb.cpu.a = state.a
    emu.gb.cpu.b = state.b
    emu.gb.cpu.c = state.c
    emu.gb.cpu.d = state.d
    emu.gb.cpu.e = state.e
    emu.gb.cpu.f = state.f
    emu.gb.cpu.h = state.h
    emu.gb.cpu.l = state.l
    emu.gb.cpu.sp = state.sp
    emu.gb.cpu.pc = state.pc

    for mem_data in state.ram {
        addr := cast(u16)mem_data[0]
        val := cast(u8)mem_data[1]
        memory.write(&emu.gb.mem, addr, val)
    }

}

verify_state :: proc(t: ^testing.T, emu: ^emulator.Emulator, state: State) {
    testing.expect_value(t, emu.gb.cpu.a, state.a)
    testing.expect_value(t, emu.gb.cpu.b, state.b)
    testing.expect_value(t, emu.gb.cpu.c, state.c)
    testing.expect_value(t, emu.gb.cpu.d, state.d)
    testing.expect_value(t, emu.gb.cpu.e, state.e)
    testing.expect_value(t, emu.gb.cpu.f, state.f)
    testing.expect_value(t, emu.gb.cpu.h, state.h)
    testing.expect_value(t, emu.gb.cpu.l, state.l)
    testing.expect_value(t, emu.gb.cpu.sp, state.sp)
    testing.expect_value(t, emu.gb.cpu.pc, state.pc)
}

test_opcode :: proc(t: ^testing.T, opcode: string) {
    path := fmt.aprintf("deps/sm83/v1/%s.json", opcode)
    defer delete(path)
    tests := get_tests(path)

    emu := emulator.init()
    defer delete(emu.gb.mem.mem)

    for test in tests {
        configure_state(&emu, test.initial)

        cpu.step(&emu.gb.cpu, &emu.gb.mem)

        verify_state(t, &emu, test.final)
    }
}
