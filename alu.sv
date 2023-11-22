module alu (
	input bit clk,
	input bit alu_src,
    input logic  [4:0]  alu_op,
    input logic  [31:0] rdata1,
	 input logic  [31:0] rdata2,
    output logic [31:0] ALUResult
);


always @(posedge clk) begin
    case(alu_op)
	 
	 
    
    5'b00000: ALUResult = rdata1 + rdata2 ;                             //Addition

    5'b00001: ALUResult = rdata1 - rdata2 ;                             //Subtraction

    5'b00010: ALUResult = rdata1 << rdata2 [4:0];                        //Shift Left Logical

    5'b00101: ALUResult = rdata1 ^ rdata2;                              //LOgical xor

    5'b00110: ALUResult = rdata1 >> rdata2;                             //Shift Right Logical

    5'b00111: ALUResult = rdata1 >>> rdata2[4:0];                       //Shift Right Arithmetic

    5'b01000: ALUResult = rdata1 | rdata2;                              //Logical Or

    5'b01001: ALUResult = rdata1 & rdata2;                              //Logical and
  
    default:  ALUResult = rdata1 + rdata2;
    endcase

  end
endmodule