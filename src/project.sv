/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tinymos6502 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  // assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  // assign uio_out = 8'h00;
  // assign uio_oe  = 8'h00;

  //make all the internal wires

  //assign all the input pins their proper name
  assign RDY = 

  //the system clock will be 3 times slower than the input clock
  reg [1:0] clk_div;
  always @(posedge clk or negedge rst_n) begin
    if (~rst_n or clk_div == 2'b10) begin
      clk_div <= 2'b00;
    end else begin
      clk_div <= clk_div + 1;
    end
  end

  //instantiation of the 8-bit eater
  //the name of the top module is 'eightBit'
  tinymos6502 tinymos6502_inst (
      .RST_N,
      .CLK,
      .RDY,
      .IRQ,
      .NMI,
      .SO,
      .DATA_OUT,        
      .DATA_IN,         
      .OUTPUT_ENABLE,  
      .ADDRESS,
      .RW,
      .SYNC
  );



endmodule
