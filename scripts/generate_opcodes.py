import json
from pathlib import Path

instructions_json = Path(__file__).with_suffix(".json")

instructions = json.loads(instructions_json.read_text())

text = ""

text += "package main\n"

text += "OpCode :: enum u8 {\n"

for name, instruction in instructions["cbprefixed"].items():
    # 0xC0 is the last implemented instruction at the time of writing this script
    # if int(name, 16) < 0xC0:
    #     continue
    if "ILLEGAL" in instruction["mnemonic"]:
        continue
    text += f'    {instruction["mnemonic"]}'

    for operand in instruction["operands"]:
        operand_name = ""

        operand_name += operand["name"].replace("$", "")

        if operand.get("increment", False):
            operand_name += "i"

        if operand.get("decrement", False):
            operand_name += "d"

        text += f"_{operand_name}"

    text += f" = {name},"

    text += "\n"
    # text +=
    pass

text += "}\n"

print(text)

out = Path(__file__).with_suffix(".odin")
out.write_text(text)
