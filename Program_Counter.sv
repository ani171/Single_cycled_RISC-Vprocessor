module Program_Counter(
    input bit clk,                 
    input bit signed [31:0] imm,          
    input bit branch,              
    input bit zero_flag,          
    output bit [31:0] pc_out       
);


    bit [31:0] pc_reg;              
    bit [31:0] pc_next;            
    bit branch_taken;              

    assign branch_taken = branch && zero_flag;

    always @(posedge clk) begin
        if (branch_taken) begin
            pc_reg <= pc_reg + imm;  
        end else begin
            pc_reg <= pc_reg + 4;    
        end
    end

    assign pc_next = branch_taken ? pc_reg + imm : pc_reg + 4;
    assign pc_out = pc_next;

endmodule
