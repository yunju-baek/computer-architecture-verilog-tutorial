# Chapter 04: Combinational Circuit Design

## 1. Learning Objectives

This chapter establishes design methods for complex combinational logic using procedural `always @*` blocks. The HW02 RV32 ALU and the HW02 single-cycle instruction decoder follow the architectural template developed here.

**The Combinational Design Invariant**: Every output signal driven within a combinational procedural block must receive an explicit assignment across all possible execution paths. Adhering to this invariant synthesizes pure combinational logic; omitting an assignment along any branch forces synthesis tools to infer unwanted transparent latches.

Six core competencies:

1. Understand the operation of automatic sensitivity lists (`always @*`).
2. Construct mutually exclusive parallel selectors using `case` statements.
3. Apply default value pre-assignment to prevent latch inference.
4. Design priority encoders using `if-else` chains and `casez` masks.
5. Encapsulate reusable combinational sub-blocks using `function` definitions.
6. Verify branch completeness and default fallbacks.

---

## 2. Structure of `always @*` Combinational Blocks

```verilog
module ex_comb(
  input  wire [7:0] in_data,
  output reg  [7:0] out_data     // Driven in procedural block; declared as reg
);

  always @* begin
    out_data = in_data + 8'd1;   // Blocking assignment (=)
  end

endmodule
```

Three mandatory design rules:

1. Output net declaration as `reg`: Nets updated within procedural `always` blocks must be declared as `reg`.
2. Automatic sensitivity list (`@*`): The compiler automatically registers all RHS inputs, preventing simulation mismatches caused by incomplete manual sensitivity lists.
3. Blocking assignments (`=`): Use blocking assignments within combinational blocks so each expression updates sequentially and immediately.

---

## 3. Multiplexers via `case` Statements

[`ex01_mux4.v`](ex01_mux4.v) implements a 4:1 multiplexer:

```verilog
module ex01_mux4(
  input  wire [7:0] in0,
  input  wire [7:0] in1,
  input  wire [7:0] in2,
  input  wire [7:0] in3,
  input  wire [1:0] sel,
  output reg  [7:0] y
);

  always @* begin
    case (sel)
      2'b00:   y = in0;
      2'b01:   y = in1;
      2'b10:   y = in2;
      default: y = in3;   // Fallback handling 2'b11 and uninitialized x/z states
    endcase
  end

endmodule
```

```bash
make test
```

Simulation output:

```text
sel | y
----+----
 00 | aa
 01 | bb
 10 | cc
 11 | dd
sel=x0 -> y=dd  (default path determines value)
PASS ch04 ex01 mux4
```

### Complete `default` Branch Handling

1. Handling 4-state logic: In transient or uninitialized states where inputs carry `x` or `z`, the `default` branch guarantees deterministic output behavior.
2. Preventing latch inference: Explicitly covering all unlisted bit patterns eliminates unassigned branches.

Comparison of `case` variants:

| Construct | Matching Rule | Primary Application |
|---|---|---|
| `case` | Exact bit-for-bit match | Instruction decoders, ALU operation selection |
| `casez` | Treats `?` and `z` bits as Don't-Care | Priority encoders, bitmask matching |
| `casex` | Treats `x` bits as Don't-Care | Avoid in synthesizable RTL; causes simulation-synthesis mismatches |

---

## 4. Default Value Pre-Assignment Pattern

[`ex02_default.v`](ex02_default.v) contrasts multi-output control block structures:

```verilog
// Recommended pattern: Default value pre-assignment
always @* begin
  // 1. Pre-assign safe default values to all outputs
  alu_select   = 2'b00;
  write_enable = 1'b0;
  memory_read  = 1'b0;
  illegal      = 1'b0;

  // 2. Selectively override control signals on matching branches
  case (opcode)
    4'h1: begin alu_select = 2'b00; write_enable = 1'b1;                     end
    4'h2: begin alu_select = 2'b01; write_enable = 1'b1;                     end
    4'h3: begin alu_select = 2'b10; write_enable = 1'b1; memory_read = 1'b1; end
    4'h4: begin                     write_enable = 1'b1;                     end
    default: illegal = 1'b1;
  endcase
end
```

Pre-assigning defaults at the head of the procedural block ensures every output net receives a deterministic value even if subsequent branches omit it. This structure defines the standard coding style for HW02 `rv32i_decode.v`.

---

## 5. Priority Encoder Architecture

[`ex03_priority.v`](ex03_priority.v) demonstrates two priority selection architectures when multiple requests assert simultaneously:

```verilog
// Method 1: Chained if-else priority structure
always @* begin
  granted_index = 2'd0;
  any_granted   = 1'b1;

  if (request[0])
    granted_index = 2'd0;
  else if (request[1])
    granted_index = 2'd1;
  else if (request[2])
    granted_index = 2'd2;
  else if (request[3])
    granted_index = 2'd3;
  else
    any_granted = 1'b0;
end

// Method 2: casez parallel mask structure
always @* begin
  granted_index = 2'd0;
  any_granted   = 1'b1;

  casez (request)
    4'b???1: granted_index = 2'd0;
    4'b??10: granted_index = 2'd1;
    4'b?100: granted_index = 2'd2;
    4'b1000: granted_index = 2'd3;
    default: any_granted   = 1'b0;
  endcase
end
```

The nested `if-else` prioritization directly models the HW04 forwarding priority structure (`EX/MEM` over `MEM/WB`).

---

## 6. Combinational Macro Modularization with `function`

[`ex04_function.v`](ex04_function.v) encapsulates repeated combinational logic inside a synthesizable function:

```verilog
function [31:0] pick_larger_signed;
  input [31:0] left;
  input [31:0] right;
  begin
    pick_larger_signed = ($signed(left) > $signed(right)) ? left : right;
  end
endfunction

assign max_signed = pick_larger_signed(a, b);
```

Rules governing synthesizable `function` blocks:

1. Functions omit timing controls (`#`, `@`) and synthesize into zero-delay combinational networks.
2. Internal constant-bound `for` loops unroll into parallel hardware gate arrays during synthesis.

---

## 7. Diagnostic Analysis: Three Combinational Defects

Execute `make errors` to inspect compiler diagnostics across three intentional defects:

```bash
make errors
```

### Defect 1: Latch Inference via Incomplete Branching (`bad01_latch.v`)

```verilog
always @* begin
  if (sel)
    y = in1;
  // Omitted sel=0 branch: hardware infers a transparent latch to hold previous state
end
```

When an assignment is omitted under certain input conditions, synthesis tools infer a physical latch to retain the prior value. Latches introduce timing hazards and glitches. Pre-assigning default outputs eliminates latch inference.

### Defect 2: Incomplete `case` Branching (`bad02_incomplete_case.v`)

Occurs when a `case` statement omits both specific input combinations and the `default` branch.

### Defect 3: Incomplete Manual Sensitivity List (`bad03_sensitivity.v`)

If a manual sensitivity list specifies `always @(a)` while omitting input `b`, the simulator does not re-evaluate the block when `b` transitions, holding stale values. Synthesis tools ignore manual sensitivity lists and build complete circuits, creating simulation-synthesis discrepancies. Always write `always @*`.

---

## 8. Five-Point Combinational Design Checklist

1. Are all output ports and procedurally assigned signals declared as `reg`?
2. Does the sensitivity list specify `always @*`?
3. Are all procedural assignments using blocking operators (`=`)?
4. Are default values pre-assigned to all outputs at the head of the block?
5. Does every `case` statement include a `default` branch?

---

## 9. Complete Chapter Verification

```bash
make test      # Verify functional examples
make errors    # Inspect intentional defect diagnostics
make clean
```

---

## 10. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| `always @*` with blocking assignments | Operational kernel in HW02 `rtl/alu.v` |
| Default value pre-assignment | Control decoder in HW02 `rtl/rv32i_decode.v` |
| Exhaustive `case` with `default` | Opcode and function decoding across HW02 |
| Chained `if-else` priority | Forwarding path selection in HW04 |
| Pure combinational synthesis (zero latches) | Submission verification across all projects |

---

## 11. Concept Check Questions

1. Why must output signals assigned inside `always @*` blocks be declared as `reg`?
2. How does pre-assigning default output values prevent latch inference?
3. How does `casez` differ from standard `case` matching?
4. What simulation-synthesis discrepancy occurs when writing an incomplete manual sensitivity list `always @(a)`?
5. Recite the five checkpoints in the combinational design checklist.

---

Previous Chapter: [Chapter 03: Operators and Bit-Width Rules](../ch03/README.md) | Next Chapter: [Chapter 05: Sequential Circuit Design](../ch05/README.md)
