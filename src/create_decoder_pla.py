import pandas as pd
from enum import Enum
from create_opcode_decoder import *

# let's create a microcode counter to know which instruction cycle we are in
class MicrocodeCounter(Enum):
    T0 = 0
    T1 = 1
    T2 = 2
    T3 = 3
    T4 = 4
    T5 = 5
    T6 = 6

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
    pass

def absolute_addressing_mode(opcode):
    pass

def A_addressing_mode(opcode):
    pass

def implied_addressing_mode(opcode):
    pass

def determine_control_signals(instruction_name, addressing_mode, microcode_counter):
    signals = {signal: False for signal in control_signals}
    if microcode_counter == MicrocodeCounter.T0:
        signals['rw'] = False  # Read from memory
        signals['pcho'] = True # Load PC high byte
        signals['pclo'] = True # Load PC low byte
        signals['iri'] = True  # Load instruction register
    elif microcode_counter == MicrocodeCounter.T1:
        pass
    return signals

def generate_verilog(opcode_to_signals, control_signals):
    control_signal_map = {}
    for (opcode, cycle), signals in opcode_to_signals.items():
        control_signal_bits = ''.join(['1' if signals[signal] else '0' for signal in control_signals])
        if control_signal_bits not in control_signal_map:
            control_signal_map[control_signal_bits] = []
        control_signal_map[control_signal_bits].append((opcode, cycle))

    verilog_code = f"""
module PLA (
    input [7:0] opcode,
    input [2:0] microcode_counter,
    output reg [{len(control_signals)-1}:0] control_signals
);

// Define control signal positions
"""
    for idx, signal in enumerate(control_signals):
        verilog_code += f"parameter {signal.upper()} = {idx};\n"

    verilog_code += """
always @(*) begin
    casez ({opcode, microcode_counter})
"""

    for control_signal_bits, entries in control_signal_map.items():
        if len(entries) == 1:
            opcode, cycle = entries[0]
            opcode_bin = f"{opcode:08b}"
            cycle_bin = f"{cycle.value:03b}"
            pattern = f"{opcode_bin}_{cycle_bin}"
            verilog_code += f"        11'b{pattern}: control_signals = {len(control_signals)}'b{control_signal_bits};\n"
        else:
            combined_pattern = None
            for opcode, cycle in entries:
                opcode_bin = f"{opcode:08b}"
                cycle_bin = f"{cycle.value:03b}"
                pattern = f"{opcode_bin}_{cycle_bin}"
                if combined_pattern is None:
                    combined_pattern = list(pattern)
                else:
                    for i in range(len(pattern)):
                        if combined_pattern[i] != pattern[i]:
                            combined_pattern[i] = '?'
            combined_pattern_str = ''.join(combined_pattern)
            # Ensure that the combined pattern is not entirely '?' (which would match everything)
            if combined_pattern_str.count('?') < len(combined_pattern_str) - 1:
                verilog_code += f"        11'b{combined_pattern_str}: control_signals = {len(control_signals)}'b{control_signal_bits};\n"

    verilog_code += """
        default: control_signals = 0;
    endcase
end

endmodule
"""
    return verilog_code

# Example usage
opcode_to_signals = {}

for opcode in range(256):  # Assuming 8-bit opcodes
    for cycle in MicrocodeCounter:
        instruction_name, addressing_mode = get_instruction_info(opcode)
        signals = determine_control_signals(instruction_name, addressing_mode, cycle)
        opcode_to_signals[(opcode, cycle)] = signals

verilog_code = generate_verilog(opcode_to_signals, control_signals)

with open("pla.sv", "w") as f:
    f.write(verilog_code)
