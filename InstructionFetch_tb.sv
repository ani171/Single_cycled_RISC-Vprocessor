`timescale 1ns / 1ps

module InstructionFetch_tb;

    reg clk;
    reg signed [31:0] i;
    reg b1;
    reg zflag;
    wire [31:0] instruction;

    InstructionFetch uut (
        .clk(clk),
        .instruction(instruction)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        i = 32'h00000001;
        b1 = 1'b0;
        zflag = 1'b0;
        #10 i = 32'h00000002; 
        #10 b1 = 1'b1;
        #10 zflag = 1'b1;
        #100 $finish; 
    end

endmodule
