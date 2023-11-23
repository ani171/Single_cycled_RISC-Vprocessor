module control_unit (
  input logic [6:0] instruction, 
  input logic clk,
  output logic branch,
  output logic memread,
  output logic memwrite,
  output logic memtoreg,
  output logic alusrc,
  output logic regwrite,
  output logic [1:0] aluop
);
  localparam logic [6:0] RT = 7'b0110011,
	     IT = 7'b0010011, 
	     LW = 7'b0000011,
	     SW = 7'b0100011,
	     BEQ = 7'b1100011;

  always_ff @(posedge clk) begin
    
    alusrc    = 1'b0;
    memtoreg  = 1'b0;
    regwrite  = 1'b0;
    memread   = 1'b0;
    memwrite  = 1'b0;
    branch    = 1'b0;
    aluop     = 2'b00;
	 
    if (instruction == RT) begin
      alusrc    = 1'b0;
      memtoreg  = 1'b1;
      regwrite  = 1'b1;
      memread   = 1'b0;
      memwrite  = 1'b0;
      branch    = 1'b0;
      aluop     = 2'b10;
    end

    if (instruction == IT) begin
      alusrc    = 1'b0;
      memtoreg  = 1'b0;
      regwrite  = 1'b1;
      memread   = 1'b0;
      memwrite  = 1'b0;
      branch    = 1'b0;
      aluop     = 2'b10;
    end

    if (instruction == LW) begin
      alusrc    = 1'b1;
      memtoreg  = 1'b1;
      regwrite  = 1'b1;
      memread   = 1'b1;
      memwrite  = 1'b0;
      branch    = 1'b0;
      aluop     = 2'b00;
    end

    if (instruction == SW) begin
      alusrc    = 1'b1;
      memtoreg  = 1'b0;
      regwrite  = 1'b0;
      memread   = 1'b0;
      memwrite  = 1'b1;
      branch    = 1'b0;
      aluop     = 2'b10;
    end

    if (instruction == BEQ) begin
      alusrc    = 1'b0;
      memtoreg  = 1'b0;
      regwrite  = 1'b0;
      memread   = 1'b0;
      memwrite  = 1'b0;
      branch    = 1'b1;
      aluop     = 2'b01;
    end
  end
endmodule
