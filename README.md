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
```
![image](https://github.com/ani171/risc/assets/97838595/77205218-e48c-4012-95a8-baf08d81c442)




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

#### Instruction Fetch Block

```
module InstructionFetch(
    input bit clk,            
    output bit [31:0] instruction 
);

    bit [31:0] pc_next;  

    ProgramCounter PC (
        .clk(clk),
        .pc_sel(2'b00),      
        .imm(32'h0),                 
        .pc_out(pc_next)     
    );


    MyMemory memory (
       .clk(clk),
       .address(pc_next),
       .data(instruction)
    );

endmodule
```
![image](https://github.com/ani171/risc/assets/97838595/e9c3b418-b83b-45b1-bb92-3afb2927b165)

