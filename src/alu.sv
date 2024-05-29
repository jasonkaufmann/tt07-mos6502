module alu (
    input wire [7:0] a,
    input wire [7:0] b,
    input sub,
    
    output wire [7:0] out,
    output zeroFlag,
    output carryFlag 
    );

    wire [7:0] bTwosComplement; //create an intermediate for the two's complement for clarity
    wire [7:0] sub8 = {8{sub}}; //extend sub to 8 bits

    assign bTwosComplement = b ^ sub8; //if we want to subtract, xor the b register with 1 to invert it

    assign out = a + bTwosComplement + {7'b0, sub}; //if subtracting add the sub bit as the carry in bit

    assign zeroFlag = &out;
    assign carryFlag = (a[7] & b[7] & !out[7]) | (!a[7] & !b[7] & out[7]);

endmodule
