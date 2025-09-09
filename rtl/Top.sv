/// This is basically the CPU 
/// We will be having a few pipeline stages
module Top(
    input clk,
    input reset
);
    // Stalling
    wire stall_decode, stall_execute;

    // starting the fetch pipeline
    // We start by getting the memory
    wire [15:0] fetch_pc, fetch_instr;
    PipelineFetch fetch_pipeline(
        // input
        .clk(clk),
        .reset(reset),
        // outputs
        .pc(fetch_pc) 
    );

    wire [2:0] execute_rm_num, execute_rn_num;
    wire [15:0] execute_rm, execute_rn;
    wire writeback_write_to_regfile; // be populated from Pipeline Writeback
    wire [15:0] writeback_data;
    wire [2:0] writeback_writenum;
    Regfile regfile(
        // write related
        .write(writeback_write_to_regfile),
        .write_reg_num(writeback_writenum),
        .write_data(writeback_data),
        .clk(clk), 

        // read
        .read_reg_num(execute_rm_num),
        .read_reg_num_two(execute_rn_num),
        .output_one(execute_rm), 
        .output_two(execute_rn)
    );

    // execute pipeline
    wire execute_done, execute_is_dependent;
    wire [15:0] execute_result, execute_instr;
    PipelineExecute execute_pipeline(
        // clock related thingy
        .clk(clk),
        .reset(reset),
        .instr(fetch_instr),
        // regfile input
        .rn(execute_rn),
        .rm(execute_rm),
        // data forwarding
        .memory_done(memory_done),
        .memory_is_dependent(memory_is_dependent),
        .memory_result(memory_result),
        .memory_instr(memory_instr),


        .execute_done(execute_done),
        .execute_is_dependent(execute_is_dependent),
        .execute_result(execute_result),
        .execute_instr(execute_instr),

        // regfile number
        .rn_num(execute_rn_num),
        .rm_num(execute_rm_num)
    );

    wire memory_done, memory_is_dependent;
    wire [15:0] memory_result, memory_instr;
    PipelineMemory memory_pipeline(
        .clk(clk),
        .reset(reset),

        // from previous pipeline
        .execute_done(execute_done),
        .execute_is_dependent(execute_is_dependent),
        .execute_result(execute_result),
        .execute_instr(execute_instr),

        // output
        .memory_done(memory_done),
        .memory_is_dependent(memory_is_dependent),
        .memory_result(memory_result),
        .memory_instr(memory_instr)
    );

    PipelineWriteback writeback_pipeline(
        // .clk(clk),
        .reset(reset),
        // from memory pipeline
        .memory_done(memory_done),
        .memory_is_dependent(memory_is_dependent),
        .memory_result(memory_result),
        .memory_instr(memory_instr),

        // output
        .write(writeback_write_to_regfile),
        .write_reg_num(writeback_writenum),
        .to_regfile(writeback_data)
    );

    wire [15:0] read_output; // FIXME: move to somewhere else
    Memory memory(
        .clk(clk), 
        .write(0'b0), // FIXME: this needs to be set during memory stages
        .write_address(16'b0), // FIXME: this to
        .write_input(16'b0), // FIXME: this to

        .read_address(16'b0), // FIXME: this to
        .pc(fetch_pc),
        .fetch_instr(fetch_instr),
        .read_output(read_output)
    );
endmodule
