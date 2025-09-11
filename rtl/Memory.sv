module Memory(
    input clk,
    // for write
    input wire write, 
    input reg [15:0] write_address,
    input reg [15:0] write_input,
    // reading, both buses
    input reg [15:0] read_address,
    input reg [15:0] next_pc,
    input reg [15:0] pc, // the PC bus

    output reg [15:0] read_output,
    output reg [15:0] fetch_instr,
    output reg [15:0] fetch_next_instr
);
    reg [15:0] mem[65535 : 0]; // memory module with 2^16 location, each location has 16 bit

    always_ff @(posedge clk) begin 
        if(write) begin 
            mem[write_address] <= write_input;
        end
    end

    assign read_output = mem[read_address];
    assign fetch_instr = mem[pc];
    assign fetch_next_instr = mem[next_pc];
endmodule
