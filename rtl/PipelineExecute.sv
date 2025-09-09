`include "Constant.sv"

// IMPORTANT: this assumes that it is always valid to forward 
// and that stalling logic must be handled in a different unit
module DataForwardUnit(
    // memory unit
    input wire memory_is_dependent,
    input wire [15:0] memory_result,
    input wire [15:0] memory_instr,
    // execute unit
    input wire execute_is_dependent,
    input wire [15:0] execute_result,
    input wire [15:0] execute_instr,
    // regfile 
    input wire [15:0] data_from_regfile, // this must be from reg_num
    input wire [2:0] reg_num,

    output reg [15:0] forwarded_data
); 
    always_comb begin 
        if(execute_is_dependent && execute_instr[2:0] == reg_num) begin 
            forwarded_data = execute_result;
        end else if (memory_is_dependent && memory_instr[2:0] == reg_num) begin 
            forwarded_data = memory_result;
        end else begin 
            forwarded_data = data_from_regfile;
        end
    end
endmodule

module PipelineExecute(
    // input from pipeline fetch
    input clk,
    input reset,
    input wire [15:0] instr, 
    // input from the register files
    wire [15:0] rn,
    wire [15:0] rm,
    // data forwarding options
    input reg memory_done, 
    input reg memory_is_dependent,
    input reg [15:0] memory_result,
    input reg [15:0] memory_instr,

    // output 
    // checking for hazard and data dependency
    output reg execute_done, 
    output reg execute_is_dependent,
    output reg [15:0] execute_result,
    output reg [15:0] execute_instr,
    // outputting the signals to the regfile, so that we 
    // have the register input
    output wire [2:0] rn_num,
    output wire [2:0] rm_num
);
    // ===================== DATA FORWARDING ====================
    // ==========================================================
    wire [15:0] actual_rm;
    wire [15:0] actual_rn;
    DataForwardUnit rn_forward_unit(
        // data forwarding
        .memory_is_dependent(memory_is_dependent),
        .memory_result(memory_result),
        .memory_instr(memory_instr),
        .execute_is_dependent(execute_is_dependent),
        .execute_result(execute_result),
        .execute_instr(execute_instr),

        .data_from_regfile(rn),
        .reg_num(rn_num),
        .forwarded_data(actual_rn)
    );

    DataForwardUnit rm_forward_unit(
        // data forwarding
        .memory_is_dependent(memory_is_dependent),
        .memory_result(memory_result),
        .memory_instr(memory_instr),
        .execute_is_dependent(execute_is_dependent),
        .execute_result(execute_result),
        .execute_instr(execute_instr),

        .data_from_regfile(rm),
        .reg_num(rm_num),
        .forwarded_data(actual_rm)
    );

    wire [15:0] rd;
    ArithmeticLogicUnit alu(
        .rn(actual_rn),
        .rm(actual_rm),
        .instr(instr), 

        // rd output
        .rd(rd)
    );


    // computing execute_done, execute_is_dependent
    reg next_execute_done, next_execute_is_dependent;
    always_comb begin 
        // checking to see if we are done
        if(instr[15:14] == `A_TYPE || instr[15:14] == `R_TYPE)
            next_execute_done = 1'b1;
        else 
            next_execute_done = 1'b0;

        // checking to see if the instruction we are currently executing is
        // dependent
        if (instr[15:14] == `A_TYPE || instr[15:14] == `R_TYPE 
            || instr[15:12]==4'b1000)
            next_execute_is_dependent = 1'b1;
        else
            next_execute_is_dependent = 1'b0;
    end

    // computing the output 
    assign rm_num = instr[8:6];
    assign rn_num = instr[5:3];
    always_ff @(posedge clk) begin 
        // there is also stalling we have to consider
        execute_done <= (reset) ? (1'b0) : next_execute_done;
        execute_is_dependent <= (reset)  ? (1'b0): next_execute_is_dependent;
        execute_result <= (reset) ? (16'b0) : rd;
        execute_instr <= (reset) ? (16'b0) : instr;
    end
endmodule
