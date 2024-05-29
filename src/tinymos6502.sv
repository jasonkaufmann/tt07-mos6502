//top level module
module tinymos6502 (
    input  wire         RST_N,
    input  wire         CLK,

    input  wire         RDY,
    input  wire         IRQ,
    input  wire         NMI,
    input  wire         SO,

    output wire [7:0]   DATA_OUT,        // IOs: Output path
    input  wire [7:0]   DATA_IN,         // IOs: Input path
    output wire [7:0]   OUTPUT_ENABLE,   // IOs: Enable path (active high: 0=input, 1=output)

    output wire [15:0]  ADDRESS,
    output wire         RW,
    output wire         SYNC
);


localparam BUS_WIDTH = 8; // this is an 8 bit CPU

assign uio_oe = RW ? 8'b0 : 8'b1; // if RW is high, make uio_oe an input, otherwise make it an output

//define the buses in the CPU (yes, this has tri-state logic, yosys has limited support for this which I hope should work?)
wire [BUS_WIDTH - 1 : 0] DATA_BUS; 
wire [BUS_WIDTH - 1 : 0] ADH;
wire [BUS_WIDTH - 1 : 0] ADL;

//define all the registers of the 6502
register #(.n(8))  INDEX_REGISTER_X (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));
register #(.n(8))  INDEX_REGISTER_Y (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));

register #(.n(16)) STACK_POINTER    (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));

register #(.n(8))  ACCUMULATOR      (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));

register #(.n(8))  PCH              (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));
register #(.n(8))  PCL              (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));

register #(.n(8))  PROCESSOR_STATUS (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));
register #(.n(8))  INSTRUCTION      (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(/*need load control signal*/), .output_enable(/*need oe control signal*/), .data_out(DATA_BUS));

//define the ALU
alu alu (.a(a), .b(b), .sub(sub), .out(aluOut), .zeroFlag(zf), .carryFlag(cf));

//make all the control lines
wire irxi, iryi, spri, ai, pchi, pcli, ai, psri, iri; //input enable (load) lines for register
wire irxo, iryo, spro, ao, pcho, pclo, ao, psro, iro; //output enable lines for register
//make the instruction decoder
decoder decoder();

endmodule