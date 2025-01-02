import json
from pathlib import Path

instructions_json = Path(__file__).parent / "instructions.json"

instructions = json.loads(instructions_json.read_text())

text = ""

text += "package main\n"

text += "OpCode :: enum u8 {\n"

for name, instruction in instructions["unprefixed"].items():
    if "ILLEGAL" in instruction["mnemonic"]:
        continue
    if instruction["bytes"] == 0:
        continue
    print(name, instruction["bytes"])

    instruction_name = instruction["mnemonic"]
    for operand in instruction["operands"]:
        operand_name = ""

        operand_name += operand["name"].replace("$", "")

        if operand.get("increment", False):
            operand_name += "i"

        if operand.get("decrement", False):
            operand_name += "d"

        instruction_name += f"_{operand_name}"

    text += f"case .{instruction_name}:\n"
    bytes_format = ""
    bytes_format2 = ""

    if instruction["bytes"] == 2:
        text += "    b := peek_byte(self, mem)\n"
        bytes_format += "\t$%X"
        bytes_format2 += ", b"

    if instruction["bytes"] == 3:
        text += "    w := peek_word(self, mem)\n"
        bytes_format += "\t$%X"
        bytes_format2 += ", w"

    text += f'    return fmt.aprintf("%v {bytes_format}", opcode{bytes_format2})'

    # text += f" = {name},"

    text += "\n"
    # text +=
    pass

text += "}\n"

print(text)

out = Path(__file__).with_suffix(".odin")
out.write_text(text)
