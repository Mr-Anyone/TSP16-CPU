`include "Constant.sv"

module PipelineWriteback(
    // clock input
    // input clk, 

    // from previous stage of the pipeline
    input memory_done, 
    input memory_is_dependent, 
    input [15:0] memory_result, 
    input [15:0] memory_instr,

    // output 
    output reg write,
    output reg [2:0] write_reg_num,
    output wire [15:0] to_regfile
);
    assign to_regfile = memory_result;
    assign write_reg_num = memory_instr[2:0];

    always_comb begin 
        if (memory_instr[15:14] == `A_TYPE || memory_instr[15:14] == `R_TYPE 
            || memory_instr[15:12] == 4'b1000) begin 
            write = 1'b1;
        end else begin 
            write = 1'b0;
        end
    end
endmodule
