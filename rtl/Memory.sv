module Memory(
    input wire write, 
    input clk,
    input reg [15:0] write_address,
    input reg [15:0] write_input,
    input reg [15:0] read_address,

    output reg [15:0] read_output 
);
    reg [15:0] mem[65535 : 0]; // memory module with 2^16 location, each location has 16 bit

    always_ff @(posedge clk) begin 
        if(write) begin 
            mem[write_address] <= write_input;
        end
    end

    assign read_output = mem[read_address];
endmodule