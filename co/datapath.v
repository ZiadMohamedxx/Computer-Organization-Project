module DataMemory (
    input clk, MemWrite, MemRead,
    input [31:0] Address, WriteData,
    output reg [31:0] ReadData
);
    reg [31:0] memory [0:127]; 

    always @(*) begin 
        if (MemRead) begin
            ReadData = memory[Address >> 2];
        end
    end

    always @(posedge clk) begin
        if (MemWrite) begin
            memory[Address >> 2] <= WriteData;
        end
    end
endmodule




module ALU (
    input [31:0] A, B,
    input [3:0] ALUControl,
    output reg [31:0] Result,
    output Zero
);
    assign Zero = (Result == 0);

    always @(*) begin
        case (ALUControl)
            4'b0010: Result = A + B; // ADD
            4'b0110: Result = A - B; // SUB
            4'b0000: Result = A & B; // AND
            4'b0001: Result = A | B; // OR
            default: Result = 0;
        endcase
    end
endmodule




module RegisterFile (
    input clk, RegWrite,
    input [4:0] ReadReg1, ReadReg2, WriteReg,
    input [31:0] WriteData,
    output reg [31:0] ReadData1, ReadData2
);
    reg [31:0] registers [31:0]; // 32 registers, each 32-bit wide

    always @(*) begin
        ReadData1 = registers[ReadReg1];
        ReadData2 = registers[ReadReg2];
    end

    always @(posedge clk) begin
        if (RegWrite) begin
            registers[WriteReg] <= WriteData;
        end
    end
endmodule




module InstructionMemory (
    input [31:0] Address,
    output reg [31:0] Instruction
);
    reg [31:0] memory [0:127]; // Memory for 128 instructions

    initial begin
        // Manually populate instructions
        memory[0] = 32'b000000_01010_01011_01001_00000_100000; // ADD $t1, $t2, $t3
        memory[1] = 32'b100011_01010_01001_00000_00000_000100; // LW $t1, 4($t2)
        memory[2] = 32'b101011_01010_01001_00000_00000_000100; // SW $t1, 4($t2)
        memory[3] = 32'b000100_01001_01010_00000_00000_000011; // BEQ $t1, $t2, offset
    end

    always @(*) begin
        Instruction = memory[Address >> 2];
    end
endmodule



// Sign-Extension Unit
module SignExtend(input [15:0] Immediate,
                  output [31:0] SignExtended);
    assign SignExtended = {{16{Immediate[15]}}, Immediate};
endmodule

// Program Counter Module
module ProgramCounter(input clk, reset, PCWrite,
                      input [31:0] PCNext,
                      output reg [31:0] PC);
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'b0;
        else if (PCWrite)
            PC <= PCNext;
    end
endmodule

// MIPS Datapath Without Control Unit
module MIPS_Datapath(input clk, reset,
                     output [31:0] PC, Instruction, ALUResult);
    // Wires and Registers
    wire [31:0] PCNext, PCBranch, PCJump, PCPlus4;
    wire [31:0] SignExtImm, ALUInput2, ReadData1, ReadData2, WriteData, ReadDataMem;
    wire [3:0] ALUControl;
    wire Zero;
    reg Branch, Jump, MemWrite, MemRead, RegWrite;
    reg [3:0] ALUControlReg;

    // Program Counter
    ProgramCounter pc(clk, reset, 1'b1, PCNext, PC);

    // Increment PC by 4
    assign PCPlus4 = PC + 4;

    // Instruction Memory
    InstructionMemory IM(PC, Instruction);

    // Register File
    RegisterFile RF(clk, RegWrite, Instruction[25:21], Instruction[20:16], Instruction[15:11], WriteData, ReadData1, ReadData2);

    // Sign-Extension Unit
    SignExtend SE(Instruction[15:0], SignExtImm);

    // Branch Address Calculation
    assign PCBranch = PCPlus4 + (SignExtImm << 2);

    // Jump Address
    assign PCJump = {PCPlus4[31:28], Instruction[25:0], 2'b00};

    // ALU Input MUX (Register or Immediate)
    assign ALUInput2 = (Instruction[31:26] == 6'b100011 || Instruction[31:26] == 6'b101011) ? SignExtImm : ReadData2;

    // ALU
    ALU UUT(ReadData1, ALUInput2, ALUControlReg, ALUResult, Zero);

    // Data Memory
    DataMemory dm(clk, MemWrite, MemRead, ALUResult, ReadData2, ReadDataMem);

    // Write-Back Stage
    assign WriteData = (MemRead) ? ReadDataMem : ALUResult;

    // Control Signal Logic (Direct Assignment)
    always @(*) begin
        // Default values
        RegWrite = 0;
        MemWrite = 0;
        MemRead = 0;
        Branch = 0;
        Jump = 0;
        ALUControlReg = 4'b0000;

        case (Instruction[31:26]) // Opcode field
            6'b000000: begin // R-type instructions
                RegWrite = 1;
                case (Instruction[5:0]) // Func field
                    6'b100000: ALUControlReg = 4'b0010; // ADD
                    6'b100010: ALUControlReg = 4'b0110; // SUB
                    6'b100100: ALUControlReg = 4'b0000; // AND
                    6'b100101: ALUControlReg = 4'b0001; // OR
                endcase
            end
            6'b100011: begin // LW
                RegWrite = 1;
                MemRead = 1;
                ALUControlReg = 4'b0010; // ADD for address calculation
            end
            6'b101011: begin // SW
                MemWrite = 1;
                ALUControlReg = 4'b0010; // ADD for address calculation
            end
            6'b000100: begin // BEQ
                Branch = 1;
                ALUControlReg = 4'b0110; // SUB for comparison
            end
            6'b000010: begin // JUMP
                Jump = 1;
            end
        endcase
    end

    // PC Update Logic
    assign PCNext = (Jump) ? PCJump :
                    (Branch && Zero) ? PCBranch : PCPlus4;
endmodule
