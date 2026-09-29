# Appendix: Verilog HDL Quick Reference Guide

This manual aggregates syntax conventions, design rules, inspection checklists, and error diagnostics for immediate reference during RTL implementation and debugging.

---

## 1. Standard Execution Command Reference

### Tutorial Chapter Verification Commands

```bash
make test          # Execute all 10 chapter test suites
make chapters      # Run baseline circuit examples across chapters
make errors        # Execute intentional defect and pitfall examples
make clean         # Remove compilation artifacts

cd ch03 && make test      # Execute Chapter 03 suite
cd ch03 && make errors    # Analyze Chapter 03 error diagnostics
```

### Direct Icarus Verilog Compilation and Simulation

```bash
iverilog -g2012 -Wall -s <top_module> -o build/out.vvp <source_files...>
vvp build/out.vvp
echo $?            # 0: PASS, 1: $fatal error termination
```

### Assignment Verification and Deliverable Packaging

```bash
cd assignments/hw02
make setup-check   # Verify toolchain prerequisites
make test          # Run public test suite
make student-test  # Run student test suite
make evidence      # Generate evaluation VCD/CSV artifacts
make clean
```

---

## 2. Data Type Declarations and Signal Classification (ch02)

```verilog
wire        single_net;                // 1-bit net driven by continuous assign
wire [31:0] bus_data;                  // 32-bit bus net
reg  [31:0] state_reg;                 // Register driven in procedural blocks (always/initial)
reg  [31:0] memory_array [0:255];      // 2D memory array: 32-bit width x 256 words
integer     loop_idx;                  // 32-bit signed integer loop variable (testbench only)
genvar      g_idx;                     // Index variable for generate unrolling
parameter   WIDTH = 32;                // Module parameter overridable at instantiation
localparam  DEPTH = 1 << 8;            // Module-internal constant (not overridable)
```

| Driver Source | Required Data Type |
|---|---|
| Left-hand side of continuous `assign` | `wire` |
| Connection to an output port of a sub-module instance | `wire` |
| Left-hand side in procedural `always` blocks (combinational/sequential) | `reg` |
| Left-hand side in procedural `initial` testbench blocks | `reg` |

---

## 3. Numeric Literals and State Representations (ch02)

```verilog
4'b1010          // 4-bit binary (decimal 10)
8'o377           // 8-bit octal (decimal 255)
8'd255           // 8-bit decimal
32'hdead_beef    // 32-bit hexadecimal with readability underscores
{8{1'b1}}        // Replicate bit 1 across 8 bits (8'hff)
{WIDTH{1'b0}}    // Fill parameterized width with zeros
```

| Logic State | Hardware Meaning |
|---|---|
| `0`, `1` | Definite logic low / high level |
| `x` | Unknown, uninitialized, or contention clash |
| `z` | High impedance, floating, or un-driven wire |

---

## 4. Bit-Level Slicing and Concatenation (ch02)

```verilog
instr[31]                        // Single-bit extraction (Bit-Select)
instr[19:15]                     // Constant range slicing (Part-Select)
data[idx*8 +: 8]                 // Variable base 8-bit slicing (Indexed Part-Select)
{a, b}                           // Concatenation operator
{20{sign_bit}}                   // Bit replication operator
{{20{instr[31]}}, instr[31:20]}  // 32-bit sign-extension of 12-bit immediate
{20'b0, instr[31:20]}            // 32-bit zero-extension of 12-bit immediate
{1'b0, a} + {1'b0, b}            // 33-bit addition preserving carry-out
```

---

## 5. Hardware Operator Precedence (ch03)

| Precedence | Category | Operators |
|---|---|---|
| 1 (Highest) | Unary & Reduction | `~`, `!`, `+`, `-`, `&`, `~&`, `\|`, `~\|`, `^`, `~^` |
| 2 | Multiplicative | `*`, `/`, `%` |
| 3 | Additive | `+`, `-` |
| 4 | Shift | `<<`, `>>`, `<<<`, `>>>` |
| 5 | Relational | `<`, `<=`, `>`, `>=` |
| 6 | Equality | `==`, `!=`, `===`, `!==` |
| 7 | Bitwise AND | `&` |
| 8 | Bitwise XOR / XNOR | `^`, `~^` |
| 9 | Bitwise OR | `\|` |
| 10 | Logical AND | `&&` |
| 11 | Logical OR | `\|\|` |
| 12 (Lowest) | Conditional Ternary | `? :` |

Always use explicit parentheses when combining arithmetic, relational, and bitwise operators to eliminate ambiguity.

---

## 6. Five Bit-Width Expansion Rules (ch03)

| Operational Context | Recommended Design Pattern |
|---|---|
| Preserving Carry-Out | Prefix operands with `{1'b0, x}` to force an N+1 bit expression context |
| Sizing Integer Constants | Explicitly declare bit widths for all constants (`32'd1`, `4'b0001`) |
| Compound Expressions | Split sub-expressions into intermediate `wire` nets with explicit widths |
| Signed Comparisons | Cast both operands explicitly using `$signed` |

The operational bit width of an expression equals the maximum bit width among the LHS target and all RHS operands.

---

## 7. Signed Arithmetic and Shift Operations (ch03)

```verilog
$signed(a) < $signed(b)      // Signed comparison: requires casting on both operands
$signed(value) >>> shamt     // Arithmetic right shift: replicates sign bit into MSB positions
value >> shamt               // Logical right shift: fills MSB positions with zeros
value << shamt               // Logical left shift
b[4:0]                       // Shift amounts in RV32I span 5 bits (values 0 to 31)
```

---

## 8. Four Core ALU Status Flag Equations (ch03)

```verilog
wire [32:0] wide_sum = {1'b0, a} + {1'b0, b};

assign sum      = wide_sum[31:0];
assign carry    = wide_sum[32];                                           // Unsigned carry-out
assign zero     = ~|sum;                                                  // 32-bit zero check (Reduction NOR)
assign negative = sum[31];                                                // Most Significant Sign Bit
assign overflow = (a[31] == b[31]) && (sum[31] != a[31]);                 // Signed addition overflow
// Signed subtraction overflow: (a[31] != b[31]) && (sum[31] != a[31])
```

---

## 9. Five-Point Combinational Design Checklist (ch04)

```verilog
always @* begin
  // 1. Pre-assign default values to all outputs
  out_a = 1'b0;
  out_b = 2'b00;

  // 2. Selectively assert control paths
  case (sel)
    2'b00: out_a = 1'b1;
    2'b01: out_b = 2'b11;
    default: ;
  endcase
end
```

1. Are all driven signals declared as `reg`?
2. Does the sensitivity list use `always @*`?
3. Are all procedural assignments using blocking operators (`=`)?
4. Are default values pre-assigned to all outputs at the head of the block?
5. Does every `case` statement include a `default` branch?

---

## 10. Six-Point Sequential Design Checklist (ch05)

```verilog
always @(posedge clk) begin
  if (reset)
    state <= 32'h0;
  else if (load)
    state <= load_val;
  else if (enable)
    state <= state + 32'd4;
  // State holds automatically if no condition asserts (standard flip-flop behavior)
end
```

1. Are all state variables declared as `reg`?
2. Does the sensitivity list specify `always @(posedge clk)`?
3. Are all state transitions driven using nonblocking assignments (`<=`)?
4. Is each state register assigned within exactly one `always` block?
5. Does the priority nesting match specifications (`reset > load > enable`)?
6. Is reset behavior synchronous across all sequential modules?

---

## 11. Module Hierarchy and Instantiation Rules (ch06)

```verilog
wire [4:0] carry_chain;                  // Declare intermediate wire nets with explicit widths

// Named port instantiation
full_adder u_bit0 (
  .a         (a[0]),
  .b         (b[0]),
  .carry_in  (carry_chain[0]),
  .sum       (sum[0]),
  .carry_out (carry_chain[1])
);

adder #(.WIDTH(32)) u_add32 (...);       // Parameter override

genvar i;
generate
  for (i = 0; i < WIDTH; i = i + 1) begin : stage
    full_adder u_fa (...);
  end
endgenerate
```

---

## 12. Standard Two-Block FSM Architecture (ch07)

```verilog
localparam [1:0] IDLE = 2'd0, RUN = 2'd1, DONE = 2'd2;
reg [1:0] state, next_state;

// Block 1: Sequential state transition (Synchronous Reset)
always @(posedge clk) begin
  if (reset) state <= IDLE;
  else       state <= next_state;
end

// Block 2: Combinational next-state and output logic
always @* begin
  next_state  = state;
  output_flag = 1'b0;
  case (state)
    IDLE: if (start) next_state = RUN;
    RUN:  if (done)  next_state = DONE;
    DONE: begin output_flag = 1'b1; next_state = IDLE; end
    default: next_state = IDLE;
  endcase
end
```

---

## 13. Self-Checking Testbench Template (ch08)

```verilog
module tb_target;
  reg         clk = 1'b0;                // Explicit initialization to 0
  reg  [31:0] in_data;
  wire [31:0] out_data;

  target dut (.a(in_data), .y(out_data));

  always #5 clk = ~clk;                  // 100MHz clock generation (10ns period)

  task check;
    input [31:0]     expected;
    input [8*32-1:0] label;
    begin
      if (out_data !== expected)
        $fatal(1, "FAIL [%0s] actual=%h (expected=%h)", label, out_data, expected);
    end
  endtask

  initial begin
    $timeformat(-9, 0, "ns", 6);
    $dumpfile("build/target.vcd");
    $dumpvars(0, tb_target);

    // Wait for rising edge plus 1ns hold delay before sampling
    @(posedge clk); #1;
    check(32'h0000_0000, "Reset check");

    $display("PASS tb_target");
    $finish(0);
  end

  initial begin                          // Hang prevention watchdog timer
    #100000;
    $fatal(1, "FAIL simulation timeout");
  end
endmodule
```

---

## 14. Common Compilation Errors and Fixes (ch01)

| Compiler Diagnostic | Root Cause and Resolution |
|---|---|
| `syntax error` | Missing semicolon, mismatched parenthesis/bracket, or omitted `begin-end` |
| `Unknown module type` | Typo in module name or missing source file in compilation command |
| `port ... is not a port of ...` | Typo in instantiation port name or outdated module interface |
| `expects N bit(s), given M` | Bit-width mismatch between port and connected net |
| `is not a valid l-value` | Missing `reg` declaration on variable assigned in procedural block |
| `dangling input port ... floating` | Unconnected input port on instantiated submodule |
| `also continuously assigned` | Multidriver net conflict (driven concurrently by multiple sources) |

---

## 15. Symptom-Based Debugging Guide

| Observed Symptom | Primary Inspection Points and Corrective Action |
|---|---|
| `x` state spreads across waveform | Check for unconnected inputs, omitted default assignments, or out-of-bounds array indices |
| Monitored data lags by 1 cycle | Check whether testbench sampled synchronously without post-edge `#1` delay |
| Carry-out truncates to 0 | Verify N+1 bit context expansion (`{1'b0, a}`) on addition operands |
| Negative arithmetic fails | Check for missing `$signed` casts on comparison or shift operands |
| Output latches under specific inputs | Check for missing `else` branches or omitted `default` in combinational blocks |
| Simulation hangs indefinitely | Inspect loop termination conditions and verify presence of watchdog timeout block |

---

## 16. Complete Chapter Directory

| Chapter | Topic Focus |
|---|---|
| [ch01](../ch01/README.md) | Icarus Verilog workflow, port declarations, continuous `assign`, error diagnostics |
| [ch02](../ch02/README.md) | Literals, 4-state logic (`x`, `z`), `wire` vs. `reg`, sign extension |
| [ch03](../ch03/README.md) | Five bit-width expansion rules, signed casting, shift variants, ALU flags |
| [ch04](../ch04/README.md) | `always @*`, default assignments, priority encoders, latch avoidance |
| [ch05](../ch05/README.md) | `always @(posedge clk)`, nonblocking assignments (`<=`), synchronous reset |
| [ch06](../ch06/README.md) | Named hierarchical instantiation, signal probing, `generate` loops |
| [ch07](../ch07/README.md) | 2D register arrays, combinational/synchronous read timing, 2-block FSM |
| [ch08](../ch08/README.md) | Self-checking testbenches, 6 boundary vectors, pseudo-random vectors, VCD/CSV |
| [ch09](../ch09/README.md) | Synthesizable RTL subsets, 27-point design self-check checklist |
| [ch10](../ch10/README.md) | Verilog-2001 vs. SystemVerilog 1:1 syntax mapping and interoperability |
