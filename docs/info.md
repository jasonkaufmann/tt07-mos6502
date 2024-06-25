<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

## Multiplex Data and Address Lines
Currently, TinyTapeout only supports 8 inputs, 8 outputs, and 8I/Os (input/outputs). This is a total of 24 pins. The 6502 has 40 pins. To make this work we have to mux some stuff.

The ADDRESS lines are almost always an output to a memory location, so lets use the 8 output pins to represent this 16 bit binary number. The best technique for the address multiplexing is probably to send the first 8 bits of the address on one clock cyle and then send the top 8 on the next cycle.
So, to control the address lines of this we will have a very basic circuit on the output that takes the 16 bit address and splits it into two 8 bit accesses. There are 2 other output signals R/W and SYNC, so we will need 3 total reads/clock cycles to get all the address lines and other output signals out of the CPU. So, the 6502 internal clock will run 3x slower than the external one you provide in the board.

The 8 DATA pins will go on the  I/O lines unmuxed and should fit perfectly. They need to be bidirectional for reads and writes to memory / other peripherals.

The rest of the pins RDY, IRQ, NMI, and SO are inputs are can go on the input pins.

This results in the final TT pinout as follows:

<img width="189" alt="Screenshot 2024-06-24 at 4 47 46 PM" src="https://github.com/jasonkaufmann/tt07-mos6502/assets/41923667/ab3400c4-2948-4f9f-8405-f717055c367a">

## MOS 6502 Pinout
        +----+--+----+
     Vss  |1        40 | RST
     RDY  |2        39 | φ2
     φ1   |3        38 | SO
     IRQ  |4        37 | φ0
     NC   |5        36 | NC
     NMI  |6        35 | NC
     SYNC |7        34 | R/W
     Vcc  |8        33 | D0
     A0   |9        32 | D1
     A1   |10       31 | D2
     A2   |11       30 | D3
     A3   |12       29 | D4
     A4   |13       28 | D5
     A5   |14       27 | D6
     A6   |15       26 | D7
     A7   |16       25 | A15
     A8   |17       24 | A14
     A9   |18       23 | A13
     A10  |19       22 | A12
     A11  |20       21 | Vss
          +-----------+

# ISA information
See this for all possible instructions and addressing modes.
<img width="1293" alt="Screenshot 2024-06-24 at 4 30 33 PM" src="https://github.com/jasonkaufmann/tt07-mos6502/assets/41923667/a0ccad09-42a7-43d1-a93e-fb34099bee91">

# Internal Architecture Diagrams
<img width="761" alt="Screenshot 2024-06-24 at 4 35 23 PM" src="https://github.com/jasonkaufmann/tt07-mos6502/assets/41923667/d718e94b-624d-456b-adc3-7a966ad05ae3">
<img width="712" alt="Screenshot 2024-06-24 at 4 35 48 PM" src="https://github.com/jasonkaufmann/tt07-mos6502/assets/41923667/e05becad-8130-4005-bc2a-7d1f999c04cc">

# Notes
See this for all the notes I took when designing this.
[MOS6502 CPU.pdf](https://github.com/user-attachments/files/15962288/MOS6502.CPU.pdf)

## How to test

It's a 6502! Run any programs you want! I will provide some basic programs to show the basic functionality.

## External hardware

You will most likely want the RP2040 carrier board for this since there is no internal memory on the chip. The RAM and the ROM can be emulated on the internal memory of the Raspberry Pi module.

Other than that, you can plug this into anywhere like a normal 6502. Note: since some pins need to be multiplexed you may need a simple breadboard or PCB circuit that takes the the 8 bit output address parts and reconstructs them into the actual 16 bit 6502 address.
