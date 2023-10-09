module ProgramCounter(
    input bit clk,          
    input bit [1:0] pc_sel,  
    input bit [31:0] imm,    
    input bit branch_taken,  
    input bit jump,          
    output bit [31:0] pc_out  
);

    always @(posedge clk) begin
        if (pc_sel == 2'b11) begin
            pc_out <= 32'b0; 
        end 
		  else if (pc_sel == 2'b00) begin 
            pc_out <= pc_out + 4; 
        end 
		  else if (pc_sel == 2'b01) begin 
            if (branch_taken) begin
                pc_out <= pc_out + imm; 
            end
        end 
		  else if (pc_sel == 2'b10) begin 
            if (jump) begin
                pc_out <= imm; 
            end
        end
    end
	 
endmodule
