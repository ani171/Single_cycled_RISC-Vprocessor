module register_file(
input logic[4:0] Readreg1,
input logic[4:0] Readreg2,
input logic[4:0] writereg,
input logic[31:0] writedata,
input reg regwrite,
input logic clk,
output logic[31:0] readdata1,
output logic[31:0] readdata2
);
logic[31:0] registers[31:0];
always @(posedge clk) begin
  if(regwrite) begin
     registers[writereg] <= writedata;
  end
end
assign readdata1 = registers[Readreg1];
assign readdata2 = registers[Readreg2];
int i;
initial
begin
  for(i=0;i<=31;i++)
    registers[i]=0;
  end
 
endmodule