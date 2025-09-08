module register(
    input clk,
    input write, 

    output data
);

    always @(posedge clk) begin 
        data <= write;
    end
    
endmodule
