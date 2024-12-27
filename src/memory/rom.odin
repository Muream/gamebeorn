package memory

import "core:fmt"
import "core:log"

ROM :: struct {
    header: Header,
    bytes:  []u8,
}

load_rom :: proc(bytes: []u8) -> ROM {
    entry_point := bytes[0x0100:0x0104]
    logo := bytes[0x0104:0x0134]
    title := bytes[0x0134:0x0144]
    manufacturer_code := bytes[0x013F:0x0143]
    cgb_flag := bytes[0x0143]
    new_lic_code := bytes[0x0144:0x0146]
    sgb_flag := bytes[0x0146]
    cartridge_type := bytes[0x0147]
    rom_size := bytes[0x0148]
    ram_size := bytes[0x0149]
    dest_code := bytes[0x014A]
    old_lic_code := bytes[0x014B]
    version := bytes[0x014C]
    checksum := bytes[0x014D]

    a := bytes[0x014E]
    b := bytes[0x014F]
    global_checksum := (u16(a) << 8) | u16(b)

    return ROM {
        {
            entry_point,
            logo,
            title,
            manufacturer_code,
            cgb_flag,
            new_lic_code,
            sgb_flag,
            cartridge_type,
            rom_size,
            ram_size,
            dest_code,
            old_lic_code,
            version,
            checksum,
            global_checksum,
        },
        bytes,
    }
}

make_rom :: proc() -> ROM {
    return ROM{{}, {}}
}

read_rom :: proc(self: ^ROM, address: u16) -> u8 {
    log.debugf("reading ROM memory at %X", address)
    return self.bytes[address]
}

write_rom :: proc(self: ^ROM, address: u16, value: u8) {
    self.bytes[address] = value
}
