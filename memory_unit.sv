module memory_unit
#(
  parameter ADDRSIZE = 32,
  WORDSIZE = 32
) (
  input clk,
  input logic wren, rden,           
  input logic [ADDRSIZE-1:0] addr,  
  input logic [WORDSIZE-1:0] d,     
  output logic[WORDSIZE-1:0] q 
);

  logic [WORDSIZE-1:0] mem [0:2**ADDRSIZE-1];

  always @(posedge clk)
  begin
    if (wren)
      mem[addr] <= d;
    else
      mem[addr] <= mem[addr];
  end

  assign q = mem[addr];

  int i;
  initial
  begin
    for (i = 0; i < 2**ADDRSIZE-1; i=i+1)
      mem[i] = 0;
  end

endmodule