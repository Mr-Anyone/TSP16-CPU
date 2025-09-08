module Register(
    input wire clk,
    input wire write,
    input wire [15:0] in,

    output reg [15:0] out
);
    wire [15:0] next_clk = (write) ? in : out;

    always @(posedge clk) begin 
        out <= next_clk;
    end
endmodule

