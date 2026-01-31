# 💻 Computer Architecture & Low-Level Programming

This repository contains my personal implementations of **Computer Architecture** concepts, focusing on **MIPS Assembly** programming and **Verilog** hardware design.

These projects demonstrate a deep understanding of how software interacts with hardware, memory management at the byte level, and processor datapath design.

## 📂 Projects Overview

### 1. Library Management System (MIPS Assembly)
A low-level implementation of a library system that manages books, categories, and waitlists directly in memory.
* **Memory Management:** Manual simulation of `struct` data types using byte offsets.
* **Data Structures:** Implementation of **Linked Lists** in Assembly to manage user waitlists dynamically.
* **System Calls:** usage of dynamic memory allocation (`sbrk`) for creating book and category objects.
* **Modular Design:** Usage of the MIPS calling convention (`jal`, `$ra`, stack frames) for robust function calls.

### 2. Custom Single-Cycle MIPS Processor (Verilog)
Design and implementation of a modified Single-Cycle MIPS Processor with a custom Instruction Set Architecture (ISA).
* **Custom ISA Extension:** Integrated new instructions into the datapath, including `NAND`, `BLT` (Branch Less Than), and stack manipulation commands.
* **Hardware Security Logic:** Designed hardware-level detection mechanisms for **Stack Pointer (SP) Overflow and Underflow**. This module prevents the execution of instructions that would violate stack boundaries.
* **Datapath & Control:** Modified the ALU and Control Unit to support 8-bit memory addressing and 32-bit register operations.

## 🛠 Technologies & Tools
* **Languages:** MIPS Assembly, Verilog (HDL)
* **Simulation Tools:** QtSpim (for Assembly), ModelSim (for Verilog)
* **Concepts:** ISA Design, Digital Logic, Memory Hierarchy, Stack Frames ($sp), Recursion.

---
> **Disclaimer:** This repository allows me to showcase my technical skills and understanding of computer architecture concepts. It contains my personal solutions and implementations. It does not contain specific assignment prompts, question sheets, or proprietary course materials belonging to the university.
