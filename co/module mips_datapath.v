module MIPS_Datapath (
    input clk, reset,
    input [31:0] instruction,
    output reg [31:0] ALU_result,
    output reg zero_flag
);

    // Internal signals
    reg [31:0] reg_file [0:31];  // Register file
    reg [31:0] read_data_1, read_data_2;
    reg [31:0] sign_ext_imm;
    reg [31:0] mem [0:127];      // Data memory

    // Instruction fields
    wire [5:0] opcode = instruction[31:26];
    wire [4:0] rs = instruction[25:21];
    wire [4:0] rt = instruction[20:16];
    wire [4:0] rd = instruction[15:11];
    wire [15:0] imm = instruction[15:0];
    wire [5:0] funct = instruction[5:0];

    // Control signals
    reg RegWrite, MemRead, MemWrite, ALUSrc;
    reg [3:0] ALUOp;

    // Sign extend immediate
    always @(*) begin
        sign_ext_imm = { {16{imm[15]}}, imm };
    end

    // Register file read
    always @(*) begin
        read_data_1 = reg_file[rs];
        read_data_2 = reg_file[rt];
    end

    // ALU operation
    always @(*) begin
        case (ALUOp)
            4'b0010: ALU_result = read_data_1 + (ALUSrc ? sign_ext_imm : read_data_2); // ADD
            4'b0110: ALU_result = read_data_1 - read_data_2;  // SUB
            4'b0000: ALU_result = read_data_1 & read_data_2;  // AND
            4'b0001: ALU_result = read_data_1 | read_data_2;  // OR
            default: ALU_result = 0;
        endcase
        zero_flag = (ALU_result == 0);
    end

    // Memory operations and register write-back
    reg [31:0] mem_data;
    always @(posedge clk) begin
        if (reset) begin
            
            
        end else begin
            if (MemWrite) mem[ALU_result >> 2] <= read_data_2;
            if (MemRead) mem_data <= mem[ALU_result >> 2];
            if (RegWrite) reg_file[rd] <= ALU_result;
        end
    end
endmodule