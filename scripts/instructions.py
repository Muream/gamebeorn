import json
from pathlib import Path

instructions_json = Path(__file__).with_suffix(".json")

instructions = json.loads(instructions_json.read_text())

text = ""

for name, instruction in instructions["cbprefixed"].items():
    text += "// TODO:\n"

    instruction_name = instruction["mnemonic"]
    for operand in instruction["operands"]:
        operand_name = ""

        operand_name += operand["name"].replace("$", "")

        if operand.get("increment", False):
            operand_name += "i"

        if operand.get("decrement", False):
            operand_name += "d"

        instruction_name += f"_{operand_name}"

    text += f"// // {instruction_name}\n"

    text += f"// case {name}:\n"
    if "ILLEGAL" in instruction["mnemonic"]:
        text += f'//     panic("Illegal Instruction: {name}")\n'
    else:
        text += f"//     return {int(instruction['cycles'][0] / 4)}\n"
    text += "\n"

print(text)

out = Path(__file__).with_suffix(".odin")
out.write_text(text)
