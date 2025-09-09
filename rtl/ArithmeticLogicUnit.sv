`include "Constant.sv"

// Essentially, this performs the 
module ArithmeticLogicUnit(
    input reg [15:0] rn, 
    input reg [15:0] rm, 
    input reg [15:0] instr,

    output reg [15:0] rd
);
    wire [1:0] instr_cond = instr[15:14]; 
    wire [13:9] alu_op = instr[13:9];

    always_comb begin 
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
        end else begin 
            // these are other type of instructions, we define 0 here because
            // this is combinational logic.
            rd = 16'b0;
        end

    end

endmodule
