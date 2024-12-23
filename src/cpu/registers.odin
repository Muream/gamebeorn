package cpu

Registers :: struct {
    a:  u8 `fmt:"8b"`,
    f:  u8 `fmt:"8b"`,
    b:  u8 `fmt:"8b"`,
    c:  u8 `fmt:"8b"`,
    d:  u8 `fmt:"8b"`,
    e:  u8 `fmt:"8b"`,
    h:  u8 `fmt:"8b"`,
    l:  u8 `fmt:"8b"`,
    sp: u16 `fmt:"16b"`,
    pc: u16 `fmt:"16b"`,
}
