`include "Constant.sv"

// Essentially, this performs the 
module ArithmeticLogicUnit(
    input reg [15:0] rn, 
    input reg [15:0] rm, 
    input reg [15:0] instr,

    output reg [15:0] rd,
    output wire z, 
    output wire n

);
    wire [1:0] instr_cond = instr[15:14]; 
    wire [1:0] r_cond = instr[13:12]; 
    wire [4:0] alu_op = instr[13:9];
    wire [8:0] imm = instr[11:3];

    always_comb begin 
        rd = 16'b0; // default fallthrough

        // we have
        if(instr_cond == `A_TYPE) begin  
            // we have to switch
            case(alu_op)
                `ADD: rd = rn + rm;
                `EQUAL: rd = rn;
                `OR: rd = rn | rm;
                `AND: rd = rn & rm; 
                `MINUS: rd = rn + (~rm + 1);
                default: begin
                    // I am not quite sure how you can get here
                    rd = 16'b0;
                    $warning("you really shouldn't be here. undefined behavior?");
                end
            endcase
        end else if(instr_cond == `R_TYPE) begin
            case(r_cond)
                2'b00: rd = {7'b0, imm}; // zext
                2'b11: rd = {(imm[8] == 1'b1) ? 7'b1111111: 7'b0 // the high 7 bit
                                    , imm}; // low 9 bit 
                default: begin 
                    rd = 16'b0;
                    $warning("R type cond is not implemented as of current");
                end
            endcase
        end
    end

    // status register
    assign n = rd[15];
    assign z = rd == 16'b0;
endmodule
