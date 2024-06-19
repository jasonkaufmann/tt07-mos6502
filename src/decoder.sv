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
    output wire rw, //low = read, high = write

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

    //create a simple microclock that steps through the instruction execution sequence
    reg [2:0] microClk = 0; //most steps are max 6 cycles for 1 instruction

    reg [1:0] state; //store the current state in the state machine
    /*******************/

    // Microcode clock and opcode control
    always @(negedge clk or negedge rst) begin //on the falling edge of the clock or reset
        if (!rst_n) begin
            microClk <= 0;
            state <= FETCH; //start the state machine
            {rw, irxi, iryi, spri, ai, pchi, pcli, psri, iri, irxo, iryo, spro, ao, pcho, pclo, psro, iro} <= 16'b0; //set all control lines to 0
        end else begin
            {rw, irxi, iryi, spri, ai, pchi, pcli, psri, iri, irxo, iryo, spro, ao, pcho, pclo, psro, iro} <= 16'b0; //set all control lines to 0
            
            // Increment microClk or reset to 0 if it reaches the end of cycle
            microClk <= (microClk == 3'b101) ? 0 : microClk + 1;
            case (state)
                FETCH: begin
                    rw <= 1'b0;   //read from memory
                    pcho <= 1'b1; //output the program counter high byte
                    pclo <= 1'b1; //load the program counter low byte
                    state <= DECODE;
                end
                DECODE: begin
                    case (microClk)

                    endcase
                    if (rdy) begin
                        irxi <= 1'b1; //load the instruction register
                        iryo <= 1'b1; //output the instruction register
                        //state <= STORE;
                    end
                end
                STORE: begin
                end
            endcase
        end
    end
endmodule
