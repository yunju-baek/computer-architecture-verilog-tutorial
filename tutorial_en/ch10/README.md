# Chapter 10: Verilog-2001 versus SystemVerilog Syntax Comparison

## 1. Learning Objectives

This chapter establishes the syntactic and semantic mapping between student-authored Verilog-2001 RTL code and the SystemVerilog (IEEE 1800-2012) verification testbenches and reference models provided in the lab environment. Compiling with Icarus Verilog's `-g2012` flag directly interoperates both standards in a unified simulation.

Two interoperability rules:

1. Student RTL implementations maintain strict Verilog-2001 compliance for synthesizable portability.
2. Read and interpret SystemVerilog constructs (`logic`, `always_comb`, `enum`, `struct`) in evaluation harnesses to align module interfaces.

Five core competencies:

1. Verify instantiation compatibility between Verilog-2001 RTL and SystemVerilog testbenches.
2. Differentiate `always_comb`, `always_ff`, and `always_latch` static intent and sensitivity lists.
3. Understand automatic `wire`/`reg` resolution under the unified `logic` data type.
4. Pack and unpack bitfields using `typedef enum` and `packed struct` definitions.
5. Reference the 1:1 syntax comparison table across types, blocks, and operators.

---

## 2. Interoperability Architecture: Verilog-2001 and SystemVerilog

[`ex01_style.sv`](ex01_style.sv) implements a 2:1 multiplexer in both dialects:

```verilog
// 1. Verilog-2001 dialect (Student RTL implementation standard)
module mux_verilog2001(
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       sel,
  output reg  [7:0] y
);
  always @* begin
    y = a;
    if (sel) y = b;
  end
endmodule

// 2. SystemVerilog dialect (Evaluation testbench and reference model standard)
module mux_systemverilog(
  input  logic [7:0] a,
  input  logic [7:0] b,
  input  logic       sel,
  output logic [7:0] y
);
  always_comb begin
    y = a;
    if (sel) y = b;
  end
endmodule
```

In [`tb_ex01.sv`](tb_ex01.sv), a SystemVerilog testbench instantiates both modules directly:

```verilog
logic [7:0] a, b;
logic       sel;
logic [7:0] mux_v, mux_sv;

// Directly instantiate Verilog-2001 module inside SystemVerilog testbench
mux_verilog2001   u_mux_v  (.a(a), .b(b), .sel(sel), .y(mux_v));
mux_systemverilog u_mux_sv (.a(a), .b(b), .sel(sel), .y(mux_sv));
```

Simulation trace:

```text
--- Combinational logic comparison ---
sel=0 -> Verilog aa, SystemVerilog aa
sel=1 -> Verilog bb, SystemVerilog bb
--- Sequential logic comparison ---
after reset -> Verilog 00, SystemVerilog 00
after d=5a  -> Verilog 5a, SystemVerilog 5a
PASS ch10 ex01 syntax comparison
```

---

## 3. Behavioral Comparison: `always_comb` versus `always @*`

[`ex03_always_comb.sv`](ex03_always_comb.sv) demonstrates differences at simulation timestamp 0:

```verilog
logic [3:0] a = 4'd3;
logic [3:0] b = 4'd4;
```

Simulation trace comparison:

```text
   0ns always_comb=xxxx  always @*=xxxx
   1ns always_comb=0111  always @*=xxxx
   2ns input updated    always_comb=1001  always @*=1001
```

`always_comb` executes an automatic initial evaluation at timestamp 0, computing outputs immediately even if inputs do not transition. In contrast, `always @*` waits for a subsequent input change event. Because testbenches in this course issue an initial reset sequence, both constructs behave identically during active evaluation.

---

## 4. SystemVerilog Data Type Extensions

[`ex02_enum_struct.sv`](ex02_enum_struct.sv) demonstrates high-level abstractions used in reference models:

### 1. Enumerations (`typedef enum`)

```verilog
typedef enum logic [1:0] {
  IDLE     = 2'd0,
  SAW_ONE  = 2'd1,
  SAW_TWO  = 2'd2,
  SAW_MANY = 2'd3
} detect_state_t;

detect_state_t state;
```

Synthesizes into hardware identical to a group of Verilog-2001 `localparam` declarations. During simulation, `.name()` prints symbolic string labels to console logs.

### 2. Packed Structures (`typedef struct packed`)

```verilog
typedef struct packed {
  logic [6:0] funct7;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] rd;
  logic [6:0] opcode;
} rv32_r_type_t;

rv32_r_type_t decoded;
decoded = raw_word;    // Directly maps 32-bit bus into named struct fields
```

Directly maps to Verilog-2001 part-select slicing (`instr[19:15]`). Packed fields enhance readability in instruction decoders.

---

## 5. 1:1 Comparative Reference Table

### 1. Data Types and Net Declarations

| SystemVerilog | Verilog-2001 | Hardware Mapping and Notes |
|---|---|---|
| `logic` | `wire` (continuous) / `reg` (procedural) | Compiler infers net or variable based on driving context |
| `bit` | `reg` | 2-state logic (`0`, `1`) for high-speed behavioral models |
| `int` | `integer` | 32-bit signed integer loop index |
| `typedef enum` | Group of `localparam` constants | FSM state encodings |
| `struct packed` | Concatenation (`{}`) and Part-Select | Contiguous bitfield vectors |

### 2. Procedural Blocks and Control Structures

| SystemVerilog | Verilog-2001 | Hardware Mapping and Notes |
|---|---|---|
| `always_comb` | `always @*` | Combinational functional block |
| `always_ff @(posedge clk)` | `always @(posedge clk)` | Synchronous sequential register |
| `always_latch` | `always @*` (incomplete branches) | Transparent latch; avoid in synchronous cores |
| `unique case` | `case` + `default` | Parallel multiplexer without priority |
| `priority case` | Chained `if-else` | Priority encoder |

### 3. Operators and System Tasks

| SystemVerilog | Verilog-2001 | Notes |
|---|---|---|
| `i++`, `i--`, `i += 4` | `i = i + 1`, `i = i - 1`, `i = i + 4` | Compound arithmetic operators |
| `'0`, `'1` | `{WIDTH{1'b0}}`, `{WIDTH{1'b1}}` | Width-adaptive fill constants |
| `for (int i=0; ...)` | `integer i;` declared outside loop | Explicit external index declaration in Verilog-2001 |
| `$error(...)` | `$display` + error counter increment | Testbench error logging |
| `assert (cond) else $fatal` | `if (!(cond)) $fatal(1, ...)` | Programmatic assertion checks |

---

## 6. Integrated Overview Module

[`overview.sv`](overview.sv) and [`tb_overview.sv`](tb_overview.sv) integrate five functional units (`inv4`, `add4`, `mux4`, `dff1`, `mini_alu`) alongside a self-checking testbench in SystemVerilog.

```bash
make test      # Execute comparison suites
make waves     # Generate VCD waveforms
make clean
```

---

## 7. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| Verilog-2001 synthesizable RTL | Student source files (`rtl/*.v`) in HW02 through HW04 |
| SystemVerilog testbench reading | Interpreting course testbenches (`tests/*.v`) |
| `logic` to `wire`/`reg` mapping | Connecting top-level processor interfaces |
| `packed struct` field alignments | Bitfield decoding in HW02 `rv32i_decode.v` and HW03 |

---

## 8. Concept Check Questions

1. Why does student RTL maintain Verilog-2001 compliance while testbenches leverage SystemVerilog?
2. How does SystemVerilog's `logic` keyword unify the roles of `wire` and `reg`?
3. What architectural timing distinction causes `always_comb` to evaluate differently from `always @*` at timestamp 0?
4. What ordering rule maps fields of a `typedef struct packed` to a 32-bit vector bus?
5. Write the Verilog-2001 equivalent for SystemVerilog's adaptive `'0` constant.

---

Previous Chapter: [Chapter 09: Synthesizable RTL Coding](../ch09/README.md) | Appendix: [Quick Reference Guide](../appendix/README.md)
