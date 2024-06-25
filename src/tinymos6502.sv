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

assign OUTPUT_ENABLE = RW ? 8'b1 : 8'b0; // if RW is high, make uio_oe an input, otherwise make it an output
assign SYNC = 1'b1; //always in sync mode
assign DATA_OUT = {8{1'bZ}}; //output data is always high impedance

//define the buses in the CPU (yes, this has tri-state logic, yosys has limited support for this which I hope should work?)
wire [BUS_WIDTH - 1 : 0] DATA_BUS; 
wire [BUS_WIDTH - 1 : 0] INSTR_BUS; 
wire [BUS_WIDTH - 1 : 0] PROCESSOR_STATUS;
wire [BUS_WIDTH - 1 : 0] ACCUMULATOR_OUT;
wire [BUS_WIDTH - 1 : 0] ADH;
wire [BUS_WIDTH - 1 : 0] ADL;
wire [BUS_WIDTH - 1 : 0] STACK_POINTER_OUT;
wire [BUS_WIDTH - 1 : 0] INDEX_REGISTER_X_OUT;
wire [BUS_WIDTH - 1 : 0] INDEX_REGISTER_Y_OUT;
wire [BUS_WIDTH - 1 : 0] DATA_BUFFER_OUT;
wire [BUS_WIDTH - 1 : 0] ALU_OUT;

assign ADH = ADDRESS[ADDRESS_WIDTH - 1 : BUS_WIDTH];
assign ADL = spro ? STACK_POINTER_OUT : ADDRESS[BUS_WIDTH - 1 : 0];

//create the program counter
program_counter PROGRAM_COUNTER(
    .clk(CLK),
    .rst(RST_N),
    .jump(1'b0),
    .countEnable(1'b1),
    .jumpAddr(16'b0),
    .addr(ADDRESS)
);

//define all the registers of the 6502
register_io #(.n(BUS_WIDTH))          INDEX_REGISTER_X (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(irxi), .data_out(INDEX_REGISTER_X_OUT),  .output_enable(irxo));
register_io #(.n(BUS_WIDTH))          INDEX_REGISTER_Y (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(iryi), .data_out(INDEX_REGISTER_Y_OUT),  .output_enable(iryo));
register_io #(.n(BUS_WIDTH))          DATA_BUFFER      (.clk(CLK), .rst_n(RST_N), .data_in(DATA_IN),  .load(iri),  .data_out(DATA_BUFFER_OUT),  .output_enable(iro) );

//register with internal state availble to outside blocks
//OIS = Output Internal State
register_i  #(.n(BUS_WIDTH))          ACCUMULATOR      (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(ai),   .data_out(ACCUMULATOR_OUT)   );
register_i  #(.n(BUS_WIDTH))          INSTRUCTION      (.clk(CLK), .rst_n(RST_N), .data_in(DATA_IN),  .load(iri),  .data_out(INSTR_BUS)         );
register_i  #(.n(BUS_WIDTH))          STACK_POINTER    (.clk(CLK), .rst_n(RST_N), .data_in(DATA_BUS), .load(spri), .data_out(STACK_POINTER_OUT) );

assign aluo = sum_sel | and_sel | xor_sel | or_sel | asl_sel | lsr_sel | rol_sel | ror_sel;
assign DATA_BUS = irxo ? INDEX_REGISTER_X_OUT : iryo ? INDEX_REGISTER_Y_OUT : iri ? DATA_BUFFER_OUT : aluo ? ALU_OUT : {BUS_WIDTH{1'bZ}};

//PSR (Processor status register) bits (its not really a register, but a collection of flags)
wire                       neg_result, overflow, expansion, break_command, decimal_mode, interrupt_disable, zero_result, carry;
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

wire target_bus, subtract; 

//define the ALU
alu #(.n(BUS_WIDTH)) ALU (
    //inputs
    .a(ACCUMULATOR_OUT), 
    .mem(DATA_BUS), 

    .target_bus(target_bus), 

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

    //outputs
    .out(ALU_OUT), 

    .overflow(alu_overflow), 
    .carry(alu_carry),
    .zero(alu_zero),
    .negative(alu_negative)
);

//make all the control lines to all the registers
wire irxi, iryi, spri, ai, pchi, pcli, psri, iri; //input enable (load) lines for register
wire irxo, iryo, spro, ao, pcho, pclo, psro, iro, aluo; //output enable lines for register


//make the instruction decoder
decoder decoder(
    //inputs
    .insn(INSTR_BUS),

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
    .iro(iro),

    .target_bus(target_bus),
    .subtract(subtract),

    //ALU control lines
    .sum_sel(sum_sel),
    .and_sel(and_sel),
    .xor_sel(xor_sel),
    .or_sel(or_sel),
    .asl_sel(asl_sel),
    .lsr_sel(lsr_sel),
    .rol_sel(rol_sel),
    .ror_sel(ror_sel)

);

endmodule