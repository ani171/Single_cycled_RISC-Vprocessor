module MyMemory(
    input bit [31:0] pc,                 
    output bit [31:0] instr,
	 input bit clk
);

    reg [31:0] mem [0:32768]; 

   
    initial begin

        mem[0] = 32'b00000110000101000000110010010011;
        mem[4] = 32'b00000001000101000100001100010011;
	mem[8] = 32'b01000000000000000110000110010011;
	mem[12] = 32'b00000110010010000000000010000011;
	mem [16] = 32'b00000010000110000110000110010011;
        
    end

    always @(posedge clk) begin
        instr = mem[pc >> 2]; 
    end

endmodule
