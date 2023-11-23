module writeback(
input logic [31:0]ALUout,
input logic [31:0]q,
input logic memtoreg,
output logic [31:0]regwritedata);

assign regwritedata=(memtoreg?q:ALUout);
endmodule
