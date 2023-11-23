module ID(
  input clk,
  input logic [31:0] writedata_1,
  output logic [31:0] instruction_1,
  output logic branch_1, memread_1, memwrite_1,memtoreg_1, alusrc_1, regwrite_1,
  output logic[1:0] aluop_1,
  output logic [31:0]readdata1_1, readdata2_1,
  output logic [31:0] immediate_1);
  
 control_unit cu (
.clk(clk),
    .instruction(instruction_1[6:0]), 
    .branch(branch_1),
    .memread(memread_1),
    .memwrite(memwrite_1),
    .memtoreg(memtoreg_1),
    .alusrc(alusrc_1),
    .regwrite(regwrite_1),
    .aluop(aluop_1)
  );

  register_file rf (
    .clk(clk),
    .regwrite(regwrite_1),
    .Readreg1(instruction_1[19:15]),
    .Readreg2(instruction_1[24:20]),
    .writereg(instruction_1[11:7]),
    .writedata( writedata_1),
    .readdata1(readdata1_1),
    .readdata2(readdata2_1)
  );

  immediate_generator #(
    .INSTRSIZE(32),
    .IMMSIZE(32)
  ) ig (
    .instruction(instruction_1[31:0]),
    .immediate(immediate_1[31:0])
  ); 

endmodule