`timescale 1ns/1ps

module tb_ID;

  reg clk;
  reg [31:0] writedata_1;
  reg [31:0] instruction_1;
  wire branch_1, memread_1, memwrite_1, memtoreg_1, alusrc_1, regwrite_1;
  wire [1:0] aluop_1;
  wire [31:0] readdata1_1, readdata2_1;
  wire [31:0] immediate_1;

  INSD uut (
    .clk(clk),
    .writedata_1(writedata_1),
    .instruction_1(instruction_1),
    .branch_1(branch_1),
    .memread_1(memread_1),
    .memwrite_1(memwrite_1),
    .memtoreg_1(memtoreg_1),
    .alusrc_1(alusrc_1),
    .regwrite_1(regwrite_1),
    .aluop_1(aluop_1),
    .readdata1_1(readdata1_1),
    .readdata2_1(readdata2_1),
    .immediate_1(immediate_1)
  );

  always begin
    #5 clk = ~clk;
  end

  initial begin
    clk = 0;
    writedata_1 = 32'hDEADBEEF; 

    instruction_1 = 32'h00A98933; 
    #10; // Wait for one clock cycle
    // Verify the result for R-type instruction
    if (instruction_1 !== 32'h00A98933 || branch_1 !== 0 || memread_1 !== 0 || memwrite_1 !== 0 || memtoreg_1 !== 1 || alusrc_1 !== 0 || regwrite_1 !== 1 || aluop_1 !== 2'b10)$fatal("Test Case 1 failed");

    instruction_1 = 32'h020B2483; 
    #10; // Wait for one clock cycle
    if (instruction_1 !== 32'h020B2483 || branch_1 !== 0 || memread_1 !== 1 || memwrite_1 !== 0 || memtoreg_1 !== 0 || alusrc_1 !== 1 || regwrite_1 !== 1 || aluop_1 !== 2'b00) $fatal("Test Case 2 failed");
    #1000 $finish;
  end


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_ID);
  end

  initial begin
    $monitor("Time=%0t clk=%b writedata_1=%h instruction_1=%h branch_1=%b memread_1=%b memwrite_1=%b memtoreg_1=%b alusrc_1=%b regwrite_1=%b aluop_1=%b readdata1_1=%h readdata2_1=%h immediate_1=%h", $time, clk, writedata_1, instruction_1, branch_1, memread_1, memwrite_1, memtoreg_1, alusrc_1, regwrite_1, aluop_1, readdata1_1, readdata2_1, immediate_1);
  end

endmodule
