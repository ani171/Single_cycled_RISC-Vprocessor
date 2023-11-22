module exemux (
	input bit clk,
    input logic alu_src,
    input logic  [31:0] imm32,
	 input logic  [31:0] rdata2,
    output logic [31:0] rdata3
);

always @(posedge clk) begin 
    case (alu_src)
       1'b0 : rdata3 = rdata2;
       1'b1 : rdata3 = imm32;
    endcase
    
end
    
endmodule