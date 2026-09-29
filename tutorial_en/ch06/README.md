# Chapter 06: Hierarchy and Parameterization

## 1. Learning Objectives

This chapter establishes modular design techniques for combining multiple submodules into a complete processor core. In HW04, you assemble the five unit modules developed in HW03 into the top-level single-cycle core (`rv32i_core.v`) following the instantiation protocols presented here.

**The Hierarchical Design Invariant**: All module instantiations must use explicit named port mapping (`.port_name(signal_name)`), and all internal interconnecting nets (`wire`) must be explicitly declared with exact bit widths.

Six core competencies:

1. Construct modular hierarchies and declare intermediate interconnect buses (`wire`).
2. Probe internal submodule signals in testbenches using hierarchical dot notation (`.`).
3. Contrast the reliability of named port mapping versus positional mapping.
4. Generate regular, parameterized hardware structures using `generate for` loops.
5. Implement compile-time architectural selection using `generate if`.
6. Prevent floating input ports and parameter omission defects.

---

## 2. Module Hierarchy and Interconnect Nets

[`ex01_hierarchy.v`](ex01_hierarchy.v) constructs a 3-level hierarchy: four 1-bit full adders assemble into a 4-bit adder (`adder4`), and two 4-bit adders assemble into an 8-bit adder.

```verilog
module adder4(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       carry_in,
  output wire [3:0] sum,
  output wire       carry_out
);

  // Internal carry chain declared as an explicit wire vector
  wire [4:0] carry_chain;

  assign carry_chain[0] = carry_in;
  assign carry_out      = carry_chain[4];

  // Named port instantiation for four 1-bit full adders
  full_adder u_bit0 (.a(a[0]), .b(b[0]), .carry_in(carry_chain[0]), .sum(sum[0]), .carry_out(carry_chain[1]));
  full_adder u_bit1 (.a(a[1]), .b(b[1]), .carry_in(carry_chain[1]), .sum(sum[1]), .carry_out(carry_chain[2]));
  full_adder u_bit2 (.a(a[2]), .b(b[2]), .carry_in(carry_chain[2]), .sum(sum[2]), .carry_out(carry_chain[3]));
  full_adder u_bit3 (.a(a[3]), .b(b[3]), .carry_in(carry_chain[3]), .sum(sum[3]), .carry_out(carry_chain[4]));

endmodule
```

### Three Hierarchical Naming Rules

1. Instance naming prefix: Prefix all submodule instance names with `u_` (`u_bit0`, `u_alu`, `u_regfile`) to distinguish instances from net signals.
2. Standard DUT identifier: Name the top-level Device Under Test inside testbenches `dut`.
3. Explicit interconnect declarations: Declare all internal buses exchanging data between submodules as `wire` nets with explicit widths at the top of the enclosing module.

---

## 3. Hierarchical Probing for Testbench Debugging

In simulation, testbenches probe internal registers and carry signals across hierarchy boundaries using the dot operator (`.`):

```verilog
$display("dut.middle_carry           = %b", dut.middle_carry);
$display("dut.u_low.carry_chain      = %b", dut.u_low.carry_chain);
$display("dut.u_low.u_bit3.carry_out = %b", dut.u_low.u_bit3.carry_out);
```

Simulation output:

```text
--- Reading internal signals via hierarchical paths ---
a=0f b=01 -> sum=10 carry=0
dut.middle_carry            = 1
dut.u_low.carry_chain       = 11110
dut.u_low.u_bit3.carry_out  = 1
PASS ch06 ex01 hierarchy, 65536 vectors
```

Hierarchical probing is strictly confined to testbenches. Synthesizable RTL modules must interact exclusively through declared input and output port interfaces.

---

## 4. Named Port Mapping Standard

[`ex02_connection.v`](ex02_connection.v) contrasts named port mapping with positional mapping.

Named port mapping (`.port(signal)`) binds module interface ports directly to external nets by name:

1. Port-order independence: Reordering port lines does not affect circuit wiring.
2. Refactoring resilience: Modifying submodule port lists or inserting new ports does not break existing connections.
3. Code readability: Visual inspections immediately clarify which net feeds which functional terminal.

---

## 5. Parameterized Instantiation with `generate for`

[`ex03_generate.v`](ex03_generate.v) unrolls an N-bit ripple-carry adder at compile time:

```verilog
module ex03_generate #(
  parameter WIDTH = 8
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  input  wire             carry_in,
  output wire [WIDTH-1:0] sum,
  output wire             carry_out
);

  wire [WIDTH:0] carry_chain;
  assign carry_chain[0]     = carry_in;
  assign carry_out          = carry_chain[WIDTH];

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : adder_stage
      full_adder u_fa(
        .a         (a[i]),
        .b         (b[i]),
        .carry_in  (carry_chain[i]),
        .sum       (sum[i]),
        .carry_out (carry_chain[i+1])
      );
    end
  endgenerate

endmodule
```

Guidelines for `generate for`:

1. `genvar` loop index: Declare the iteration variable as a `genvar` to indicate compile-time elaboration.
2. Named block labels (`: adder_stage`): Label the `begin` statement to establish stable hierarchical paths (`dut.adder_stage[0].u_fa`) for simulation and synthesis tools.
3. Parameter-bounded loops: Express loop limits using module parameters.

---

## 6. Conditional Synthesis with `generate if`

[`ex04_generate_if.v`](ex04_generate_if.v) selects between architectural implementations based on parameter configuration:

```verilog
generate
  if (USE_BARREL) begin : barrel
    assign result = value << amount;
  end else begin : staged
    wire [7:0] stage1 = amount[0] ? {value[6:0],  1'b0} : value;
    wire [7:0] stage2 = amount[1] ? {stage1[5:0], 2'b0} : stage1;
    assign result     = amount[2] ? {stage2[3:0], 4'b0} : stage2;
  end
endgenerate
```

`generate if` evaluates conditions at elaboration time, synthesizing only the matching hardware block and discarding unselected branches from the gate netlist.

---

## 7. Diagnostic Analysis: Three Hierarchical Defects

Execute `make errors` to inspect compiler diagnostics across three intentional defects:

```bash
make errors
```

### Defect 1: Positional Port Swapping (`bad01_positional.v`)

Swapping the order of two equal-width arguments in positional instantiations compiles cleanly without warnings, introducing inverted arithmetic (e.g., evaluating $30 - 100$ instead of $100 - 30$).

### Defect 2: Unconnected Input Ports (`bad02_unconnected.v`)

Omitting an input port leaves the net floating at high-impedance (`z`), poisoning downstream logic into an unknown `x` state. Compiler warnings (`dangling input port ... floating`) signal unconnected inputs.

### Defect 3: Parameter Override Omission (`bad03_param.v`)

Omitting parameter overrides synthesizes submodules with default bit widths, truncating upper bits. Explicitly declare parameters during instantiation.

---

## 8. Five-Step Top-Level Core Integration Procedure

1. Verify submodules: Prepare unit modules that have passed isolated testbenches in HW03.
2. Declare interconnect nets: Declare internal data buses and control lines with explicit bit widths at the top of the core.
3. Instantiate via named mapping: Bind all submodules using `.port(signal)` mapping, resolving all compiler warnings.
4. Execute integrated testbench: Apply instruction sequences to verify end-to-end datapath execution.
5. Probe hierarchical nets: When failures occur, trace intermediate signals using dot notation to isolate faulty submodules.

---

## 9. Complete Chapter Verification

```bash
make test      # Verify functional hierarchical examples
make errors    # Inspect intentional defect diagnostics
make clean
```

---

## 10. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| Named port module instantiation | Single-cycle datapath assembly in HW04 `rtl/rv32i_core.v` |
| Interconnect bus vectorization | Wiring `alu_src1`, `alu_src2`, and `imm_ext` in HW04 |
| Hierarchical signal probing | Isolating pipeline hazard bugs in HW04 and HW05 |
| Parameterized module construction | Scalable pipeline register widths in HW05 |

---

## 11. Concept Check Questions

1. Why does named port mapping provide superior reliability over positional mapping in complex hardware modules?
2. What fundamental distinction separates a `genvar` loop variable from a standard `integer` variable?
3. What simulation behavior occurs when an input port remains unconnected (floating)?
4. How does a compile-time `generate if` differ from a run-time combinational `if-else` block?
5. List the five steps of the recommended top-level module integration workflow.

---

Previous Chapter: [Chapter 05: Sequential Circuit Design](../ch05/README.md) | Next Chapter: [Chapter 07: Memory and FSM](../ch07/README.md)
