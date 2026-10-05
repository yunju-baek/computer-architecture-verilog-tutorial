# Chapter 01: Toolchain and First Module

## 1. Learning Objectives

Upon completing this chapter, you create Verilog source files, compile them with Icarus Verilog, and execute simulations. When compilation fails, you analyze compiler diagnostic messages to isolate the root cause.

Five core competencies:

1. Understand the execution flow between the `iverilog` compiler and `vvp` runtime engine.
2. Formulate `module` declarations and define port interfaces.
3. Express combinational logic using continuous `assign` statements.
4. Construct self-checking testbenches with golden value assertions.
5. Diagnose compilation errors and warning messages systematically.

---

## 2. Toolchain Verification and Setup

All hardware examples in this tutorial run on Icarus Verilog.

```bash
iverilog -V | head -1
vvp -V | head -1
```

A version banner confirms operational tools. This tutorial suite has been fully verified on Icarus Verilog 13.0.

Platform installation commands:

| Operating System | Installation Command |
|---|---|
| macOS (Homebrew) | `brew install icarus-verilog` |
| Ubuntu / WSL | `sudo apt install iverilog` |
| Windows | Install WSL and run the Ubuntu command |

---

## 3. Example 1-1: Minimal Runnable Module

Review [`ex01_hello.v`](ex01_hello.v):

```verilog
`timescale 1ns/1ps

module ex01_hello;

  initial begin
    $display("hello from verilog");
    $display("simulation time = %0t", $time);
    $finish(0);
  end

endmodule
```

Key language constructs:

1. `` `timescale 1ns/1ps ``: Defines time units. The first term (`1ns`) specifies unit delay (`#1 = 1ns`); the second term (`1ps`) defines internal simulator precision.
2. `module ex01_hello; ... endmodule`: Declares the primary structural unit. As a portless top-level test module, a semicolon directly follows the module name.
3. `initial begin ... end`: A procedural block executed once at simulation startup ($t=0$). Simulation-only construct; omit from synthesizable RTL.
4. `$display`: Prints formatted text to the standard console output.
5. `$finish(0)`: Terminates simulation. Argument `0` suppresses diagnostic runtime headers to keep logs concise.

### Compilation and Execution

```bash
iverilog -g2012 -Wall -s ex01_hello -o build/ex01.vvp ex01_hello.v
vvp build/ex01.vvp
```

Console output:

```text
hello from verilog
simulation time = 0
```

### Compiler Flag Analysis

| Flag | Role and Purpose |
|---|---|
| `iverilog` | Compiles Verilog source into an intermediate simulation binary |
| `-g2012` | Enables IEEE 1800-2012 language standard (supports SystemVerilog testbenches) |
| `-Wall` | Activates all compiler warnings (detects net width mismatches and subtle hazards) |
| `-s ex01_hello` | Designates the root module serving as the simulation entry point |
| `-o build/ex01.vvp` | Specifies output binary path |
| `ex01_hello.v` | Target source file list |
| `vvp` | Executes the compiled `.vvp` runtime simulation engine |

Assignment Makefiles utilize these identical compiler options.

---

## 4. Example 1-2: First Combinational Logic Module

[`ex02_inverter.v`](ex02_inverter.v) implements a 4-bit inverter:

```verilog
`timescale 1ns/1ps

module ex02_inverter(
  input  wire [3:0] a,   // 4-bit input port
  output wire [3:0] y    // 4-bit output port
);

  assign y = ~a;

endmodule
```

Port declarations explicitly specify direction (`input`, `output`), net type (`wire`), and bit width (`[3:0]`). The range `[3:0]` defines a 4-bit bus where bit 3 is the Most Significant Bit (MSB) and bit 0 is the Least Significant Bit (LSB).

The continuous assignment `assign` models physical wiring: any value transition on RHS operand `~a` immediately propagates to LHS net `y`.

### Self-Checking Testbench

[`tb_ex02.v`](tb_ex02.v) applies stimulus vectors and asserts outputs programmatically:

```verilog
module tb_ex02;

  reg  [3:0] a;     // Drives DUT input; declared as reg
  wire [3:0] y;     // Observes DUT output; declared as wire
  integer    i;

  ex02_inverter dut(.a(a), .y(y));

  initial begin
    for (i = 0; i < 16; i = i + 1) begin
      a = i[3:0];
      #1;
      if (y !== ~a)
        $fatal(1, "FAIL a=%b y=%b expected=%b", a, y, ~a);
    end
    $display("PASS ch01 ex02 inverter, 16 vectors");
    $finish(0);
  end

endmodule
```

Four fundamental verification rules:

1. Driving rules: Variables assigned in procedural blocks (`initial`, `always`) must be declared as `reg`. Nets driven by continuous `assign` or module outputs must be declared as `wire`.
2. Explicit named port instantiation: Instantiating with `.a(a), .y(y)` binds signals explicitly by name, catching interface mistakes at compile time.
3. Propagation delay (`#1`): Delay execution by 1ns after changing inputs to allow combinational outputs to settle.
4. Strict 4-state equality (`!==`) and failure exits (`$fatal`): Use `!==` to catch unexpected `x` or `z` states. Invoke `$fatal(1, ...)` to return exit code 1 on verification failure.

### Compilation and Execution

```bash
iverilog -g2012 -Wall -s tb_ex02 -o build/ex02.vvp ex02_inverter.v tb_ex02.v
vvp build/ex02.vvp
```

Console output:

```text
PASS ch01 ex02 inverter, 16 vectors
```

---

## 5. Example 1-3: Multi-Output Logic Gates

[`ex03_gates.v`](ex03_gates.v) generates four concurrent logical outputs:

```verilog
module ex03_gates(
  input  wire a,
  input  wire b,
  output wire y_and,
  output wire y_or,
  output wire y_xor,
  output wire y_nand
);

  assign y_and  = a & b;
  assign y_or   = a | b;
  assign y_xor  = a ^ b;
  assign y_nand = ~(a & b);

endmodule
```

Continuous `assign` statements model independent, concurrently operating circuits; text order does not affect hardware evaluation.

Execution of [`tb_ex03.v`](tb_ex03.v):

```bash
iverilog -g2012 -Wall -s tb_ex03 -o build/ex03.vvp ex03_gates.v tb_ex03.v
vvp build/ex03.vvp
```

```text
 a b | and or xor nand
-----+-------------------
 0 0 |  0   0   0    1
 0 1 |  0   1   1    1
 1 0 |  0   1   1    1
 1 1 |  1   1   0    0
PASS ch01 ex03 gates, 4 vectors
```

---

## 6. Example 1-4: `$display` Format Specifiers

[`ex04_display.v`](ex04_display.v) demonstrates formatting options for hardware debugging:

```bash
iverilog -g2012 -Wall -s ex04_display -o build/ex04.vvp ex04_display.v
vvp build/ex04.vvp
```

```text
binary       %b   = 10100011
hex          %h   = a3
decimal      %d   = 163
decimal trim %0d  = 163
octal        %o   = 243
signed       %0d  = -93
32bit hex    %h   = deadbeef
width 8      %8b  =     0011
string       %s   = opcode
time         %0t  = 0
```

Format specifier reference:

| Specifier | Format and Application |
|---|---|
| `%b` | Binary bit pattern |
| `%h` | Hexadecimal (standard for 32-bit instructions and addresses) |
| `%d` | Decimal padded to declared bit width |
| `%0d`, `%0h`, `%0b` | Decimal/Hex/Binary without leading space padding |
| `%s` | String literal |
| `%0t` | Current simulation timestamp |

Interpreting `8'b1010_0011` with `$signed` yields `-93`, while unsigned interpretation yields `163`. Evaluating dual interpretations on identical bit patterns forms the basis of HW02.

---

## 7. Diagnostic Training: Compiler Errors and Warnings

Run `make errors` to inspect compiler diagnostics across two intentional failure cases:

```bash
make errors
```

### Defect 1: Syntax Error (`syntax error`)

[`bad01_missing_semicolon.v`](bad01_missing_semicolon.v) omits a semicolon on line 10:

```text
bad01_missing_semicolon.v:12: syntax error
I give up.
```

The parser searches ahead for statement terminators, frequently flagging the subsequent line (line 12) rather than the omitted semicolon on line 10. When encountering `syntax error`, inspect preceding lines for missing semicolons, unmatched parentheses, or missing `begin`/`end` delimiters.

### Defect 2: Port Width Mismatch (`width mismatch`)

[`bad02_port_width.v`](bad02_port_width.v) connects an 8-bit signal to a 4-bit port:

```text
bad02_port_width.v:17: warning: Port 1 (a) of module narrow expects 4 bit(s), given 8.
bad02_port_width.v:17:        : Pruning 4 high bits of the expression.
bad02_port_width.v:17: warning: Port 2 (y) of module narrow expects 4 bit(s), given 8.
bad02_port_width.v:17:        : Padding 4 high bits of the expression.
wide_in=ab wide_out=04
```

Compilation and simulation complete, but upper bits are silently discarded (`Pruning`) and padded (`Padding`), altering arithmetic results. Maintain `-Wall` in compilation flags to detect and resolve bit-width mismatches.

### Diagnostic Message Mapping

| Diagnostic Message | Root Cause Inspection Points |
|---|---|
| `syntax error` | Semicolons, parentheses, brackets, or `begin`/`end` pairs on and preceding the indicated line |
| `Unknown module type` | Module name typo or missing source file in compilation command |
| `port ... is not a port of ...` | Typo in instantiated port name or mismatched module interface |
| `expects N bit(s), given M` | Bit-width mismatch between port and connected net |
| `... is not a valid l-value` | Missing `reg` declaration on variable driven inside a procedural block |
| `Cannot find the root module` | Typo in module name supplied to `-s` flag |

---

## 8. Complete Chapter Verification

```bash
make test
```

```text
=== ch01 ex01 hello ===
hello from verilog
simulation time = 0
=== ch01 ex02 inverter ===
PASS ch01 ex02 inverter, 16 vectors
=== ch01 ex03 gates ===
 a b | and or xor nand
-----+-------------------
 0 0 |  0   0   0    1
 0 1 |  0   1   1    1
 1 0 |  0   1   1    1
 1 1 |  1   1   0    0
PASS ch01 ex03 gates, 4 vectors
=== ch01 ex04 display ===
binary       %b   = 10100011
...
PASS ch01
```

---

## 9. Hands-On Exercises

1. Extend `ex02_inverter.v` to an 8-bit bus `[7:0]` and update `tb_ex02.v` to iterate over 256 vectors.
2. Add a `y_nor` output to `ex03_gates.v`, updating the port list, instance binding, and testbench assertion.
3. Intentionally alter the expected output in `tb_ex03.v` to observe `$fatal` triggering non-zero exit status 1.
4. Redefine output `y` in `ex02_inverter.v` as `reg [3:0] y` and observe the compiler diagnostic when driven by `assign`.
5. Remove the `#1` delay from `tb_ex02.v` and observe how zero-delay race conditions produce assertion failures.

---

## 10. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| `-g2012 -Wall -s` compiler options | Build infrastructure across HW02 through HW04 |
| Port declarations and bus widths | 32-bit port interface in HW02 `rtl/alu.v` |
| Continuous `assign` statements | Asynchronous read ports in HW02 `rtl/regfile.v` |
| Explicit named port mapping | Core datapath integration in HW03 `rtl/rv32i_core.v` |
| `!==` and `$fatal` assertions | Public and student test suites across all projects |

---

## 11. Concept Check Questions

1. What role does the module specified by `iverilog`'s `-s` flag play in simulation?
2. Why does the textual order of continuous `assign` statements have no effect on hardware execution?
3. What driving rule requires declaring testbench inputs as `reg` and outputs as `wire`?
4. How does the exit code returned by `$fatal(1)` interact with GNU Make?
5. What hardware bugs arise when ignoring compiler bit-width truncation warnings?

---

Next Chapter: [Chapter 02: Syntax and Data Types](../ch02/README.md)
