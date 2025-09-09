module PipelineFetch(
    input clk,
    output reg [15:0] pc
);
    always @(posedge clk)begin 
        pc <= pc + 1;
    end
endmodule
