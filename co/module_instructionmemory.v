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