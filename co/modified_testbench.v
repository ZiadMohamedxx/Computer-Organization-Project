`timescale 1ns / 1ps

module MIPS_Datapath_Testbench;

    reg clk, reset;
    reg [31:0] instruction;
    reg [3:0] ALUOp;
    reg RegWrite, MemRead, MemWrite;
    wire [31:0] result;
    wire zero_flag;

    reg [31:0] expected_result; // بعمل valid لل result
    reg expected_zero_flag;     // validation لل zero flag

    // بعمل انشاء لل datapath
    MIPS_Datapath_Testbench UUT (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .result(result),
        .zero(zero_flag)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // task عشان aset control signals
    task assign_control_signals;
        input [5:0] opcode;
        input [5:0] funct;
        begin
            case (opcode)
                6'b000000: begin // R-type instructions
                    RegWrite = 1; MemRead = 0; MemWrite = 0;
                    case (funct)
                        6'b100000: ALUOp = 4'b0010; // ADD
                        6'b100010: ALUOp = 4'b0110; // SUB
                        6'b100100: ALUOp = 4'b0000; // AND
                        6'b100101: ALUOp = 4'b0001; // OR
                    endcase
                end
                6'b100011: begin // LW
                    RegWrite = 1; MemRead = 1; MemWrite = 0; ALUOp = 4'b0010;
                end
                6'b101011: begin // SW
                    RegWrite = 0; MemRead = 0; MemWrite = 1; ALUOp = 4'b0010;
                end
                6'b000100: begin // BEQ
                    RegWrite = 0; MemRead = 0; MemWrite = 0; ALUOp = 4'b0110;
                end
                6'b000010: begin // JUMP (simplified here)
                    RegWrite = 0; MemRead = 0; MemWrite = 0; ALUOp = 4'b0000;
                end
                default: begin
                    RegWrite = 0; MemRead = 0; MemWrite = 0; ALUOp = 4'b0000;
                end
            endcase
        end
    endtask

    // Test sequence
    initial begin
        reset = 1;
        #10 reset = 0;

        // Test ADD
        instruction = 32'b000000_00001_00010_00011_00000_100000; // ADD $3, $1, $2
        RegWrite = 1; MemRead = 0; MemWrite = 0; ALUSrc = 0; ALUOp = 4'b0010;
        assign_control_signals(6'b000000, 6'b100000);
        expected_result = 32'h00000003; // Assuming $1=1, $2=2
        expected_zero_flag = 0;
        #20 validate_test("ADD");

        // Test SUB
        instruction = 32'b000000_00001_00001_00100_00000_100010; // SUB $4, $1, $1
        assign_control_signals(6'b000000, 6'b100010);
        expected_result = 0; // Assuming $1=1
        expected_zero_flag = 1;
        #20 validate_test("SUB");

        // Test AND
        instruction = 32'b000000_00001_00011_00101_00000_100100; // AND $5, $1, $3
        assign_control_signals(6'b000000, 6'b100100);
        expected_result = 1 & 3; // Assuming $1=1, $3=3
        expected_zero_flag = 0;
        #20 validate_test("AND");

        // Test OR
        instruction = 32'b000000_00001_00011_00110_00000_100101; // OR $6, $1, $3
        assign_control_signals(6'b000000, 6'b100101);
        expected_result = 1 | 3; // Assuming $1=1, $3=3
        expected_zero_flag = 0;
        #20 validate_test("OR");

        // Test BEQ
        instruction = 32'b000100_00001_00001_00000_00000_000011; // BEQ $1, $1, offset
        assign_control_signals(6'b000100, 6'b000000);
        expected_result = 0; // Result not used in BEQ
        expected_zero_flag = 1; // Equal
        #20 validate_test("BEQ");

        // Test JUMP
        instruction = 32'b000010_00000_00000_00000_00000_000101; // JUMP to address
        assign_control_signals(6'b000010, 6'b000000);
        expected_result = 0; // Result not used in JUMP
        expected_zero_flag = 0; // Not applicable
        #20 validate_test("JUMP");

        $display("All tests completed.");
        $finish;
    end

    // Validation task
    task validate_test;
        input [31:0] test_name;
        begin
            if (result !== expected_result || zero_flag !== expected_zero_flag) begin
                $display("FAIL: %s - Expected Result=%h, Got=%h, Expected Zero=%b, Got=%b",
                         test_name, expected_result, result, expected_zero_flag, zero_flag);
            end else begin
                $display("PASS: %s - Result=%h, Zero Flag=%b",
                         test_name, result, zero_flag);
            end
        end
    endtask

    // Monitor signals
    initial begin
        $monitor("Time=%0d, Instruction=%b, Result=%h, Zero_Flag=%b",
                 $time, instruction, result, zero_flag);
    end
endmodule