# MIPS Datapath Implementation Using Verilog

This project implements a simplified version of the **MIPS datapath** using Verilog HDL, excluding the control unit. It was developed as part of the Computer Organization (CS223) course by Ziad Mohamed, Mohamed Hesham, Nada Emad and Youssef Abdelrahem.

The design follows a behavioral modeling approach and focuses on manually simulating different MIPS instruction types (R-type, I-type, and branching) through a custom testbench.

---

## 🎯 Objective

To design and implement a modular and testable MIPS datapath architecture in Verilog, including:

- ALU
- Register File
- Data Memory
- Instruction Memory
- Multiplexers

---

## 🧩 Modules Included

- `alu.v`: Performs arithmetic and logic operations (ADD, SUB, AND, OR)
- `reg_file.v`: Register file with read/write functionality
- `data_memory.v`: Handles load and store operations
- `instr_memory.v`: Stores binary instructions
- `mux.v`: Multiplexer for input control
- `mips_datapath.v`: Integrated datapath without control logic
- `tb_mips.v`: Testbench simulating different instruction types and setting manual control signals

---

## 📚 Features

- Implements all 3 main MIPS instruction types:
  - ✅ Arithmetic/Logical: `ADD`, `SUB`, `AND`, `OR`
  - ✅ Load/Store: `LW`, `SW`
  - ✅ Branching: `BEQ`
- Manual control signal assignment in the testbench
- Binary instruction memory setup for simulation
- Modular design with individual Verilog files for each unit
- Fully commented and testable behavioral code

---

## 🛠 Technologies

- **Language:** Verilog HDL
- **Tools:** ModelSim / Icarus Verilog / GTKWave
- **Modeling Style:** Behavioral
- **Simulation:** Manual control via testbench

---

## 🚀 How to Run

1. Open the project in your Verilog simulation environment (ModelSim / Icarus).
2. Load the top module and run `tb_mips.v`.
3. Observe signal outputs and memory contents to verify behavior.
4. Use waveform tools (e.g., GTKWave) to analyze datapath execution.

---

## 👥 Team

- Ziad Mohamed  
- Mohamed Hesham

---

## 📜 License

This project is for educational purposes as part of the Computer Organization course at university level.
