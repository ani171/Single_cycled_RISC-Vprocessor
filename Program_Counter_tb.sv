module Program_Counter_tb;

    reg clk;
    reg signed [31:0] imm;
    reg branch;
    reg zero_flag;
    wire [31:0] pc_out;

    Program_Counter uut (
        .clk(clk),
        .imm(imm),
        .branch(branch),
        .zero_flag(zero_flag),
        .pc_out(pc_out)
    );

    initial begin
        // Initialize inputs
        clk = 0;
        imm = 8; // Change imm to test different branches
        branch = 1;
        zero_flag = 1;

        // Apply clock and inputs
        #5 clk = 1;
        #5 clk = 0;

        // Display results
        $display("Initial PC: %d", pc_out);

        // Test with branch taken
        imm = 12;
        #5 clk = 1;
        #5 clk = 0;
        $display("Branch taken: %d", pc_out);

        // Test with branch not taken
        branch = 0;
        #5 clk = 1;
        #5 clk = 0;
        $display("Branch not taken: %d", pc_out);

        $finish;
    end

endmodule
