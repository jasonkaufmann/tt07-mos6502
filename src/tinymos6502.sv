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
assign SYNC = 1'b1; //always in sync mode

//define the buses in the CPU (yes, this has tri-state logic, yosys has limited support for this which I hope should work?)
wire [BUS_WIDTH - 1 : 0] DATA_BUS; 
wire [BUS_WIDTH - 1 : 0] ACCUMULATOR; 
wire [BUS_WIDTH - 1 : 0] PROCESSOR_STATUS;
wire [BUS_WIDTH - 1 : 0] ADH;
wire [BUS_WIDTH - 1 : 0] ADL;

assign ADDRESS = {ADH, ADL};

//define all the registers of the 6502
register #(.n(BUS_WIDTH))          INDEX_REGISTER_X (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(irxi), .data_out(DATA_BUS), .output_enable(irxo));
register #(.n(BUS_WIDTH))          INDEX_REGISTER_Y (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(iryi), .data_out(DATA_BUS), .output_enable(iryo));
register #(.n(ADDRESS_WIDTH))      STACK_POINTER    (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(spri), .data_out(DATA_BUS), .output_enable(spro));
register #(.n(BUS_WIDTH))          PCH              (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(pchi), .data_out(ADH),      .output_enable(pcho));
register #(.n(BUS_WIDTH))          PCL              (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(pcli), .data_out(ADL),      .output_enable(pclo));
register #(.n(BUS_WIDTH))          INSTRUCTION      (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(iri),  .data_out(DATA_BUS), .output_enable(iro) );

//register with internal state availble to outside blocks
//OIS = Output Internal State
register #(.n(BUS_WIDTH), .OIS(1)) ACCUMULATOR      (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(ai),   .data_out(DATA_BUS), .output_enable(ao),   .data_stored_out(ACCUMULATOR));

//PSR (Processor status register) bits (its not really a register, but a collection of flags)
wire                       neg_result, overflow, expansion, break_command, decimal_mode, interrupt_disable, zero_result, carry
assign PROCESSOR_STATUS = {neg_result, overflow, expansion, break_command, decimal_mode, interrupt_disable, zero_result, carry};

assign overflow = alu_overflow | SO; //if the ALU overflowed or the SO pin is high, then the overflow flag is high
assign carry = alu_carry;
assign zero_result = alu_zero;
assign neg_result = alu_negative;

//ALU control bits
wire sum_sel, and_sel, xor_sel, or_sel, asl_sel, lsr_sel, rol_sel, ror_sel;
//sum select, and select, xor select, or select, arithmetic shift left select, logical shift right select, rotate left select, rotate right select

//ALU output flags
wire alu_overflow, alu_carry, alu_zero, alu_negative;

//define the ALU
alu alu #(.n(BUS_WIDTH)) (
    .a(ACCUMULATOR), 
    .mem(DATA_BUS), 

    .subtract(subtract),
    .sum_sel(sum_sel),
    .and_sel(and_sel),
    .xor_sel(xor_sel),
    .or_sel(or_sel),
    .asl_sel(asl_sel),
    .lsr_sel(lsr_sel),
    .rol_sel(rol_sel),
    .ror_sel(ror_sel),

    .carry_in(carry),

    .out(DATA_BUS), 

    .overflow(alu_overflow), 
    .carry(alu_carry),
    .zero(alu_zero),
    .negative(alu_negative)
);

//make all the control lines to all the registers
wire irxi, iryi, spri, ai, pchi, pcli, psri, iri; //input enable (load) lines for register
wire irxo, iryo, spro, ao, pcho, pclo, psro, iro; //output enable lines for register

//make the instruction decoder
decoder decoder(
    //inputs
    .insn(DATA_BUS),

    .clk(CLK),
    .rst_n(RST_N),

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