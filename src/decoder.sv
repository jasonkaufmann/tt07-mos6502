module decoder (

    // INPUTS
    input wire [7:0] insn,

    input wire clk,
    input wire rst_n,

    input wire so,
    input wire rdy,
    input wire nmi,
    input wire irq,

    // OUTPUTS
    output reg rw, //low = read, high = write

    output reg irxi,
    output reg iryi,
    output reg spri,
    output reg ai,
    output reg pchi,
    output reg pcli,
    output reg psri,
    output reg iri,

    output reg irxo,
    output reg iryo,
    output reg spro,
    output reg ao,
    output reg pcho,
    output reg pclo,
    output reg psro,
    output reg iro,

    // alu control lines
    output reg target_bus,
    output reg subtract,
    
    output reg sum_sel,
    output reg and_sel,
    output reg xor_sel,
    output reg or_sel,
    output reg asl_sel,
    output reg lsr_sel,
    output reg rol_sel,
    output reg ror_sel

);

    wire [7:0] opcode;
    assign opcode = insn; // the opcode is the instruction itself

    //create a simple microclock that steps through the instruction execution sequence
    reg [2:0] microClk = 0; //most steps are max 6 cycles for 1 instruction

    // instantiate the pla decoder
    wire [25:0] control_signals;
    pla PLA (
        .opcode(opcode),
        .microcode_counter(microClk),
        .control_signals(control_signals)
    );
   
    // Microcode clock and opcode control
    always @(negedge clk or negedge rst_n) begin //on the falling edge of the clock or reset
        if (!rst_n) begin
            {rw, irxi, iryi, spri, ai, pchi, pcli, psri, iri, irxo, iryo, spro, ao, pcho, pclo, psro, iro, target_bus, subtract, sum_sel, and_sel, xor_sel, or_sel, asl_sel, lsr_sel, rol_sel, ror_sel} <= 25'b0; //set all 25 control lines to 0
        end else begin
            {rw, irxi, iryi, spri, ai, pchi, pcli, psri, iri, irxo, iryo, spro, ao, pcho, pclo, psro, iro, target_bus, subtract, sum_sel, and_sel, xor_sel, or_sel, asl_sel, lsr_sel, rol_sel, ror_sel} <= control_signals ; //set all 25 control lines to 0
        end
    end
endmodule
