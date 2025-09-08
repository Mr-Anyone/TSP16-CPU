module Regfile(
    input wire write, 
    input [2:0] write_reg_num, 
    input [15:0] write_data,
    input [2:0] read_reg_num, 
    input clk,

    output [15:0] output_one
);
    wire [7:0] write_reg_onehot;
    ToOneHot onehot(
        .num(write_reg_num), 
        .onehot(write_reg_onehot)
    );

    wire [15:0] register_outputs [7:0];

    // Generate the register file
    genvar i; // for the for loop inside?
    generate 
        for (i=0; i<8; i=i+1) begin 
            Register register(
                .clk(clk), 
                .write(write & write_reg_onehot[i]), 
                .in(write_data),

                .out(register_outputs[i])
            );
        end
    endgenerate

    assign output_one = register_outputs[read_reg_num];
endmodule
