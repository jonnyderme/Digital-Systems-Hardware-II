# 💻 Digital Systems Hardware II
### ⚙️ Digital Systems Design – Floating Point Multiplier (2024)
Assignment for the "Digital-Systems-Hardware-II" Course  
Faculty of Engineering, AUTh  
School of Electrical and Computer Engineering  
Electronics and Computers Department

📚 *Course:* Digital Systems Hardware II  
🏛️ *Faculty:* AUTh - School of Electrical and Computer Engineering  
📅 *Semester:* 8th Semester, 2023–2024

---

## 📚 Table of Contents
- [Overview](#overview)
- [Objectives](#objectives)
- [Modules](#modules)
- [Testbench & Verification](#testbench--verification)
- [Assertions](#assertions)
- [Repository Structure](#repository-structure)

---

## 🧠 Overview

This project involves the design and verification of a **single-precision IEEE-754 Floating Point Multiplier** in SystemVerilog using a modular architecture and assertions. The coursework includes setting up a simulation environment, developing individual multiplier stages, creating a testbench, and writing SystemVerilog Assertions (SVA).

---

## 🎯 Objectives

- Develop RTL modules for normalization, rounding, exception handling, and multiplication
- Simulate and verify correctness through comprehensive testbenches
- Handle edge cases (NaNs, Infinities, Zeros, Denormals)
- Use **Questa Intel FPGA Edition** for RTL simulation
- Utilize **SVA** for design property verification

---

## 🧩 Modules

- **fp_mult**: Top-level wrapper connecting all submodules  
- **normalize_mult**: Normalizes mantissa and adjusts exponent  
- **round_mult**: Rounds mantissa based on rounding mode and guard/sticky bits  
- **exception_mult**: Handles edge cases, calculates status flags  
- **testbench.sv**: Applies random and corner-case tests  
- **dut_property.sv**: Contains SystemVerilog Assertions (Immediate + Concurrent)

---

## 🧪 Testbench & Verification

- Randomized tests using `$urandom`  
- Corner-case tests: zeros, infinities, NaNs, denormals, normals  
- Result comparison using provided `multiplication()` function  
- Clock period: 15ns  
- Total combinations tested: 144 (corner cases)

---

## ✔️ Assertions

- **Immediate Assertions**: Ensure invalid flag combinations don’t co-occur  
- **Concurrent Assertions**: Check output signal behavior based on status bits over multiple cycles  
- Modules:
  - `test_status_bits.sv`  
  - `test_status_z_combinations.sv`

---

## 📁 Repository Structure
## 📁 Repository Structure
```
├── exercise1/
│   ├── fp_mult.sv                  # Main multiplier module
│   ├── normalize_mult.sv           # Normalization stage
│   ├── round_mult.sv               # Rounding logic
│   └── exception_mult.sv           # Exception handling
├── exercise2/
│   └── testbench.sv                # Testbench for random and corner cases
├── exercise3/
│   ├── test_status_bits.sv         # Immediate assertions
│   └── test_status_z_combinations.sv # Concurrent assertions
├── report.pdf                      # Coursework report with results and screenshots
└── README.md                       # This documentation
```
