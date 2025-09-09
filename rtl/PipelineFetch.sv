module PipelineFetch(
    input clk, 
    output reg [15:0] pc, 
    input reset
);
    always @(posedge clk)begin 
        pc <= (reset) ? 16'b0 : pc + 1;
    end
endmodule
