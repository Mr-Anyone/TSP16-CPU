`include "Constant.sv"

module PipelineExecute(
    // input from pipeline fetch
    input clk,
    input wire [15:0] instr, 
    // input from the register files
    wire [15:0] rn,
    wire [15:0] rm,

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
    wire [15:0] rd;
    ArithmeticLogicUnit alu(
        .rn(rn),
        .rm(rm),
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
        execute_done <= next_execute_done;
        execute_is_dependent <= next_execute_is_dependent;
        execute_result <= rd;
        execute_instr <= instr;
    end
endmodule
