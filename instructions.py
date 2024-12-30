import json
from pathlib import Path

instructions_json = Path(__file__).with_suffix(".json")

instructions = json.loads(instructions_json.read_text())

text = ""

for name, instruction in instructions["unprefixed"].items():
    # 0xC0 is the last implemented instruction at the time of writing this script
    if int(name, 16) < 0xC0:
        continue

    text += "// TODO:\n"
    text += f'// // {instruction["mnemonic"]}\n'
    text += f"// case {name}:\n"
    if "ILLEGAL" in instruction["mnemonic"]:
        text += f'//     panic("Illegal Instruction: {name}")\n'
    else:
        text += f"//     return {int(instruction['cycles'][0] / 4)}\n"
    text += "\n"

print(text)

out = Path(__file__).with_suffix(".odin")
out.write_text(text)
