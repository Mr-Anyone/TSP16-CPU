module PipelineFetch(
    input clk, 
    input reset,
    // status flags from execute pipelien
    input execute_z,
    input execute_v,
    input execute_n,
    // input from other pipeline
    input [15:0] fetch_instr,
    input [15:0] next_instr,

    // from execute pipeline
    input execute_stall,
    // output
    output reg [15:0] pc
);
    // first question we  
    reg fetch_stall;   
    always_comb begin 
        fetch_stall = 1'b0;
        if(execute_stall) begin
            fetch_stall = 1'b1;
        end else if (fetch_instr[15:9] == 7'b0000101) begin
            // we basically have a cmp instruction
            fetch_stall = 1'b1;
        end
    end

    reg [15:0] next_pc;
    always_comb begin
        if(reset) begin 
            next_pc = 16'b0;
        end else if(fetch_stall) begin 
            next_pc = pc;
        end else begin 
            // FIXME: add a testcase for the following:
            next_pc = pc + 1;
        end
    end


    always @(posedge clk)begin 
        // when we stall the pc should remain the same 
        pc <= next_pc; 
    end
endmodule
