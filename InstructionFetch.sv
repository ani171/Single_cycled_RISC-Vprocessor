module InstructionFetch(
    input bit clk,            
    output bit [31:0] instruction 
);

    bit [31:0] pc_next;  

    ProgramCounter PC (
        .clk(clk),
        .pc_sel(2'b00),      
        .imm(32'h0),                 
        .pc_out(pc_next)     
    );


    MyMemory memory (
       .clk(clk),
       .address(pc_next),
       .data(instruction)
    );

endmodule
