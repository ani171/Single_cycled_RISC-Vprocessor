# RISC-V


![WhatsApp Image 2023-11-22 at 6 31 54 PM (1)](https://github.com/ani171/risc/assets/97838595/9c55fbeb-6244-47bb-8e85-0cb2b2645523)


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
![WhatsApp Image 2023-11-24 at 10 01 47 AM](https://github.com/ani171/risc/assets/97838595/20be9f01-537b-43eb-a97d-4a0d43294e53)

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
![WhatsApp Image 2023-11-24 at 10 04 46 AM](https://github.com/ani171/risc/assets/97838595/6698db43-6117-486e-9dff-1253532b51ba)

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

![WhatsApp Image 2023-11-22 at 7 46 37 PM](https://github.com/ani171/risc/assets/97838595/f232361b-81f2-442f-8f0b-28d979c0ee7e)

## Instruction Decode
- The instruction decode stage in a processor involves the interpretation of the opcode and other fields of an instruction
- The opcode of the fetched instruction is examined to determine the type of operation to be performed. Different opcodes correspond to different categories of instructions, and the processor must identify the instruction type.
- Register operands and immediate values are identified based on the decoded instruction
- Control signals are generated based on the decoded instruction to control various components of the processor, such as the ALU, register file, and memory unit. Control signals ensure that the subsequent stages of the pipeline or the relevant functional units operate correctly for the given instruction.

#### Control Unit

```
module control_unit (
  input logic [6:0] instruction, 
  input logic clk,
  output logic branch,
  output logic memread,
  output logic memwrite,
  output logic memtoreg,
  output logic alusrc,
  output logic regwrite,
  output logic [1:0] aluop
);
  localparam logic [6:0] RT = 7'b0110011,
	     IT = 7'b0010011, 
	     LW = 7'b0000011,
	     SW = 7'b0100011,
	     BEQ = 7'b1100011;

  always_ff @(posedge clk) begin
    
    alusrc    = 1'b0;
    memtoreg  = 1'b0;
    regwrite  = 1'b0;
    memread   = 1'b0;
    memwrite  = 1'b0;
    branch    = 1'b0;
    aluop     = 2'b00;
	 
    if (instruction == RT) begin
      alusrc    = 1'b0;
      memtoreg  = 1'b1;
      regwrite  = 1'b1;
      memread   = 1'b0;
      memwrite  = 1'b0;
      branch    = 1'b0;
      aluop     = 2'b10;
    end

    if (instruction == IT) begin
      alusrc    = 1'b0;
      memtoreg  = 1'b0;
      regwrite  = 1'b1;
      memread   = 1'b0;
      memwrite  = 1'b0;
      branch    = 1'b0;
      aluop     = 2'b10;
    end

    if (instruction == LW) begin
      alusrc    = 1'b1;
      memtoreg  = 1'b1;
      regwrite  = 1'b1;
      memread   = 1'b1;
      memwrite  = 1'b0;
      branch    = 1'b0;
      aluop     = 2'b00;
    end

    if (instruction == SW) begin
      alusrc    = 1'b1;
      memtoreg  = 1'b0;
      regwrite  = 1'b0;
      memread   = 1'b0;
      memwrite  = 1'b1;
      branch    = 1'b0;
      aluop     = 2'b10;
    end

    if (instruction == BEQ) begin
      alusrc    = 1'b0;
      memtoreg  = 1'b0;
      regwrite  = 1'b0;
      memread   = 1'b0;
      memwrite  = 1'b0;
      branch    = 1'b1;
      aluop     = 2'b01;
    end
  end
endmodule
```
![WhatsApp Image 2023-11-24 at 10 16 06 AM](https://github.com/ani171/risc/assets/97838595/e9f461d1-8e9e-47f3-adf6-262fcec10a74)

#### Immediate generator

```
module immediate_generator #(
  parameter INSTRSIZE = 32,
  IMMSIZE = 32
) (
  input [INSTRSIZE-1:0] instruction,
  output reg signed [IMMSIZE-1:0] immediate
);
  localparam RT = 7'b0110011,
             IT = 7'b0010011, 
	     LW = 7'b0000011, 
	     SW = 7'b0100011,
	    BEQ = 7'b1100011;

  always @(*)
  begin
    case (instruction[6:0])
      IT, LW: begin
        immediate = { {20{instruction[31]}}, instruction[31:20] };
      end
      SW: begin
        immediate = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
      end
      BEQ: begin
        immediate = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
      end
    endcase
  end

endmodule
```
![WhatsApp Image 2023-11-24 at 10 18 05 AM](https://github.com/ani171/risc/assets/97838595/42ad2a98-8271-40a0-9f25-111d03bf0f48)


#### Register file

```
module register_file(
input logic[4:0] Readreg1,
input logic[4:0] Readreg2,
input logic[4:0] writereg,
input logic[31:0] writedata,
input reg regwrite,
input logic clk,
output logic[31:0] readdata1,
output logic[31:0] readdata2
);
logic[31:0] registers[31:0];
always @(posedge clk) begin
  if(regwrite) begin
     registers[writereg] <= writedata;
  end
end
assign readdata1 = registers[Readreg1];
assign readdata2 = registers[Readreg2];
int i;
initial
begin
  for(i=0;i<=31;i++)
    registers[i]=0;
  end
 
endmodule
```
![WhatsApp Image 2023-11-24 at 10 19 59 AM](https://github.com/ani171/risc/assets/97838595/f8f166db-0138-48af-a870-8c8356155a8c)

#### Instruction Decode

```
module ID(
  input clk,
  input logic [31:0] writedata_1,
  output logic [31:0] instruction_1,
  output logic branch_1, memread_1, memwrite_1,memtoreg_1, alusrc_1, regwrite_1,
  output logic[1:0] aluop_1,
  output logic [31:0]readdata1_1, readdata2_1,
  output logic [31:0] immediate_1);
  
 control_unit cu (
.clk(clk),
    .instruction(instruction_1[6:0]), 
    .branch(branch_1),
    .memread(memread_1),
    .memwrite(memwrite_1),
    .memtoreg(memtoreg_1),
    .alusrc(alusrc_1),
    .regwrite(regwrite_1),
    .aluop(aluop_1)
  );

  register_file rf (
    .clk(clk),
    .regwrite(regwrite_1),
    .Readreg1(instruction_1[19:15]),
    .Readreg2(instruction_1[24:20]),
    .writereg(instruction_1[11:7]),
    .writedata( writedata_1),
    .readdata1(readdata1_1),
    .readdata2(readdata2_1)
  );

  immediate_generator #(
    .INSTRSIZE(32),
    .IMMSIZE(32)
  ) ig (
    .instruction(instruction_1[31:0]),
    .immediate(immediate_1[31:0])
  ); 

endmodule
```
![WhatsApp Image 2023-11-24 at 10 22 18 AM](https://github.com/ani171/risc/assets/97838595/5b2d24af-84fb-4aa9-b07f-bdc20e02ec21)


#### Testbench for Instruction decode
```
`timescale 1ns/1ps

module tb_ID;

  reg clk;
  reg [31:0] writedata_1;
  reg [31:0] instruction_1;
  wire branch_1, memread_1, memwrite_1, memtoreg_1, alusrc_1, regwrite_1;
  wire [1:0] aluop_1;
  wire [31:0] readdata1_1, readdata2_1;
  wire [31:0] immediate_1;

  INSD uut (
    .clk(clk),
    .writedata_1(writedata_1),
    .instruction_1(instruction_1),
    .branch_1(branch_1),
    .memread_1(memread_1),
    .memwrite_1(memwrite_1),
    .memtoreg_1(memtoreg_1),
    .alusrc_1(alusrc_1),
    .regwrite_1(regwrite_1),
    .aluop_1(aluop_1),
    .readdata1_1(readdata1_1),
    .readdata2_1(readdata2_1),
    .immediate_1(immediate_1)
  );

  always begin
    #5 clk = ~clk;
  end

  initial begin
    clk = 0;
    writedata_1 = 32'hDEADBEEF; 

    instruction_1 = 32'h00A98933; 
    #10; // Wait for one clock cycle
    // Verify the result for R-type instruction
    if (instruction_1 !== 32'h00A98933 || branch_1 !== 0 || memread_1 !== 0 || memwrite_1 !== 0 || memtoreg_1 !== 1 || alusrc_1 !== 0 || regwrite_1 !== 1 || aluop_1 !== 2'b10)$fatal("Test Case 1 failed");

    instruction_1 = 32'h020B2483; 
    #10; // Wait for one clock cycle
    if (instruction_1 !== 32'h020B2483 || branch_1 !== 0 || memread_1 !== 1 || memwrite_1 !== 0 || memtoreg_1 !== 0 || alusrc_1 !== 1 || regwrite_1 !== 1 || aluop_1 !== 2'b00) $fatal("Test Case 2 failed");
    #1000 $finish;
  end


  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_ID);
  end

  initial begin
    $monitor("Time=%0t clk=%b writedata_1=%h instruction_1=%h branch_1=%b memread_1=%b memwrite_1=%b memtoreg_1=%b alusrc_1=%b regwrite_1=%b aluop_1=%b readdata1_1=%h readdata2_1=%h immediate_1=%h", $time, clk, writedata_1, instruction_1, branch_1, memread_1, memwrite_1, memtoreg_1, alusrc_1, regwrite_1, aluop_1, readdata1_1, readdata2_1, immediate_1);
  end

endmodule
```
![WhatsApp Image 2023-11-23 at 9 46 10 PM](https://github.com/ani171/risc/assets/97838595/cd5ce4c1-ad8c-4bd7-8393-ca9850bb84d7)


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
![image](https://github.com/ani171/risc/assets/97838595/03b7f37b-a3b3-4b3f-884c-701ffd037e86)


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

![image](https://github.com/ani171/risc/assets/97838595/e5899317-5469-4614-bf03-c880db6a46ed)

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

![image](https://github.com/ani171/risc/assets/97838595/fed65616-0dbc-4d72-8ed1-3586996b86bb)

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
![image](https://github.com/ani171/risc/assets/97838595/4bf5d547-3994-48fd-a09f-9e32f1b20e0b)


## Memory Access
- The Memory Access stage is responsible for interacting with the data memory subsystem. This is particularly relevant for load and store instructions.
- In the case of a load instruction, the Memory stage retrieves data from the data memory based on the effective memory address calculated in the previous stages. For store instructions, the stage writes data to the specified memory location.

```
module memory_unit
#(
  parameter ADDRSIZE = 32,
  WORDSIZE = 32
) (
  input clk,
  input logic wren, rden,           
  input logic [ADDRSIZE-1:0] addr,  
  input logic [WORDSIZE-1:0] d,     
  output logic[WORDSIZE-1:0] q 
);

  logic [WORDSIZE-1:0] mem [0:2**ADDRSIZE-1];

  always @(posedge clk)
  begin
    if (wren)
      mem[addr] <= d;
    else
      mem[addr] <= mem[addr];
  end

  assign q = mem[addr];

  int i;
  initial
  begin
    for (i = 0; i < 2**ADDRSIZE-1; i=i+1)
      mem[i] = 0;
  end

endmodule
```

![image](https://github.com/ani171/risc/assets/97838595/537c81d3-92f8-416c-9110-ef1ec28ca726)


## Write Back
- In the Write Back stage, the result of the execution, often obtained from the Execution stage, is written back to the register file or register bank.
- The result is stored in the destination register specified by the instruction.

```
module writeback(
input logic [31:0]ALUout,
input logic [31:0]q,
input logic memtoreg,
output logic [31:0]regwritedata);

assign regwritedata=(memtoreg?q:ALUout);
endmodule
```

![image](https://github.com/ani171/risc/assets/97838595/86f4f842-942c-4f4b-a350-31b7269869d3)

#### Testbench for WriteBack

```
module tb_writeback;

  logic [31:0] ALUout;
  logic [31:0] q;
  logic memtoreg;
  logic [31:0] regwritedata;

  writeback uut (
    .ALUout(ALUout),
    .q(q),
    .memtoreg(memtoreg),
    .regwritedata(regwritedata)
  );

  initial begin
    ALUout = 32'h0000_0000;
    q = 32'h0000_1234;
    memtoreg = 1'b0;

    #10;
    memtoreg = 1'b1; 
    #10;
    memtoreg = 1'b0; 
    #10;
    ALUout = 32'h5678_9ABC; 
    #100;
    $stop; 
  end

endmodule
```
![WhatsApp Image 2023-11-23 at 9 51 13 PM](https://github.com/ani171/risc/assets/97838595/6359db91-9ed9-4e87-ad35-b76fe9710cde)



## Single Cycled RISC-V Processor

```
module final_top(input bit clk
);


wire mlcode,imm32,rdata1,rdata2,reg_wr,alu_src,wb_sel,alu_op,wr_en,rd_en,rmdata,wdata;

instfetch if1 (clk,br_taken,imm,mlcode);

dcd_stg dcd1 (clk,mlcode,wdata,rdata1,rdata2,imm32,reg_wr,alu_src,wb_sel,alu_op,btype,wr_en,rd_en);

exe_stg exe1 (clk,rdata1,rdata2,imm32,alu_op,alu_src,ALUResult,br_taken);

mem_stg ma1 (clk,wr_en,rd_en,ALUResult,imm32,rdata);

wb_stg wb1 (clk,ALUResult,rdata,wb_sel,wdata);

endmodule
```
