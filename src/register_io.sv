// This is an n-bit register with load, output enable, and asynchronous clear signals

module register_io #(parameter n = 8) ( //OIS = Output Internal State
    input clk,
    input rst_n, // Active low asynchronous reset

    input [n-1:0] data_in, // Data to be loaded in
    input load,
    input output_enable,

    output wire [n-1:0] data_out // Data to be stored
);
    reg [n-1:0] data_stored;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_stored <= {n{1'b0}}; // Asynchronous clear
        end else if (load) begin
            data_stored <= data_in;   // Load data
        end
    end

    assign data_out = output_enable ? data_stored : {n{1'bZ}};

endmodule