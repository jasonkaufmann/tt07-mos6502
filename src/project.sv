/*
 * Copyright (c) 2024 Jason Kaufmann
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_jasonk_6502 (
    input  wire [7:0] ui_in,    // Dedicated inputs: 8-bit input bus for various control signals
    output wire [7:0] uo_out,   // Dedicated outputs: 8-bit output bus for various control signals
    input  wire [7:0] uio_in,   // IOs: Input path, 8-bit bidirectional bus for data input
    output wire [7:0] uio_out,  // IOs: Output path, 8-bit bidirectional bus for data output
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output), 8-bit output enable signals
    input  wire       ena,      // Enable signal, goes high when the design is enabled
    input  wire       clk,      // Clock signal
    input  wire       rst_n     // Reset signal, active low (low to reset the module)
);
  // Define local parameters for bus and address widths
  localparam BUS_WIDTH     = 8;  // This is an 8-bit CPU
  localparam ADDRESS_WIDTH = 16; // This is a 16-bit address space CPU

  /*** INPUTS ***/
  // Declare the input wires from outside the chip
  wire RDY, IRQ, NMI, SO;

  // Map input pins to control signals
  assign RDY = ui_in[0];  // Ready signal
  assign IRQ = ui_in[1];  // Interrupt request signal
  assign NMI = ui_in[2];  // Non-maskable interrupt signal
  assign SO  = ui_in[3];  // Set overflow signal
  /*************/

  /*** OUTPUTS ***/
  // Declare register for full address
  reg [ADDRESS_WIDTH - 1: 0] ADDRESS;
  // Declare registers for read/write control and synchronization
  reg RW;   // Read/Write control
  reg SYNC; // Synchronization signal
  reg [7:0] output_data; // Data output bus
  assign uo_out = output_data; // Assign output data to output bus
  /***************/

  /********************* CLOCK DIVIDE BY 3 AND OUTPUT SIGNALS ************************/
  reg clock_6502;   // system clock that goes to the 6502
  reg [1:0] clk_div; // clock divider counter

  // Clock divider logic to generate system clock and control outputs
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      clk_div <= 2'b00;    // Reset clock divider
      clock_6502 <= 1'b0;  // Reset system clock
    end else begin
      clk_div <= clk_div + 1; // Increment clock divider
      case (clk_div)
        2'b00: output_data <= ADDRESS[BUS_WIDTH - 1 : 0];      // Output lower byte of address
        2'b01: output_data <= ADDRESS[BUS_WIDTH +: BUS_WIDTH]; // Output upper byte of address
        2'b10: begin
          output_data[0] <= RW;             // Output read/write control
          output_data[1] <= SYNC;           // Output synchronization signal
          clock_6502 <= ~clock_6502;   // Toggle system clock
          clk_div <= 2'b00;            // Reset clock divider
        end
        default: ;
      endcase
    end
  end
  /***********************************************************************************/

  /**************************** Instantiate the 6502 core ****************************/
  tinymos6502 tinymos6502_inst (
      .RST_N(rst_n),         // Reset signal, active low
      .CLK(clock_6502),      // System clock signal
      .RDY(RDY),             // Ready signal input
      .IRQ(IRQ),             // Interrupt request signal input
      .NMI(NMI),             // Non-maskable interrupt signal input
      .SO(SO),               // Set overflow signal input
      .DATA_OUT(uio_out),    // Data output bus
      .DATA_IN(uio_in),      // Data input bus
      .OUTPUT_ENABLE(uio_oe),// Output enable signals
      .ADDRESS(ADDRESS),     // Address bus
      .RW(RW),               // Read/Write control signal
      .SYNC(SYNC)            // Synchronization signal
  );
  /***********************************************************************************/

endmodule
