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
    input [15:0] memory_data_from_ram,
    // from reg file 
    input [15:0] memory_rn, 

    // for data forwarding
    output reg memory_done,
    output reg memory_is_dependent,
    output reg [15:0] memory_result,
    output reg [15:0] memory_instr, 
    // for reading and writing into memory
    output wire [15:0] memory_read_address,
    output wire [15:0] memory_write_address,
    output wire memory_write,
    // for regfile so that we can read
    output wire [2:0] memory_rn_num
);
    // FIXME: there need a data forwarding logic here!
    assign memory_rn_num = execute_instr[5:3];

    assign memory_read_address =  memory_rn; // we have to forward data I guess
    assign memory_write_address = memory_rn; // we have to forward data I guess
    assign memory_write = (4'b0101 == execute_instr[15:12]) ? 1'b1 : 1'b0; // we have a STR instruction

    // here we execute M type instruction
    reg [15:0] next_memory_result;
    always_comb begin
        next_memory_result = execute_result; // fallthrough
        if(execute_instr[15:12] == 4'b0100) // this is a LDR and we have a data dependnecy
            next_memory_result = memory_data_from_ram;
    end

    always_ff @(posedge clk) begin 
        // The ISA is designed so such by the time it made it here,
        memory_done <= (reset) ? (1'b0) : 1'b1; 
        memory_is_dependent <= (reset) ? (1'b0) : execute_is_dependent; // this is computed 
                                                                        // in the execute stage
        memory_result <= (reset) ? (16'b0) : next_memory_result;
        memory_instr <= (reset) ? (16'b0) : execute_instr;
    end
endmodule

