# Verilog Tutorial

## 1. Objectives and Architectural Principles

Assignments HW02 through HW04 require implementing digital hardware in Verilog HDL. This tutorial establishes the syntax conventions, verification methodologies, and architectural constraints necessary to complete these projects independently.

Three core principles govern this tutorial:

1. 100% Executable Examples: Every example exists as an independent source file, verified via simulation with `make test`. Console outputs in the text reflect verbatim simulation runs.
2. Direct Framework Compatibility: The tutorial adopts the Verilog-2001 standard (`wire`, `reg`, `always @*`, `always @(posedge clk)`), matching the notation of the assignment starter code. SystemVerilog constructs used in testbenches are mapped explicitly in the Chapter 10 comparison tables.
3. Defect-Driven Debugging Training (`badNN`): Each chapter provides intentional failure cases exposing compilation errors and logic pitfalls. Running `make errors` surfaces compiler diagnostics, training practical hardware debugging skills.

---

## 2. Quickstart Guide

### 2.1 Verify Development Prerequisites

```bash
iverilog -V | head -1
vvp -V | head -1
```

A clean version banner confirms operational tools. Detailed setup instructions appear in [Chapter 01](ch01/README.md), Section 1.

### 2.2 Run Full Tutorial Verification

```bash
make test
```

When `PASS tutorial all` prints on the final line, all chapter test suites have passed.

### 2.3 Make Target Architecture

| Target | Description |
|---|---|
| `make setup-check` | Verify compiler and simulation toolchains |
| `make test` | Compile and execute all chapter test suites |
| `make errors` | Execute intentional error and pitfall examples to inspect compiler diagnostics |
| `make waves` | Generate VCD waveforms for the Chapter 10 overview module |
| `make clean` | Remove all generated compilation and waveform artifacts |
| `make help` | Display available targets |

Execute individual chapter suites from their respective directories:

```bash
cd ch03
make test
make errors
```

---

## 3. Chapter and Appendix Directory

| Chapter | Topic | Core Technical Focus | Project Alignment |
|---|---|---|---|
| [ch01](ch01/README.md) | Toolchain & First Module | `iverilog`/`vvp` pipeline, `module` port interfaces, continuous `assign`, self-checking testbenches, compiler diagnostics | All Projects |
| [ch02](ch02/README.md) | Syntax & Data Types | Literal formats, 4-state logic (`0`/`1`/`x`/`z`), `wire` vs. `reg` driving rules, bit-slicing, concatenation, sign extension, `parameter` | HW02 |
| [ch03](ch03/README.md) | Operators & Bit-Width Rules | Operator precedence, 5 bit-width expansion rules, signed casting, 3 shift variants, 4 independent ALU flags | HW02 |
| [ch04](ch04/README.md) | Combinational Circuit Design | `always @*`, exhaustive `case` statements, default pre-assignment, priority encoding, `function`, latch avoidance | HW02 |
| [ch05](ch05/README.md) | Sequential Circuit Design | `always @(posedge clk)`, nonblocking assignments (`<=`), synchronous resets, `reset > load > enable` priority | HW02, HW03, HW04 |
| [ch06](ch06/README.md) | Hierarchy & Parameterization | Modular hierarchy, explicit named port mapping, hierarchical signal probing, `generate` unrolling | HW03 |
| [ch07](ch07/README.md) | Memory & FSM | 2D memory arrays, asynchronous vs. synchronous read timing, `$readmemh`, 2-block FSM pattern | HW02, HW03, HW04 |
| [ch08](ch08/README.md) | Testbench Methodologies | Self-checking testbench architecture, modular `task` blocks, 32-bit boundary vectors, golden model comparisons, VCD and CSV traces | All Projects |
| [ch09](ch09/README.md) | Synthesizable RTL Coding | Synthesizable hardware subsets, simulation-only construct isolation, 27-point hardware design checklist | All Projects |
| [ch10](ch10/README.md) | SystemVerilog Comparison | `logic`, `always_comb`/`always_ff`, `typedef enum`, packed struct, 5-step framework code-reading method | All Projects |
| [Appendix](appendix/README.md) | Comprehensive Quick Reference | Essential commands, idiomatic patterns, 32-bit boundary vectors, compiler error tables, symptom-based debug guides | All Projects |

---

## 4. Recommended Learning Sequence

| Stage | Target Chapters | Objective |
|---|---|---|
| Stage 1: Toolchain & Baseline Syntax | ch01 | Compile, simulate, and interpret compiler diagnostic messages |
| Stage 2: Data Types & Arithmetic | ch02, ch03 | Master bit-width rules and signed operations in preparation for HW02 |
| Stage 3: Combinational Logic & Testing | ch04, ch08 | Implement combinational units with default assignments and self-checking testbenches |
| Stage 4: Sequential Logic & Hierarchy | ch05, ch06 | Model nonblocking state transitions and instantiate hierarchical modules for HW02 |
| Stage 5: Memory Timing & Synthesis | ch07, ch09 | Implement synchronous memory arrays and FSMs for the HW03 single-cycle core |
| Stage 6: Modern Verilog Reading | ch10 | Read SystemVerilog testbenches and navigate the HW04 pipelined core framework |
| Continuous Reference | [Appendix](appendix/README.md) | Consult during RTL implementation and debugging sessions |

---

## 5. SystemVerilog Integrated Overview

[`ch10/overview.sv`](ch10/overview.sv) and [`ch10/tb_overview.sv`](ch10/tb_overview.sv) integrate combinational and sequential constructs in a unified reference module. They provide five 4-bit functional units (`inv4`, `add4`, `mux4`, `dff1`, `mini_alu`) alongside a self-checking testbench.

```bash
make waves       # Generate VCD waveforms and launch viewer
```

---

## 6. Project Curriculum Mapping

| Assignment | Core Technical Focus | Required Tutorial Chapters |
|---|---|---|
| HW01 | Architectural-State Programming | ch02 (Instruction field layouts) |
| HW02 | TinyRV Building Blocks | ch02, ch04, ch05, ch06, ch07 |
| HW03 | TinyRV Core Integration | ch05, ch06, ch07, ch08 |
| HW04 | Forwarding and Load-Use Interlock | ch05, ch07, ch09, ch10 |

---

## 7. Example Naming Conventions

| Prefix / Pattern | Purpose and Invocation |
|---|---|
| `exNN_name.v` | Synthesizable design module or standalone runnable example; execute via `make test` |
| `tb_exNN.v` | Dedicated self-checking testbench for `exNN` |
| `badNN_name.v` | Intentional syntax error or logic defect for diagnostics training; inspect via `make errors` |

Simulation exit conventions automate test validation. Passing runs print `$display("PASS ...")` and exit cleanly with `$finish(0)`. Detected faults trigger `$fatal(1, "FAIL ...")`, returning a non-zero exit status that stops the Make build. Assignment grading harnesses enforce this exact exit protocol.
