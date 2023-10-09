module MyMemory(
    input bit clk,        
    input bit [31:0] address, 
    output bit [31:0] data 
);
	 // Considering a 16 bit range
    reg [31:0] memory_array [-32768:32767];

    always @(posedge clk) begin
        data <= memory_array[address];
    end

endmodule
