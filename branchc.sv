module branchc (
	input bit clk,
	input bit btype,
    input bit [2:0]  funct3,
    input bit [6:0]  opcode,
    input bit [31:0] rdata1,
	 input bit [31:0] rdata2,
    output bit br_taken
);


parameter [2:0] BEQ  = 3'b000;

always @(posedge clk) begin
    case (opcode)
        7'b1100011 :begin  // B Type 
            case(funct3) 
                BEQ   : br_taken = (btype & (rdata1 == rdata2)) ;
					 
					 endcase
				end
				
		endcase
		
	end
	
endmodule