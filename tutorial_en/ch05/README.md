# Chapter 05: Sequential Circuit Design

## 1. Learning Objectives

This chapter establishes design rules for sequential circuits that store and transition architectural state on active clock edges. The Program Counter (PC), Register File, and 5-stage pipeline registers are designed using the sequential template defined here.

**The Sequential Design Invariant**: All state transitions occurring on active clock edges must use nonblocking assignments (`<=`).

Six core competencies:

1. Formulate sequential blocks using `always @(posedge clk)`.
2. Differentiate the physical hardware timing between nonblocking (`<=`) and blocking (`=`) assignments.
3. Implement control priority encoding (`reset > load > enable`).
4. Apply synchronous resets for deterministic state initialization.
5. Model state retention and hardware stall interlocks.
6. Avoid multidriver conflicts and mixed-assignment hazards.

---

## 2. Structure of `always @(posedge clk)` Sequential Blocks

```verilog
module ex_dff(
  input  wire       clk,
  input  wire       reset,
  input  wire [7:0] d,
  output reg  [7:0] q          // Driven in procedural block; declared as reg
);

  always @(posedge clk) begin
    if (reset)
      q <= 8'h00;              // Nonblocking assignment (<=)
    else
      q <= d;
  end

endmodule
```

Three mandatory design rules:

1. Rising clock edge sensitivity: The sensitivity list specifies `@(posedge clk)`, updating state only during `0` to `1` transitions.
2. Nonblocking assignments (`<=`): State transitions use nonblocking assignments to model concurrent register updates across clock domains.
3. Automatic state retention: Omitting an `else` branch in a sequential block maintains prior state, reflecting standard physical flip-flop behavior.

Review [`ex01_dff.v`](ex01_dff.v) simulation output:

```text
  Time   reset d    q
------------------
   6ns   1   ff   00  (Reset takes precedence)
  16ns   0   aa   aa  (d transfers to q on clock edge)
  17ns   0   bb   aa  (q holds constant prior to next edge)
  26ns   0   bb   bb  (q updates on next clock edge)
  36ns   0   cc   cc
PASS ch05 ex01 dff
```

Even though input `d` transitions at 17ns, output `q` retains its stored value until the subsequent rising clock edge at 26ns.

---

## 3. Hardware Timing: Nonblocking versus Blocking Assignments

[`ex02_blocking.v`](ex02_blocking.v) compares two implementations of a 3-stage shift register:

```verilog
// Method 1: Proper sequential implementation (Nonblocking)
always @(posedge clk) begin
  q0 <= d;
  q1 <= q0;      // Reads q0 state from immediately before the clock edge
  q2 <= q1;      // Reads q1 state from immediately before the clock edge
end

// Method 2: Defective sequential implementation (Blocking)
always @(posedge clk) begin
  q0 = d;
  q1 = q0;       // Reads newly assigned q0 within the same delta cycle
  q2 = q1;       // Reads newly assigned q1 within the same delta cycle
end
```

Simulation trace from [`tb_ex02.v`](tb_ex02.v):

```text
cycle d | nonblocking q2 q1 q0 | blocking q2 q1 q0
------+---------------------+------------------
  0   1 |        0  0  1     |      1  1  1
  1   0 |        0  1  0     |      0  0  0
  2   0 |        1  0  0     |      0  0  0
  3   0 |        0  0  0     |      0  0  0
  4   0 |        0  0  0     |      0  0  0
```

With nonblocking assignments, bit `1` shifts sequentially across three cycles through three cascaded flip-flops. With blocking assignments, evaluation order causes the value to pierce through all stages within a single cycle, collapsing the circuit into a single flip-flop.

### Assignment Operator Selection Rule

| Procedural Block Type | Required Operator | Hardware Mapping |
|---|---|---|
| Sequential (`always @(posedge clk)`) | Nonblocking (`<=`) | Concurrent multi-register state updates |
| Combinational (`always @*`) | Blocking (`=`) | Cascaded logic gates and dataflow routing |

---

## 4. Control Priority Encoding (`reset > load > enable`)

[`ex03_control.v`](ex03_control.v) models the control hierarchy of a Program Counter:

```verilog
always @(posedge clk) begin
  if (reset)
    state <= 32'h0000_0000;
  else if (load)
    state <= load_value;
  else if (enable)
    state <= state + 32'd4;
  // State holds automatically if all conditions are false (stall behavior)
end
```

Simulation output:

```text
reset=1                    -> state=00000000
enable=1                   -> state=00000004
enable=1                   -> state=00000008
load=1 enable=1            -> state=00001000  (load overrides enable)
reset=1 load=1 enable=1    -> state=00000000  (reset overrides load and enable)
enable=1 for 2 cycles      -> state=00000008
all 0 for 2 cycles         -> state=00000008  (state holds constant)
PASS ch05 ex03 control
```

Chaining `if-else` branches establishes clear hardware precedence: `reset` dominates, followed by `load`, and finally `enable`.

---

## 5. Synchronous Reset Standard

[`ex04_reset.v`](ex04_reset.v) contrasts synchronous and asynchronous resets:

```verilog
// Synchronous reset (standard across this course)
always @(posedge clk) begin
  if (reset) count <= 4'd0;
  else       count <= count + 4'd1;
end

// Asynchronous reset
always @(posedge clk or posedge reset) begin
  if (reset) count <= 4'd0;
  else       count <= count + 4'd1;
end
```

Synchronous resets evaluate exclusively on rising clock edges, filtering glitch noise and simplifying static timing analysis. All course projects (HW03 through HW05) standardize on synchronous resets.

---

## 6. Three Sequential Design Defects

Execute `make errors` to inspect compiler diagnostics across three intentional defects:

```bash
make errors
```

### Defect 1: Multidriver Registers (`bad01_two_always.v`)

Driving the same `reg` from multiple `always` blocks causes simulation nondeterminism and synthesis conflicts. Consolidate updates into a single `always` block.

### Defect 2: Blocking Assignments in Sequential Blocks (`bad02_blocking_seq.v`)

Using `=` inside clocked blocks makes synthesis sensitive to statement ordering, frequently collapsing multi-stage pipelines.

### Defect 3: Mixing Assignment Operators (`bad03_mixed.v`)

Mixing `=` and `<=` inside the same clocked block creates subtle race conditions and timing hazards.

---

## 7. Six-Point Sequential Design Checklist

1. Are all state variables declared as `reg`?
2. Does the sensitivity list specify `always @(posedge clk)`?
3. Are all state updates driven using nonblocking assignments (`<=`)?
4. Is each state register driven by exactly one `always` block?
5. Does control priority follow specifications (`reset > load > enable`)?
6. Is reset behavior synchronous across all modules?

---

## 8. Complete Chapter Verification

```bash
make test      # Verify functional examples
make errors    # Inspect intentional defect diagnostics
make clean
```

---

## 9. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| `always @(posedge clk)` and `<=` | Sequential state units across HW03, HW04, and HW05 |
| `reset > load > enable` priority | Program Counter in HW03 `rtl/pc_counter.v` |
| Synchronous reset architecture | Reset logic across processor cores |
| Clock-disabled state retention | Load-use hazard stall interlock in HW05 |
| Concurrent pipeline register updates | Pipeline stage registers in HW05 |

---

## 10. Concept Check Questions

1. Why must sequential circuits use nonblocking assignments (`<=`) inside clocked blocks?
2. What hardware distortion occurs when modeling a 3-stage shift register using blocking assignments (`=`)?
3. Why does omitting the `else` branch in a clocked block avoid inferring unwanted latches?
4. Contrast the sensitivity list notation between synchronous and asynchronous resets.
5. Why does testbench verification introduce a `#1` delay after `@(posedge clk)` before sampling register outputs?

---

Previous Chapter: [Chapter 04: Combinational Circuit Design](../ch04/README.md) | Next Chapter: [Chapter 06: Hierarchy and Parameterization](../ch06/README.md)
