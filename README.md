# RISC-V

![WhatsApp Image 2023-11-22 at 6 31 54 PM](https://github.com/ani171/risc/assets/97838595/055b03f3-de84-4f6c-927c-45bbf077d35b)

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

    bit signed [31:0] i;          
    bit b1;              
    bit zflag;          
    bit [31:0] pc_out;
	 bit [31:0] pc_next; 

    Program_Counter PC (
        .clk(clk),
        .branch(b1),      
        .imm(i), 
		  .zero_flag(zflag),
        .pc_out(pc_next)     
    );


    MyMemory memory (
       .clk(clk),
       .pc(pc_next),
       .instr(instruction)
    );

endmodule

```
![image](https://github.com/ani171/risc/assets/97838595/27b8b76f-91c4-41c2-b6ea-2cf9feaa9762)

#### Testbench for Instruction Fetch Block

```
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
```

## Execution

- The ALU (Arithmetic Logic Unit) performs the actual computation based on the decoded instruction.
- This stage includes operations such as addition, subtraction, logic operations, etc.

#### Execution Mux 
- To select between immediate value and the value in the register

```
module exemux (
	input bit clk,
    input logic alu_src,
    input logic  [31:0] imm32,
	 input logic  [31:0] rdata2,
    output logic [31:0] rdata3
);

always @(posedge clk) begin 
    case (alu_src)
       1'b0 : rdata3 = rdata2;
       1'b1 : rdata3 = imm32;
    endcase
    
end
    
endmodule
```
![image](https://github.com/ani171/risc/assets/97838595/14142950-575c-4981-bde3-0890141871b8)

#### Branch condition checking
- Conditional Branching: The module is designed to handle a specific type of branch instruction (opcode 7'b1100011) with the specified function code (funct3 BEQ). The condition for branching is (rdata1 == rdata2).
- Branch Taken Signal: The output br_taken is asserted (1) if the branch condition is met; otherwise, it is deasserted (0). The br_taken signal indicates whether the branch instruction should be taken based on the specified condition.
- B-Type Branching: The module checks for a specific opcode associated with B-type branching (7'b1100011). Inside this case, it further examines the function code (funct3). If the function code corresponds to the BEQ operation, it checks whether rdata1 is equal to rdata2 while considering an additional condition (btype). The specific condition (btype & (rdata1 == rdata2)) determines whether the branch should be taken.

```
module branchc (
	input bit clk,
	input bit btype,
    input bit [2:0]  funct3,
    input bit [6:0]  opcode,
    input bit [31:0] rdata1,
	 input bit [31:0] rdata2,
    output bit br_taken
);


parameter [2:0] BEQ  = 3'b000;

always @(posedge clk) begin
    case (opcode)
        7'b1100011 :begin  // B Type 
            case(funct3) 
                BEQ   : br_taken = (btype & (rdata1 == rdata2)) ;
					 
					 endcase
				end
				
		endcase
		
	end
	
endmodule
```

![image](https://github.com/ani171/risc/assets/97838595/ed93feb2-83d0-4423-9f19-e769386c9d07)


#### ALU
- performs various arithmetic and logical operations based on the specified control signal (alu_op)

```
module alu (
	input bit clk,
	input bit alu_src,
    input logic  [4:0]  alu_op,
    input logic  [31:0] rdata1,
	 input logic  [31:0] rdata2,
    output logic [31:0] ALUResult
);


always @(posedge clk) begin
    case(alu_op)
	 
	 
    
    5'b00000: ALUResult = rdata1 + rdata2 ;                             //Addition

    5'b00001: ALUResult = rdata1 - rdata2 ;                             //Subtraction

    5'b00010: ALUResult = rdata1 << rdata2 [4:0];                        //Shift Left Logical

    5'b00101: ALUResult = rdata1 ^ rdata2;                              //LOgical xor

    5'b00110: ALUResult = rdata1 >> rdata2;                             //Shift Right Logical

    5'b00111: ALUResult = rdata1 >>> rdata2[4:0];                       //Shift Right Arithmetic

    5'b01000: ALUResult = rdata1 | rdata2;                              //Logical Or

    5'b01001: ALUResult = rdata1 & rdata2;                              //Logical and
  
    default:  ALUResult = rdata1 + rdata2;
    endcase

  end
endmodule

```

![image](https://github.com/ani171/risc/assets/97838595/2a0ac813-e6bb-4f91-9dfd-cf514bb56fe5)

![image](https://github.com/ani171/risc/assets/97838595/8248091f-166a-4023-8b08-a57f20526c8f)

#### Execution

````
module exetop (
input bit clk,
input bit [31:0] rdata1,
input bit [31:0] rdata2,
input bit [31:0] imm32,
input bit alu_op,
input bit alu_src,
output logic [31:0] ALUResult,
output bit br_taken
);

wire rdata3;

exemux exemux1 (clk,alu_src,imm32,rdata2,rdata3);

alu alu1 (clk,alu_src,alu_op,rdata1,rdata3,ALUResult);

branchc bc1 (clk, btype,funct3,opcode,rdata1,rdata3,br_taken);

endmodule
````
![image](https://github.com/ani171/risc/assets/97838595/f8696fbc-95f9-4dd8-96c9-b61e7567f1a9)

