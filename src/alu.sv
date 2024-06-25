module alu #(parameter n = 8) (
    input wire [n-1:0] a,   //the accumulator
    input wire [n-1:0] mem, //the data memory

    //dataflow control
    input wire subtract,   
    input wire target_bus, //0 = accumulator, 1 = memory

    //output control
    input wire sum_sel,
    input wire and_sel,
    input wire xor_sel,
    input wire or_sel,
    input wire asl_sel,
    input wire lsr_sel,
    input wire rol_sel,
    input wire ror_sel,

    input wire carry_in,
    
    output wire [7:0] out,

    output wire overflow,
    output wire carry,
    output wire zero,
    output wire negative
);

    wire [n:0] sum_val, and_val, xor_val, or_val, asl_val, lsr_val, rol_val, ror_val;
    wire [n-1:0] mem_to_sum;

    assign mem_to_sum = subtract ? ~mem : mem; //invert the b register if we are subtracting
    assign sum_val = a + (mem_to_sum + subtract) + subtract? {8{~carry_in}} : carry_in;
    assign and_val = a & mem;
    assign xor_val = a ^ mem;
    assign or_val =  a | mem;
    assign asl_val = target_bus ? mem <<< 1 : a <<< 1;
    assign lsr_val = target_bus ? mem >> 1 : a >> 1;
    assign rol_val = target_bus ? mem << 1 & carry_in : a << 1 & carry_in;
    assign ror_val = target_bus ? mem >> 1 & carry_in : a >> 1 & carry_in;

    assign out = (sum_sel ? sum_val : 
                  and_sel ? and_val : 
                  xor_sel ? xor_val : 
                  or_sel  ? or_val  : 
                  asl_sel ? asl_val : 
                  lsr_sel ? lsr_val : 
                  rol_sel ? rol_val : 
                  ror_sel ? ror_val : 0);

    wire [n-1:0] overflow_hold;
    assign overflow_hold = ((a ^ out) & (mem ^ out)); //if the sign bit of a and b are different from the sign bit of the result, then overflow
    assign overflow = overflow_hold[n-1]; //if the sign bit of a and b are different from the sign bit of the result, then overflow
    assign negative = out[n-1]; //the most significant bit is the sign bit
    assign zero = ~|out; //if any bit is high, then the result is not zero
    assign carry = (sum_val[n] | asl_val[n] | rol_val[n] | ror_val[n]) & ~subtract; //if the most significant bit is high, then carry

endmodule
