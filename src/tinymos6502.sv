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


localparam BUS_WIDTH     = 8; // this is an 8 bit CPU
localparam ADDRESS_WIDTH = 16; // this is an 16 bit address space CPU

assign uio_oe = RW ? 8'b0 : 8'b1; // if RW is high, make uio_oe an input, otherwise make it an output

//define the buses in the CPU (yes, this has tri-state logic, yosys has limited support for this which I hope should work?)
wire [BUS_WIDTH - 1 : 0] DATA_BUS; 
wire [BUS_WIDTH - 1 : 0] ACCUMULATOR; 
wire [BUS_WIDTH - 1 : 0] PROCESSOR_STATUS;
wire [BUS_WIDTH - 1 : 0] ADH;
wire [BUS_WIDTH - 1 : 0] ADL;

//define all the registers of the 6502
register #(.n(BUS_WIDTH))          INDEX_REGISTER_X (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(irxi), .data_out(DATA_BUS), .output_enable(irxo),);
register #(.n(BUS_WIDTH))          INDEX_REGISTER_Y (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(iryi), .data_out(DATA_BUS), .output_enable(iryo),);
register #(.n(ADDRESS_WIDTH))      STACK_POINTER    (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(spri), .data_out(DATA_BUS), .output_enable(spro),);
register #(.n(BUS_WIDTH))          PCH              (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(pchi), .data_out(DATA_BUS), .output_enable(pcho),);
register #(.n(BUS_WIDTH))          PCL              (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(pcli), .data_out(DATA_BUS), .output_enable(pclo),);
register #(.n(BUS_WIDTH))          INSTRUCTION      (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(iri),  .data_out(DATA_BUS), .output_enable(iro), );

//register with internal state availble to outside blocks
//OIS = Output Internal State
//register #(.n(BUS_WIDTH), .OIS(1)) PROCESSOR_STATUS (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(psri), .data_out(DATA_BUS), .output_enable(psro), .data_stored_out(PROCESSOR_STATUS));
register #(.n(BUS_WIDTH), .OIS(1)) ACCUMULATOR      (.clk(CLK), .rst(RST_N), .data_in(DATA_BUS), .load(ai),   .data_out(DATA_BUS), .output_enable(ao),   .data_stored_out(ACCUMULATOR));

//PSR (Processor status register) bits
wire                       neg_result, overflow, expansion, break_command, decimal_mode, interrupt_disable, zero_result, carry
assign PROCESSOR_STATUS = {neg_result, overflow, expansion, break_command, decimal_mode, interrupt_disable, zero_result, carry};

//ALU control bits
wire sum_sel, and_sel, xor_sel, or_sel, shift_right_sel;
//sum select, and select, xor select, or select


//define the ALU
alu alu #(.n(BUS_WIDTH)) (
    .a(ACCUMULATOR), 
    .b(DATA_BUS), 

    .sum_sel(sum_sel),
    .and_sel(and_sel),
    .xor_sel(xor_sel),
    .or_sel(or_sel),
    .shift_right_sel(shift_right_sel),

    .out(DATA_BUS), 

    .overflow_flag(over), 
    .carry_flag(carry_flag),
    .half_carry_flag(half_carry_flag)
);

//make all the control lines
wire irxi, iryi, spri, ai, pchi, pcli, psri, iri; //input enable (load) lines for register
wire irxo, iryo, spro, ao, pcho, pclo, psro, iro; //output enable lines for register

//make the instruction decoder
decoder decoder(
    //inputs
    .insn(DATA_BUS),
    .so(SO),
    .rdy(RDY),
    .nmi(NMI),
    .irq(IRQ),

    //outputs,
    .rw(RW),

    .irxi(irxi),
    .iryi(iryi),
    .spri(spri),
    .ai(ai),
    .pchi(pchi),
    .pcli(pcli),
    .psri(psri),
    .iri(iri),

    .irxo(irxo),
    .iryo(iryo),
    .spro(spro),
    .ao(ao),
    .pcho(pcho),
    .pclo(pclo),
    .psro(psro),
    .iro(iro)

);

endmodule