`timescale 1ns / 1ps

module MIPS_Datapath_Testbench;

    reg clk;
    reg reset;
    reg [31:0] instruction;
    wire [31:0] result;
    wire zero_flag;
    

    // Instantiate the Datapath
    MIPS_Datapath_Testbench DUT (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .ALUResult(result),
        .Zero(zero_flag)
    );
    

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test cases
    initial begin
        $display("Starting Testbench...");

        // Reset
        reset = 1;
        #10 reset = 0;

        // Test 1: Arithmetic ADD instruction
        instruction = 32'b000000_00001_00010_00011_00000_100000; // ADD R3 = R1 + R2
        #20;
        $display("ADD Test: Result = %h, Zero Flag = %b", result, zero_flag);

        // Test 2: Logical AND instruction
        instruction = 32'b000000_00001_00010_00100_00000_100100; // AND R4 = R1 & R2
        #20;
        $display("AND Test: Result = %h, Zero Flag = %b", result, zero_flag);

        // Test 3: Branch BEQ instruction
        instruction = 32'b000100_00001_00001_00000_00000_000011; // BEQ R1 == R1
        #20;
        $display("BEQ Test: Zero Flag = %b", zero_flag);

        // Test 4: Load Word (LW) instruction
        instruction = 32'b100011_00001_00010_00000_00000_000100; // LW R2 = Mem[R1 + offset]
        #20;
        $display("LW Test: Result = %h", result);

        // Test 5: Store Word (SW) instruction
        instruction = 32'b101011_00001_00010_00000_00000_000100; // SW Mem[R1 + offset] = R2
        #20;
        $display("SW Test: Data Written");

        $display("Testbench completed.");
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0d, Instruction=%b, Result=%h, Zero_Flag=%b", 
                 $time, instruction, result, zero_flag);
    end
endmodule