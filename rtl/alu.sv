`define A_TYPE 2'b00
`define M_TYPE 2'b01
`define R_TYPE 2'b10
`define B_TYPE 2'b11

`define ADD 5'b00000
`define EQUAL 5'b00001
`define OR 5'b00010
`define AND 5'b00011
`define MINUS 5'b00100

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
            // these are other type of instructions
            rd = 16'b0;
        end

    end

endmodule
