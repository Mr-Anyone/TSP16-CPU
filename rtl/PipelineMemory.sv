module PipelineMemory(
    input clk, 
    // from the pipeline stages
    input execute_done, 
    input execute_is_dependent, 
    input [15:0] execute_result, 
    input [15:0] execute_instr,

    // for data forwarding
    output reg memory_done,
    output reg memory_is_dependent,
    output reg [15:0] memory_result,
    output reg [15:0] memory_instr
);

    always_ff @(posedge clk) begin 
        memory_done <= execute_done;
        memory_is_dependent <= execute_is_dependent;
        memory_result <= execute_result;
        memory_instr <= execute_instr;
    end
endmodule

