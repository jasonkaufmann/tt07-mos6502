module decoder (

    // INPUTS
    input wire [7:0] insn,

    input wire clk,
    input wire rst,

    input wire so,
    input wire rdy,
    input wire nmi,
    input wire irq,

    // OUTPUTS
    output wire rw,
    output wire irxi,
    output wire iryi,
    output wire spri,
    output wire ai,
    output wire pchi,
    output wire pcli,
    output wire psri,
    output wire iri,
    output wire irxo,
    output wire iryo,
    output wire spro,
    output wire ao,
    output wire pcho,
    output wire pclo,
    output wire psro,
    output wire iro
);

    assign opcode = insn; // the opcode is the instruction itself

    /** STATE MACHINE **/
    parameter FETCH = 2'b00;
    parameter DECODE = 2'b01;
    parameter STORE = 2'b10;

    reg [1:0] state; //store the current state in the state machine
    /*******************/

    // Microcode clock and opcode control
    always @(negedge clk or negedge rst) begin
        if (!rst_n) begin
            state <= FETCH; //start the state machine
        end else begin
            case (state)
                FETCH: begin
                end
                DECODE: begin
                end
                STORE: begin
                end
            endcase
        end
    end
endmodule
