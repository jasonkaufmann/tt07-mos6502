module decoder (
    // Inputs
    input wire [7:0] insn,
    input wire clk,
    input wire rst,
    input wire prog_mode,
    input wire cf, 
    input wire zf,

    // Outputs
    output reg hlt,
    output reg mi,
    output reg ri,
    output reg ro,
    output reg io,
    output reg ii,
    output reg ai,
    output reg ao,
    output reg sumo,
    output reg sub,
    output reg bi,
    output reg oi,
    output reg ce, 
    output reg co,
    output reg j
);

    reg [2:0] microClk = 0;
    wire [3:0] opcode = insn[7:4]; // Extract the opcode from the instruction

    // Microcode clock and opcode control
    always @(negedge clk or negedge rst) begin

        if (!rst) begin
            microClk <= 0;
            {hlt, mi, ri, ro, io, ii, ai, ao, sumo, sub, bi, oi, ce, co, j} <= 15'b0;
            {mi, co} <= 2'b11;
        end else if (!prog_mode) begin
            {hlt, mi, ri, ro, io, ii, ai, ao, sumo, sub, bi, oi, ce, co, j} <= 15'b0;
            // Increment microClk or reset to 0 if it reaches the end of cycle
            microClk <= (microClk == 3'b101) ? 0 : microClk + 1;
            //microClk at 0 and 1 are always the same for all instructions (this is the fetch cycle)
            if(microClk == 3'b000) begin
                {mi, co} <= 2'b11;
            end else if(microClk == 3'b001) begin
                {ro, ii, ce} <= 3'b111;
            end else begin
                case (opcode)
                    4'b0000: begin  // NOP: No operation
                        case (microClk)
                            3'b010: {hlt, mi, ri, ro, io, ii, ai, ao, sumo, sub, bi, oi, ce, co, j} <= 15'b0; //set all control lines to 0
                            3'b011: {hlt, mi, ri, ro, io, ii, ai, ao, sumo, sub, bi, oi, ce, co, j} <= 15'b0; //set all control lines to 0
                            3'b100: {hlt, mi, ri, ro, io, ii, ai, ao, sumo, sub, bi, oi, ce, co, j} <= 15'b0; //set all control lines to 0
                            default: ;
                        endcase
                    end
                    4'b0001: begin  // LDA: Load A from memory
                        case (microClk)
                            3'b010: {mi, io} <= 2'b11;  // Set memory address, output from IR
                            3'b011: {ro, ai} <= 2'b11;  // Set RAM to output, load A register
                            default: ;
                        endcase
                    end
                    4'b0010: begin  // ADD: Add memory to A
                        case (microClk)
                            3'b010: {mi, io} <= 2'b11;
                            3'b011: {ro, bi} <= 2'b11;
                            3'b100: {ai, sumo} <= 2'b11;
                            default: ;
                        endcase
                    end
                    4'b0011: begin  // SUB: Subtract memory from A
                        case (microClk)
                            3'b010: {mi, io} <= 2'b11;
                            3'b011: {ro, bi} <= 2'b11;
                            3'b100: {ai, sumo, sub} <= 3'b111;
                            default: ;
                        endcase
                    end
                    4'b0100: begin  // STA: Store A into memory
                        case (microClk)
                            3'b010: {mi, io} <= 2'b11;  // Set memory address from IR
                            3'b011: {ao, ri} <= 2'b11;  // Set A register out, RAM data in
                            default: ;
                        endcase
                    end
                    4'b0101: begin  // LDI: Load immediate into A
                        case (microClk)
                            3'b010: {ii, ai} <= 2'b11;  // Set immediate to A register
                            default: ;
                        endcase
                    end
                    4'b0110: begin  // JMP: Jump to address
                        case (microClk)
                            3'b010: {io, j} <= 2'b11;  // Set instruction to jump
                            default: ;
                        endcase
                    end
                    4'b0111: begin  // JC: Jump if carry
                        case (microClk)
                            3'b010: begin
                                if (cf) begin  // If carry flag is set, jump
                                    {io, j} <= 2'b11;
                                end
                            end 
                            default: ;
                        endcase
                    end
                    4'b1000: begin  // JZ: Jump if zero
                        case (microClk)
                            3'b010: begin
                                if (zf) begin  // If zero flag is set, jump
                                    {io, j} <= 2'b11;
                                end
                            end 
                        endcase
                    end
                    4'b1110: begin  // OUT: Output from A to output device
                        case (microClk)
                            3'b010: {ao, oi} <= 2'b11;  // Activate A register output to Output interface
                            default: ;
                        endcase
                    end
                    4'b1111: begin  // HLT: Halt the machine
                        hlt <= 1;  // Set halt immediately on opcode fetch
                    end
                    default: begin
                        if (microClk == 3'b101)  // Reset signals at the end of cycle
                            {mi, co} <= 2'b11;  // Default action to prepare for next instruction
                    end
                endcase
            end
        end   
    end
endmodule
