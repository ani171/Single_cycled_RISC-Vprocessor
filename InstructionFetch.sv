module InstructionFetch(
    input bit clk,            
    output bit [31:0] instruction 
);

    bit signed [31:0] i;          
    bit b1;              
    bit zflag;          
    bit [31:0] pc_out;
	 bit [31:0] pc_next; 

    Program_Counter PC (
        .clk(clk),
        .branch(b1),      
        .imm(i), 
		  .zero_flag(zflag),
        .pc_out(pc_next)     
    );


    MyMemory memory (
       .clk(clk),
       .pc(pc_next),
       .instr(instruction)
    );

endmodule
