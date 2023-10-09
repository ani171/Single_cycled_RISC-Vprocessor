# RISC-V
-  Different stages typically involved in the execution of instructions in a RISC-V CPU
1. Instruction Fetch
2. Instruction Decode
3. Execution
4. Memory Access
5. Write Back
## Instruction Fetch
-  CPU fetches the next instruction from memory
-  The program counter (PC) is used to determine the memory address of the instruction to be fetched
-  The instruction is then stored in an instruction register for decoding and execution

#### Program Counter

```
module ProgramCounter(
    input bit clk,          
    input bit [1:0] pc_sel,  
    input bit [31:0] imm,           
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
            pc_out <= pc_out + imm; 
        end 
		  else if (pc_sel == 2'b10) begin 
            pc_out <= imm; 
        end
    end
	 
endmodule
```
![image](https://github.com/ani171/risc/assets/97838595/108801f7-bc50-4750-a53c-b3037edd4cc2)
![image](https://github.com/ani171/risc/assets/97838595/0eb8c608-2b1b-49c4-8704-b6dda816e717)


- pc_sel
	- 2'b00: Increment the PC --> pc_out=pc_out+4
	- 2'b01: Branch
	- 2'b10: Jump

#### Code Memory
- Obtaining instruction from the PC output which has the address that has the instruction
- Considering a 16-bit range

```
module MyMemory(
    input bit clk,        
    input bit [31:0] address, 
    output bit [31:0] data 
);
	 // Considering a 16-bit range
    reg [31:0] memory_array [-32768:32767];

    always @(posedge clk) begin
        data <= memory_array[address];
    end
endmodule

```
![image](https://github.com/ani171/risc/assets/97838595/b05b8a9d-439e-4f22-b693-cfc462531547)

![image](https://github.com/ani171/risc/assets/97838595/c8b517e3-cc36-4655-b1df-0611f2a61db7)
