# Parameterized Arithmetic Logic Unit (ALU) Design and Verification Report

This report documents the design and functional verification of a parameterized Arithmetic Logic Unit (ALU) developed as part of the RTL design and verification training at Mirafra Technologies, Batch 11. 

The ALU is a fundamental digital building block capable of performing arithmetic and logical operations on parameterized-width operands. The default configuration uses:
* **8-bit operands** (`width = 8`)
* **4-bit command bus** (`cwidth = 4`)
* **16-bit result bus**

### Project Activities
The project involved two parallel activities:
* **RTL Design (`alu`):** Writing a synthesizable Verilog implementation of the ALU specification.
* **Functional Verification (`test_alu`):** Developing a directed testbench with an embedded reference model to verify an externally provided DUT (`design_tamil`) against the specification.

### Design Features
The design supports a wide range of operations, including multi-cycle multiplication, signed arithmetic, bitwise operations, shifts, and barrel rotations:
* **13 Arithmetic Commands** (`mode = 1`)
* **14 Logical Commands** (`mode = 0`)

All functional blocks were verified using QuestaSim, and coverage analysis was performed using Questa’s built-in coverage tools.

---

### Access the Full Report
🔗 [View the complete RTL Design and Verification Report on Google Drive](https://drive.google.com/file/d/1lX6NMPxcX63B0C-uWxhbP674bTwTmjpW/view?usp=sharing)
