# Chapter 08: Testbench Methodologies

## 1. Learning Objectives

This chapter establishes standard architectures for self-checking testbenches that automate hardware verification and pinpoint design defects. Across assignments HW02 through HW05, passing public testbenches and constructing comprehensive student test suites represent key grading criteria.

**The Testbench Design Invariant**: Every verification scenario must replace manual `$display` inspections with automated programmatic comparisons and `$fatal` assertions, returning deterministic PASS/FAIL exit codes.

Six core competencies:

1. Construct the 7-part standard self-checking testbench framework.
2. Select between fail-fast and error-counting verification strategies.
3. Formulate the six essential boundary vector categories for 32-bit architectures.
4. Implement pseudo-random testing with reference models and fixed seeds.
5. Generate VCD waveforms and CSV execution traces.
6. Eliminate sampling race conditions and implement watchdog timeouts.

---

## 2. Seven-Part Standard Testbench Architecture

[`tb_ex01.v`](tb_ex01.v) validates a 16-bit accumulator (`ex01_dut.v`) using the 7-part architecture:

```verilog
`timescale 1ns / 1ps

module tb_ex01;

  // 1. Net declarations: DUT inputs as reg, DUT outputs as wire
  reg         clk = 1'b0;      // Initialize explicitly to 0 to prevent latchup in unknown (x)
  reg         reset;
  reg         enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;

  // 2. Timing constants: 5ns half-period (100MHz clock)
  localparam CLOCK_HALF = 5;

  // 3. DUT instantiation: Named port binding
  ex01_dut dut (
    .clk    (clk),
    .reset  (reset),
    .enable (enable),
    .addend (addend),
    .total  (total),
    .zero   (zero),
    .carry  (carry)
  );

  // 4. Free-running clock generator
  always #CLOCK_HALF clk = ~clk;

  // 5. Verification tasks: Wait for @(posedge clk) followed by #1 hold delay
  task apply_reset;
    begin
      reset  = 1'b1;
      enable = 1'b0;
      addend = 16'h0000;
      @(posedge clk);
      #1;
      reset = 1'b0;
    end
  endtask

  task check_total;
    input [15:0]     expected;
    input [8*32-1:0] label;
    begin
      if (total !== expected)
        $fatal(1, "FAIL [%0s] total=%h (expected=%h)", label, total, expected);
    end
  endtask

  // 6. Primary test sequence
  initial begin
    $timeformat(-9, 0, "ns", 6);

    apply_reset;
    check_total(16'h0000, "post-reset");

    // Execute test cases...

    $display("PASS ch08 ex01 skeleton");
    $finish(0);
  end

  // 7. Watchdog timeout to prevent infinite hangs
  initial begin
    #10000;
    $fatal(1, "FAIL simulation timeout");
  end

endmodule
```

### Seven Core Framework Components

1. Net declarations: Inputs driven from procedural blocks must be declared as `reg` and initialized with `clk = 1'b0`.
2. Timing constants: Centralize clock periods in constants (`CLOCK_HALF`) to simplify frequency scaling.
3. Named port binding: Use `.port(signal)` mapping to eliminate connection order errors.
4. Clock generator: Generate symmetric square waves with `always #CLOCK_HALF clk = ~clk;`.
5. Modular `task` routines: Encapsulate multi-cycle stimulus sequences with timing controls (`#`, `@`) inside reusable `task` blocks.
6. Self-checking test sequence: Assert outputs against golden values and terminate cleanly with a `PASS` banner.
7. Watchdog timer: Abort stalled simulations automatically when circuits enter infinite loops or deadlocks.

---

## 3. Two Failure-Handling Strategies: Fail-Fast versus Error-Counting

[`tb_ex02.v`](tb_ex02.v) provides both failure handling modes:

### Strategy 1: Fail-Fast

Halts simulation immediately via `$fatal` upon the first detected mismatch. Best suited for interactive debugging when isolating the root cause via waveform analysis.

### Strategy 2: Error-Counting

Logs all mismatches to an error accumulator, executes the complete regression suite, and outputs an aggregate failure report:

```verilog
$display("Verification completed: %0d checks, %0d failures", check_count, error_count);
if (error_count != 0)
  $fatal(1, "FAIL %0d total errors encountered", error_count);
```

---

## 4. Six Essential 32-Bit Boundary Value Categories

Validating 32-bit arithmetic circuits (such as the HW02 ALU) requires testing the following six boundary conditions:

| Boundary Category | Representative Hex Patterns | Targeted Hardware Faults |
|---|---|---|
| Extremes | `32'h0000_0000`, `32'hffff_ffff` | Zero handling, all-ones propagation |
| Near-Extremes | `32'h0000_0001`, `32'hffff_fffe` | Off-by-one errors in `<` vs. `<=` comparisons |
| Sign-Change Boundaries | `32'h7fff_ffff`, `32'h8000_0000` | Two's complement overflow and signed comparisons |
| Byte / Halfword Edges | `32'h0000_ffff`, `32'hffff_0000` | Immediate sign extension and alignment errors |
| Alternating Bit Patterns | `32'h5555_5555`, `32'haaaa_aaaa` | Adjacent wire bridging and cross-talk faults |
| Carry-Generating Combinations | `32'hffff_ffff` + `32'h0000_0001` | Carry-chain propagation and MSB carry-out |

---

## 5. Reference Models and Pseudo-Random Testing

[`tb_ex04.v`](tb_ex04.v) pairs a behavioral software reference model with a seeded pseudo-random generator to execute hundreds of randomized trials:

```verilog
integer seed = 32'd20260825;    // Fixed seed ensures repeatable sequences
...
addend = $random(seed);

// Compute behavioral reference values
reference_wide  = {1'b0, reference_total} + {1'b0, addend};
reference_total = reference_wide[15:0];
reference_carry = reference_wide[16];

// Assert RTL outputs against reference model
if (total !== reference_total || carry !== reference_carry)
  $fatal(1, "FAIL random check mismatch");
```

---

## 6. VCD Waveform Generation and CSV Trace Logging

[`tb_ex05.v`](tb_ex05.v) generates artifacts for waveform inspection and automated grading:

```verilog
// 1. Configure VCD waveform logging
$dumpfile("build/ex05.vcd");
$dumpvars(0, tb_ex05);

// 2. Open CSV execution trace file
trace_file = $fopen("build/trace.csv", "w");
if (trace_file == 0) $fatal(1, "FAIL cannot open CSV trace file");
$fwrite(trace_file, "cycle,time_ns,enable,addend,total,zero,carry\n");

// Log committed state on every clock cycle
$fwrite(trace_file, "%0d,%0d,%b,%h,%h,%b,%b\n",
        cycle, $time, enable, addend, total, zero, carry);

$fclose(trace_file);
```

---

## 7. Diagnostic Analysis: Three Testbench Pitfalls

Execute `make errors` to inspect compiler diagnostics across three intentional defects:

```bash
make errors
```

### Pitfall 1: Missing Post-Edge Sampling Delay (`bad01_no_delay.v`)

Sampling immediately after `@(posedge clk);` without delay reads pre-transition values before nonblocking assignments commit, skewing checks by 1 cycle. Always insert a `#1;` hold delay after the clock edge before evaluating assertions.

### Pitfall 2: Display-Only Verification Without Assertions (`bad02_display_only.v`)

Printing values with `$display` without programmatic comparison allows hardware defects to slip through undetected while the testbench returns zero exit status.

### Pitfall 3: Unseeded Random Sequences (`bad03_random_seed.v`)

Omitting a fixed seed makes pseudo-random tests non-reproducible, preventing deterministic root-cause analysis when failures occur.

---

## 8. Ten-Point Testbench Design Checklist

1. Are DUT inputs declared as `reg` and outputs as `wire`?
2. Is the clock signal explicitly initialized to `1'b0`?
3. Is sampling delayed by `#1;` immediately following `@(posedge clk)`?
4. Are all outputs verified against expected values using `!==`?
5. Do failure messages print both expected and actual values?
6. Does the test suite cover both 6 boundary categories and random vectors?
7. Is a fixed integer seed passed to `$random`?
8. Does the testbench summarize total executed checks and failure counts?
9. Is a watchdog timer present to catch deadlocks?
10. Does successful execution terminate with an explicit `PASS` banner and `$finish(0)`?

---

## 9. Complete Chapter Verification

```bash
make test      # Verify functional testbench examples
make errors    # Inspect intentional defect diagnostics
make waves     # Open generated VCD waveforms
make clean
```

---

## 10. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| 7-part testbench architecture | Student-authored testbenches in HW02 through HW05 |
| 6-part boundary table | ALU flag validation in HW02 |
| Seeded random verification | Register file read/write validation in HW03 |
| CSV trace logging | `commit_trace.csv` in HW04 and `cpi_audit.csv` in HW05 |
| Watchdog timeout safety | Execution safeguards across HW04 and HW05 test programs |

---

## 11. Concept Check Questions

1. Why must the testbench clock signal initialize explicitly with `reg clk = 1'b0;`?
2. What distinction separates `task` from `function` regarding delay controls (`#`, `@`)?
3. What hardware timing principle requires a `#1` delay after `@(posedge clk)` before sampling register outputs?
4. Explain the six boundary categories required for thorough 32-bit datapath verification.
5. What verification benefit arises from passing a fixed seed to `$random`?

---

Previous Chapter: [Chapter 07: Memory and FSM](../ch07/README.md) | Next Chapter: [Chapter 09: Synthesizable RTL Coding](../ch09/README.md)
