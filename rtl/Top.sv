/// This is basically the CPU 
/// We will be having a few pipeline stages
module Top(
    input clk,
    input reset
);
    // Stalling
    wire fetch_stall, execute_stall;

    // starting the fetch pipeline
    // We start by getting the memory
    wire [15:0] fetch_pc, fetch_instr, 
        fetch_next_pc, fetch_next_instr;
    PipelineFetch fetch_pipeline(
        // input
        .clk(clk),
        .reset(reset),
        .execute_stall(execute_stall),
        // status flags
        .execute_z(execute_z),
        .execute_v(execute_v),
        .execute_n(execute_n),
        // input from other pipeline
        .fetch_instr(fetch_instr),
        .next_instr(fetch_next_instr),

        // outputs
        .pc(fetch_pc)
    );

    wire [2:0] execute_rm_num, execute_rn_num;
    wire [15:0] execute_rm, execute_rn, memory_rd, memory_rn;
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
        .read_reg_num_three(memory_rn_num),
        .read_reg_num_four(memory_rd_num),
        .output_one(execute_rm), 
        .output_two(execute_rn),
        .output_three(memory_rn),
        .output_four(memory_rd)
    );

    // execute pipeline
    wire execute_done, execute_is_dependent, execute_z, execute_v, execute_n;
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
        .rm_num(execute_rm_num),
        // stalling for data
        .execute_stall(execute_stall),
        // status register 
        .execute_z(execute_z),
        .execute_v(execute_v),
        .execute_n(execute_n)
    );

    wire memory_done, memory_is_dependent, memory_write;
    wire [15:0] memory_result, memory_instr, 
        memory_data_from_ram, memory_read_address, memory_write_address, memory_write_data;
    wire [2:0] memory_rn_num, memory_rd_num;
    PipelineMemory memory_pipeline(
        .clk(clk),
        .reset(reset),

        // from previous pipeline
        .execute_done(execute_done),
        .execute_is_dependent(execute_is_dependent),
        .execute_result(execute_result),
        .execute_instr(execute_instr),
        // from memory module 
        .memory_data_from_ram(memory_data_from_ram),
        // from reg file
        .memory_rn(memory_rn),
        .memory_rd(memory_rd),

        // output
        .memory_done(memory_done),
        .memory_is_dependent(memory_is_dependent),
        .memory_result(memory_result),
        .memory_instr(memory_instr),
        // to memory 
        .memory_read_address(memory_read_address), 
        .memory_write_address(memory_write_address),
        .memory_write(memory_write),
        .memory_write_data(memory_write_data),
        // to regfile 
        .memory_rn_num(memory_rn_num),
        .memory_rd_num(memory_rd_num)
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

    Memory memory(
        .clk(clk), 
        .write(memory_write),
        .write_address(memory_write_address),
        .write_input(memory_write_data),

        .read_address(memory_read_address),
        .next_pc(fetch_next_pc),
        .pc(fetch_pc),

        .fetch_instr(fetch_instr),
        .fetch_next_instr(fetch_next_instr),
        .read_output(memory_data_from_ram)
    );
endmodule
