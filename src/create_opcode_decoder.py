import pandas as pd
import os
# Load the most recent ISA.xlsx file
# This file is generated by the Google Sheets API
# and contains the instruction set architecture for the MOS 6502
os.system('cd ../test && python3 sheet_downloader.py && cd ../src')
# Load Excel data into a dictionary, ignoring the first row
excel_file = '../test/ISA.xlsx'
df = pd.read_excel(excel_file, skiprows=1, index_col=0)

# Convert DataFrame to a nested dictionary with string keys
opcode_dict = df.apply(lambda row: {str(k): v for k, v in row.to_dict().items()}, axis=1).to_dict()
opcode_dict = {str(k): v for k, v in opcode_dict.items()}

# Addressing mode mapping with 4-bit binary values
addressing_mode_map = {
    'A': 'Accumulator',           # Accumulator
    '#': 'Immediate',             # Immediate
    'zpg': 'Zero Page',           # Zero Page
    'zpg,X': 'Zero Page,X',       # Zero Page,X
    'zpg,Y': 'Zero Page,Y',       # Zero Page,Y
    'abs': 'Absolute',            # Absolute
    'abs,X': 'Absolute,X',        # Absolute,X
    'abs,Y': 'Absolute,Y',        # Absolute,Y
    'ind': 'Indirect',            # Indirect
    'X,ind': 'Indexed Indirect',  # Indexed Indirect
    'ind,Y': 'Indirect Indexed',  # Indirect Indexed
    'impl': 'Implied',            # Implied
    'rel': 'Relative'             # Relative
}

def get_after_space(s):
    parts = s.split(' ', 1)
    return parts[1] if len(parts) > 1 else ''

# Function to extract addressing mode from instruction format
def extract_addressing_mode(instruction):
    instruction_part = get_after_space(instruction)
    for pattern in addressing_mode_map.keys():
        if pattern == instruction_part:
            return pattern
    return None

# Function to get addressing mode and instruction name given an opcode
def get_instruction_info(opcode):
    hi_nibble = (opcode >> 4) & 0xF
    lo_nibble = opcode & 0xF
    
    hi_nibble_hex = format(hi_nibble, 'X')
    lo_nibble_hex = format(lo_nibble, 'X')
    
    #print(f"hi_nibble_hex: {hi_nibble_hex}, lo_nibble_hex: {lo_nibble_hex}")
    
    if hi_nibble_hex in opcode_dict:
        #print(f"Found hi_nibble_hex: {hi_nibble_hex} in opcode_dict")
        lo_nibble_dict = opcode_dict[hi_nibble_hex]
        if lo_nibble_hex in lo_nibble_dict:
            mnemonic_addr = lo_nibble_dict[lo_nibble_hex]
            #print(f"Found lo_nibble_hex: {lo_nibble_hex} in lo_nibble_dict with mnemonic_addr: {mnemonic_addr}")
        else:
            mnemonic_addr = None
            print(f"lo_nibble_hex: {lo_nibble_hex} not found in lo_nibble_dict")
    else:
        mnemonic_addr = None
        print(f"hi_nibble_hex: {hi_nibble_hex} not found in opcode_dict")
    
    if mnemonic_addr and mnemonic_addr != '---':
        addressing_mode = extract_addressing_mode(mnemonic_addr)
        if addressing_mode not in addressing_mode_map:
            print(f"Warning: Addressing mode '{addressing_mode}' not found in map for instruction '{mnemonic_addr}'")
            addressing_mode = 'impl'  # Default to 'impl' if not found
        
        instruction_name = mnemonic_addr.split(' ')[0]
        return instruction_name, addressing_mode_map[addressing_mode]
    else:
        return None, None

