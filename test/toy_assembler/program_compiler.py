import pandas as pd

# Step 1: Load Excel data into a dictionary, ignoring the first row
excel_file = 'ISA.xlsx'
df = pd.read_excel(excel_file, skiprows=1, index_col=0)

# Convert DataFrame to a nested dictionary
opcode_dict = df.apply(lambda row: row.to_dict(), axis=1).to_dict()

# Function to normalize instruction format
def normalize_instruction(instruction):
    parts = instruction.split()
    if len(parts) == 2:
        return f"{parts[0]} {parts[1]}"
    elif len(parts) == 1:
        return parts[0]
    return instruction

# Function to extract addressing mode from instruction
def extract_addressing_mode(instruction):
    if ',' in instruction:
        if instruction.endswith(',X'):
            return 'abs,X' if '$' in instruction else 'zpg,X'
        elif instruction.endswith(',Y'):
            return 'abs,Y' if '$' in instruction else 'zpg,Y'
        elif instruction.startswith('(') and ',X' in instruction:
            return 'X,ind'
        elif instruction.startswith('(') and ',Y' in instruction:
            return 'ind,Y'
        elif instruction.startswith('('):
            return 'ind'
    elif instruction.startswith('#'):
        return '#'
    elif instruction.startswith('('):
        return 'ind'
    elif '$' in instruction:
        return 'abs'
    elif len(instruction) == 2:
        return 'impl'
    elif instruction.isdigit():
        return 'rel'
    else:
        return 'A'

# Step 2: Function to find opcode
def find_opcode(instruction):
    normalized_instruction = normalize_instruction(instruction)
    mnemonic, operand = normalized_instruction.split()
    addressing_mode = extract_addressing_mode(operand)

    for hi_nibble, lo_nibbles in opcode_dict.items():
        for lo_nibble, mnemonic_addr in lo_nibbles.items():
            mnemonic_addr_split = mnemonic_addr.split()
            if len(mnemonic_addr_split) == 2 and mnemonic_addr_split[0] == mnemonic and mnemonic_addr_split[1].startswith(addressing_mode):
                return f"{hi_nibble}{lo_nibble}"
    return None

# Step 3: Read the text file containing the assembly instructions
with open('program.txt', 'r') as file:
    instructions = file.readlines()

# Step 4: Translate each instruction to its corresponding machine code
translated_instructions = []
hex_output = []
for instruction in instructions:
    instruction = instruction.strip()
    opcode = find_opcode(instruction)
    if opcode:
        hex_opcode = opcode.upper()
        bin_opcode = format(int(opcode, 16), '08b')
        translated_instructions.append(f"{instruction}: Hex: {hex_opcode}, Binary: {bin_opcode}")
        hex_output.append(hex_opcode)
        if '#' in instruction:
            operand = instruction.split('#')[1].zfill(2).upper()
            hex_output.append(operand)
    else:
        translated_instructions.append(f"{instruction}: Opcode not found")

# Step 5: Print the translated instructions
for line in translated_instructions:
    print(line)

# Step 6: Save the hexadecimal opcodes to output.bin
with open('program.bin', 'wb') as file:
    for hex_opcode in hex_output:
        # Convert the hexadecimal string to bytes
        byte_data = bytes.fromhex(hex_opcode)
        # Write the bytes to the file
        file.write(byte_data)
