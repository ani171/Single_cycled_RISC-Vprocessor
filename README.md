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

```


![image](https://github.com/ani171/risc/assets/97838595/7ec18f9e-617f-46e0-a670-0c044915c626)

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

