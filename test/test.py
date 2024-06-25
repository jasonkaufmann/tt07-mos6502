# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

program_to_run = "./toy_assembler/program.bin"
#program_to_run = "./real_assembler/program.bin"


def contains_z_or_x(bin_val):
        bin_str = bin_val.binstr  # Convert to string representation
        return 'z' in bin_str or 'x' in bin_str

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 1
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 0

    await ClockCycles(dut.clk, 1)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    dut._log.info("Test the program")

    # Change it to match the actual expected output of your module:
    counter = 0 # counter to stop the test after a few for now

    # open the file containing the program
    with open(program_to_run, 'rb') as file:
        program = file.read()

    while (1):
        #read the output values from the processor
        addr_low = dut.uo_out.value
        print("addr_low: ", addr_low)  
        await ClockCycles(dut.clk, 1)
        addr_high = dut.uo_out.value
        print("addr_high: ", addr_high)
        await ClockCycles(dut.clk, 1)
        control_sigs = dut.uo_out.value
        print("control_sigs: ", control_sigs)   
        await ClockCycles(dut.clk, 1)

        # create the entire 16 bit address
        #check if the address is valid
        if not contains_z_or_x(addr_low) and not contains_z_or_x(addr_high) and not contains_z_or_x(control_sigs):
            addr = addr_high << 8 | addr_low
            print(f"Address: {hex(addr)}")
            # get that address from the program
            if addr >= len(program):
                break
            instruction = program[addr]
            print(f"Instruction: {hex(instruction)}")

            # put the instruction into the input of the processor
            dut.uio_in.value = instruction;
        
        await ClockCycles(dut.clk, 1)

        # increment the counter
        counter += 1
        if counter > 50:
            break

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
