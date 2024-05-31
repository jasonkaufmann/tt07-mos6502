module alu (parameter n = 8) (
    input wire [n-1:0] a,
    input wire [n-1:0] b,

    input wire sum_sel,
    input wire and_sel,
    input wire xor_sel,
    input wire or_sel,
    input wire shift_right_sel,

    input wire carry_in,
    
    output wire [7:0] out,

    output wire overflow,
    output wire carry,
    output wire half_carry, 
);

    wire [n-1:0] sum_val, and_val, xor_val, or_val, shift_right_sel;

    assign sum_val = a + b;
    assign and_val = a & b;
    assign xor_val = a ^ b;
    assign or_val =  a | b;


    wire [n-1:0] bTwosComplement; //create an intermediate for the two's complement for clarity
    wire [7:0] sub8 = {8{sub}}; //extend sub to 8 bits

    assign bTwosComplement = b ^ sub8; //if we want to subtract, xor the b register with 1 to invert it

    assign out = a + bTwosComplement + {7'b0, sub}; //if subtracting add the sub bit as the carry in bit

    assign zeroFlag = &out;
    assign carryFlag = (a[7] & b[7] & !out[7]) | (!a[7] & !b[7] & out[7]);

endmodule
