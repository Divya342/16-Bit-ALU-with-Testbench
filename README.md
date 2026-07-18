# 16-Bit-ALU-with-Testbench

A synthesizable 16-bit Verilog ALU featuring 16 operations, safe flag handling, and full compatibility with synthesis tools like Yosys. Both the ALU design and the simulation testbench are contained within a single file (alu.v).

Quick Start (Simulation)Run these commands using Icarus Verilog and GTKWave:

# 1. Compile the unified code file
iverilog -o alu_sim alu.v

# 2. Run simulation (prints results & generates alu_tb.vcd)
vvp alu_sim

# 3. View waveforms
gtkwave alu_tb.vcd

Supported OperationsArithmetic: Add (0000), Subtract (1101) with carry/borrow out on output y.Logical: OR, NOR, XNOR, NAND, AND, XOR, NOT (0001 to 0111).Shifts: Fixed Single-Bit (1000, 1001), Variable Logic (1010, 1011), Signed Arithmetic (1100).System: Bypass/Error State (1110), Clear Output (1111).
