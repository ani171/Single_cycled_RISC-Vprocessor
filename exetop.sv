module exetop (
input bit clk,
input bit [31:0] rdata1,
input bit [31:0] rdata2,
input bit [31:0] imm32,
input bit alu_op,
input bit alu_src,
output logic [31:0] ALUResult,
output bit br_taken
);

wire rdata3;

exemux exemux1 (clk,alu_src,imm32,rdata2,rdata3);

alu alu1 (clk,alu_src,alu_op,rdata1,rdata3,ALUResult);

branchc bc1 (clk, btype,funct3,opcode,rdata1,rdata3,br_taken);

endmodule