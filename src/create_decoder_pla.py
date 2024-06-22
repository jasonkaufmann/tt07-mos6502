import pandas as pd
from enum import Enum
from create_opcode_decoder import *

# let's create a microcode counter to know which instruction cycle we are in
microcode_counter = 0
class MicrocodeCounter(Enum):
    T0 = 0
    T1 = 1
    T2 = 2
    T3 = 3
    T4 = 4
    T5 = 5
    T6 = 6

# load in the all the control signals from control_signals.txt
# List of control signals
control_signals = [
    "irxi", "iryi", "spri", "ai", "pchi", "pcli", "psri", "iri",
    "irxo", "iryo", "spro", "ao", "pcho", "pclo", "psro", "iro",
    "sum_sel", "and_sel", "xor_sel", "or_sel", "asl_sel", "lsr_sel", "rol_sel", "ror_sel",
    "target_bus", "subtract"
]

# Initialize each control signal with a default value, e.g., False
signals = {signal: False for signal in control_signals}

def immediate_addressing_mode(opcode):
    # load the immediate value into the data bus
    
    pass


def absolute_addressing_mode(opcode):
    pass

def A_addressing_mode(opcode):
    pass

def implied_addressing_mode(opcode):
    pass


def determine_control_signals(instruction_name, addressing_mode, microcode_counter):

    # Initialize each control signal with a default value, e.g., False
    signals = {signal: False for signal in control_signals}

    if microcode_counter == MicrocodeCounter.T0:
        signals['rw'] = False  # Read from memory
        signals['pcho'] = True # Load PC high byte
        signals['pclo'] = True # Load PC low byte
        signals['iri'] = True  # Load instruction register
    elif microcode_counter == MicrocodeCounter.T1:
        pass
        

    return signals

# Example usage
#instantiate the counter
microcode_counter = MicrocodeCounter.T0
opcode = 0xA9  # Example opcode for LDA immediate
instruction_name, addressing_mode = get_instruction_info(opcode)
print(f"Opcode: 0x{opcode:02X}, Instruction: {instruction_name}, Addressing Mode: {addressing_mode}")

# Determine control signals for the current microcode counter
signals = determine_control_signals(instruction_name, addressing_mode, microcode_counter)