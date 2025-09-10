`include "Constant.sv"

module PipelineMemory(
    input clk, 
    input reset,
    // from the pipeline stages
    input execute_done, 
    input execute_is_dependent, 
    input [15:0] execute_result, 
    input [15:0] execute_instr,
    // inputs from memory module

    // for data forwarding
    output reg memory_done,
    output reg memory_is_dependent,
    output reg [15:0] memory_result,
    output reg [15:0] memory_instr, 
    // for reading and writing into memory
    
);
    // here we execute M type instruction
    wire[15:0] next_memory_result;
    assign memory_address_bus = execute_instr[];
    always_comb begin
        next_memory_result = execute_result; // fallthrough
        if(instr[15:12] == 2'b0100)
            next_memory_result = mem_read;
    end

    always_ff @(posedge clk) begin 
        // The ISA is designed so such by the time it made it here,
        memory_done <= (reset) ? (1'b0) : 1'b1; 
        memory_is_dependent <= (reset) ? (1'b0) : execute_is_dependent; // this is computed 
                                                                        // in the execute stage
        memory_result <= (reset) ? (16'b0) : execute_result;
        memory_instr <= (reset) ? (16'b0) : execute_instr;
    end
endmodule

