# RISC-V
-  Different stages typically involved in the execution of instructions in a RISC-V CPU
1. Instruction Fetch
2. Instruction Decode
3. Execution
4. Memory Access
5. Write Back
### Instruction Fetch
-  CPU fetches the next instruction from memory
-  The program counter (PC) is used to determine the memory address of the instruction to be fetched
-  The instruction is then stored in an instruction register for decoding and execution

<summary> Program Counter</summary>
<details> 

```
module ProgramCounter(
    input bit clk,          
    input bit [1:0] pc_sel,  
    input bit [31:0] imm,    
    input bit branch_taken,  
    input bit jump,          
    output bit [31:0] pc_out  
);

    always @(posedge clk) begin
        if (pc_sel == 2'b11) begin
            pc_out <= 32'b0; 
        end 
		  else if (pc_sel == 2'b00) begin 
            pc_out <= pc_out + 4; 
        end 
		  else if (pc_sel == 2'b01) begin 
            if (branch_taken) begin
                pc_out <= pc_out + imm; 
            end
        end 
		  else if (pc_sel == 2'b10) begin 
            if (jump) begin
                pc_out <= imm; 
            end
        end
    end
endmodule
```
![image](https://github.com/ani171/risc/assets/97838595/ec4ab173-9edc-4869-af60-3ab21a35d8bc)

</details>
