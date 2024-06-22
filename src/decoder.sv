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
    output reg ror_sel,

);

    wire [7:0] opcode;
    assign opcode = insn; // the opcode is the instruction itself

    /** STATE MACHINE **/
    parameter FETCH = 2'b00;
    parameter DECODE = 2'b01;
    parameter STORE = 2'b10;

    //create a simple microclock that steps through the instruction execution sequence
    //reg [2:0] microClk = 0; //most steps are max 6 cycles for 1 instruction

    reg [1:0] state; //store the current state in the state machine
    /*******************/

    /* Addressing Mode Mapping:
    'A'     ->  '4'b0000'    # Accumulator
    '#'     ->  '4'b0001'    # Immediate
    'zpg'   ->  '4'b0010'    # Zero Page
    'zpg,X' ->  '4'b0011'    # Zero Page,X
    'zpg,Y' ->  '4'b0100'    # Zero Page,Y
    'abs'   ->  '4'b0101'    # Absolute
    'abs,X' ->  '4'b0110'    # Absolute,X
    'abs,Y' ->  '4'b0111'    # Absolute,Y
    'ind'   ->  '4'b1000'    # Indirect
    'X,ind' ->  '4'b1009'    # Indirect,X
    'ind,Y' ->  '4'b1010'    # Indirect,Y
    'impl'  ->  '4'b1011'    # Implied
    'rel'   ->  '4'b1100'    # Relative
    */
    wire [3:0] addr_mode;
    opcode_decoder opcode_decoder(
        .opcode(opcode),
        .addr_mode(addr_mode)
    );
   

    // Microcode clock and opcode control
    always @(negedge clk or negedge rst_n) begin //on the falling edge of the clock or reset
        if (!rst_n | !rdy) begin
            state <= FETCH; //start the state machine
            {rw, irxi, iryi, spri, ai, pchi, pcli, psri, iri, irxo, iryo, spro, ao, pcho, pclo, psro, iro} <= 16'b0; //set all control lines to 0
        end else begin
            {rw, irxi, iryi, spri, ai, pchi, pcli, psri, iri, irxo, iryo, spro, ao, pcho, pclo, psro, iro} <= 16'b0; //set all control lines to 0
            case (state)
                FETCH: begin
                    rw <= 1'b0;   //read from memory
                    pcho <= 1'b1; //output the program counter high byte
                    pclo <= 1'b1; //load the program counter low byte
                    state <= DECODE;
                end
                DECODE: begin
                    iri <= 1'b1; //load the instruction register
                    iro <= 1'b1; //output the instruction register

                    case (addr_mode)
                        4'b0000: begin //accumulator
                            
                        end
                        4'b0001: begin //immediate
                        
                        end
                        4'b0010: begin //zero page
                        
                        end
                        4'b0011: begin //zero page, X
                            
                        end
                        4'b0100: begin //zero page, Y
                            
                        end
                        4'b0101: begin //absolute
                            
                        end
                        4'b0110: begin //absolute, X
                            
                        end
                        4'b0111: begin //absolute, Y
                            
                        end
                        4'b1000: begin //indirect
                            
                        end
                        4'b1001: begin //indirect, X
                            
                        end
                        4'b1010: begin //indirect, Y
                            
                        end
                        4'b1011: begin //implied
                            
                        end
                        4'b1100: begin //relative
                            
                        end
                    endcase
                end
                STORE: begin
                end
            endcase
        end
    end
endmodule
