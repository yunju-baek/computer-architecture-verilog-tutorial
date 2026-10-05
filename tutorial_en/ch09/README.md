# Chapter 09: Synthesizable RTL Coding Guidelines

## 1. Learning Objectives

This chapter establishes the boundary between simulation-only constructs and the synthesizable Verilog subset that maps into physical ASIC standard cells and FPGA logic fabrics. All hardware source files (`rtl/*.v`) across this lab suite must conform strictly to industry-standard RTL synthesis rules.

Three fundamental synthesis rules:

1. Time delays (`#`) and `initial` blocks are confined strictly to testbenches (`tests/*.v`).
2. All sequential state initialization is governed by synchronous `reset` logic active upon power-on.
3. Iterative loops are limited to constant-bounded `for` loops that unroll statically into parallel gate arrays at elaboration time.

Five core competencies:

1. Master the synthesizable Verilog-2001 construct subset.
2. Identify non-synthesizable simulation features and apply synthesizable hardware alternatives.
3. Contrast identical simulation behaviors against non-synthesizable structural defects.
4. Replace high-latency division and modulus operators (`/`, `%`) with zero-delay bit shifts and masks.
5. Apply the 27-point pre-submission RTL design audit checklist.

---

## 2. Synthesizable Verilog Subset

[`ex01_synthesizable.v`](ex01_synthesizable.v) demonstrates a fully synthesizable arithmetic accumulator:

```verilog
module ex01_synthesizable #(
  parameter WIDTH = 8
)(
  input  wire             clk,
  input  wire             reset,
  input  wire             enable,
  input  wire [1:0]       operation,
  input  wire [WIDTH-1:0] operand,
  output reg  [WIDTH-1:0] result,
  output wire             is_zero
);

  localparam [1:0] OP_ADD = 2'd0, OP_SUB = 2'd1, OP_AND = 2'd2, OP_OR = 2'd3;

  reg [WIDTH-1:0] next_result;

  // Combinational block: Blocking assignments (=) and default pre-assignment
  always @* begin
    next_result = result;
    case (operation)
      OP_ADD:  next_result = result + operand;
      OP_SUB:  next_result = result - operand;
      OP_AND:  next_result = result & operand;
      default: next_result = result | operand;
    endcase
  end

  // Sequential block: Nonblocking assignments (<=) and synchronous reset
  always @(posedge clk) begin
    if (reset)
      result <= {WIDTH{1'b0}};
    else if (enable)
      result <= next_result;
  end

  assign is_zero = ~|result;

endmodule
```

Simulation output:

```text
add 30 -> result=30 is_zero=0
add 05 -> result=35 is_zero=0
sub 05 -> result=30 is_zero=0
and 0f -> result=00 is_zero=1
or ab -> result=ab is_zero=0
PASS ch09 ex01 synthesizable constructs
```

### Non-Synthesizable Constructs and Hardware Replacements

| Simulation-Only Construct | Intended Use Case | Synthesizable RTL Alternative |
|---|---|---|
| `initial` blocks | Testbench stimulus initialization | Synchronous `reset` branch in `always @(posedge clk)` |
| Time delay (`#10`) | Testbench clock and event pacing | Active clock edges and register state transitions |
| `$display`, `$finish` | Console logging and run termination | Confined strictly to testbench sources (`tests/`) |
| `$readmemh` in design RTL | Memory image loading | FPGA BRAM synthesis attributes or explicit write ports |
| `task` | Procedural testbench sequences | Combinational `function` or multi-cycle FSM controller |
| 4-state comparison (`===`) | Checking for `x`/`z` states | 2-state hardware comparators (`==`, `!=`) |
| Dynamic `while`, `repeat` | Behavioral software loops | Static-bound unrolled `for` loops or multi-cycle FSM |
| Variable division (`/`, `%`) | Mathematical quotient and remainder | Barrel shifters (`>>`, `&`) or dedicated pipelined divider IP |

---

## 3. Discrepancy Between Simulation Equivalence and Synthesis Viability

[`ex02_compare.v`](ex02_compare.v) contrasts two counter modules that produce identical simulation waveforms:

```verilog
// 1. Synthesizable counter
module counter_synthesizable (
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  always @(posedge clk) begin
    if (reset) count <= 4'd0;
    else       count <= count + 4'd1;
  end
endmodule

// 2. Simulation-only counter (Strictly prohibited in synthesizable RTL)
module counter_simulation_only (
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  initial count = 4'd0;        // Silicon flip-flop state is undefined at power-on

  always @(posedge clk) begin
    #1;                        // Synthesis tools ignore delays, creating timing mismatches
    if (reset) count = 4'd0;   // Blocking assignment risks synthesis race conditions
    else       count = count + 4'd1;
  end
endmodule
```

Even when simulation waveforms match, RTL code containing `initial`, `#1`, or blocking assignments in clocked blocks causes synthesis failures or post-synthesis timing violations.

---

## 4. Hardware Optimization of Division and Modulus

[`bad03_division.v`](bad03_division.v) contrasts mathematical operators with bit-level hardware equivalents:

```verilog
// 1. Variable division: Synthesizes massive multi-stage subtractor arrays with severe area and delay penalties
assign by_variable = value / divisor;

// 2. Power-of-two (2^N) division: Implemented via wire slicing (Shift) with zero silicon delay
assign by_power_of_two = value >> 4;       // Mathematically identical to value / 16

// 3. Power-of-two modulus: Implemented via a single bitwise AND gate layer
assign mod_power = value & 16'h000f;       // Mathematically identical to value % 16
```

In processor cache tagging, indexing, and offset extraction (HW04), block sizes are powers of two, allowing bit slicing (`addr[9:4]`) and masking to achieve zero-cost hardware routing.

---

## 5. Twenty-Seven Point RTL Self-Check Checklist

Verify these 27 invariants prior to assignment submission:

### 1. Declarations and Data Types
1. Are nets driven by continuous `assign` declared as `wire`?
2. Are variables assigned in procedural blocks declared as `reg`?
3. Are all internal interconnect buses declared with explicit bit widths?
4. Are all integer literals explicitly sized (`32'h0000_0000`)?

### 2. Combinational Logic Circuits
5. Does the sensitivity list specify `always @*`?
6. Are all procedural assignments driven using blocking operators (`=`)?
7. Are default values pre-assigned to all outputs at the head of the block?
8. Does every `case` statement include a `default` branch?
9. Is `casex` avoided in favor of `case` or `casez`?

### 3. Sequential Logic Circuits
10. Does the sensitivity list specify `always @(posedge clk)`?
11. Are all state transitions driven using nonblocking operators (`<=`)?
12. Is each state register driven within exactly one `always` block?
13. Does the control hierarchy match specifications (`reset > load > enable`)?
14. Is the reset architecture consistently synchronous across modules?

### 4. Bit Width and Signed Arithmetic
15. Is carry-out preserved using an expanded 33-bit addition context?
16. Are both operands explicitly cast with `$signed` in signed comparisons?
17. Is the shifted operand explicitly cast with `$signed` in arithmetic right shifts (`>>>`)?
18. Are sign extension and zero extension applied in their correct architectural contexts?

### 5. Module Hierarchy
19. Are all submodules instantiated using named port mapping (`.port(signal)`)?
20. Are all module input ports actively driven?
21. Are parameterized submodules overridden using explicit `#(.PARAM(val))` syntax?

### 6. Synthesis Boundaries
22. Are time delays (`#`) eliminated from design RTL?
23. Is state initialization driven by synchronous `reset` rather than `initial` blocks?
24. Are `$display` and related system tasks relegated exclusively to testbenches?
25. Are loop boundaries in procedural `for` statements bounded by constants?
26. Is hierarchical signal probing (`.`) confined strictly to testbenches?

### 7. Compiler Diagnostics
27. Does compilation with `iverilog -g2012 -Wall` produce exactly zero warnings?

---

## 6. Complete Chapter Verification

```bash
make test      # Verify functional synthesizable examples
make errors    # Inspect intentional non-synthesizable defect diagnostics
make clean
```

---

## 7. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| Structural file separation | `rtl/` (synthesizable) vs. `tests/` (simulation-only) |
| Shift-based arithmetic | HW02 ALU and HW04 cache address indexing |
| 27-point self-check checklist | Pre-submission audit across HW02 through HW04 |
| Zero-warning compilation | Automated grading CI/CD regression gating |

---

## 8. Concept Check Questions

1. Why must synthesizable RTL omit `initial` blocks in favor of synchronous resets?
2. How do synthesis compilers handle time delays (`#3`), and what discrepancies arise?
3. What grammatical condition must a `for` loop satisfy to synthesize into hardware?
4. Explain the mathematical basis for replacing `value / 16` with `value >> 4` in unsigned arithmetic.
5. List three common defect classes caught by `iverilog -g2012 -Wall`.

---

Previous Chapter: [Chapter 08: Testbench Methodologies](../ch08/README.md) | Next Chapter: [Chapter 10: SystemVerilog Comparison](../ch10/README.md)
