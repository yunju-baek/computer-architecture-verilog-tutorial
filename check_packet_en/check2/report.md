# Verilog Check 2 Report

- Student ID & Name: [Fill in]
- Submission Date: [Fill in]

Limit report body to approximately 1 page. Detailed execution logs and source code reside in `evidence/`, `predictions.vh`, and `tb_boundary.v`; focus the report body on analytical explanations and observed data.

## 1. Predictions and Simulation Analysis

Document 2 items where manual predictions initially differed from simulation outputs. If all initial predictions matched, document the 2 most complex signals alongside complete derivation rationales.

- Item 1 (Signal name, initial predicted value, actual simulation output, code-level rationale): [Fill in]
- Item 2 (Signal name, initial predicted value, actual simulation output, code-level rationale): [Fill in]

## 2. Verification Scope Evaluation

- Placement of `reset_dut` inside the `for` loop and initial DUT state at vector application: [Fill in]
- Core DUT hardware behavior directly verified by this testbench: [Fill in]
- Verification limitation (untested boundary condition) of this testbench: [Fill in]
- Bit-level conditions tested by the 2 added boundary values: [Fill in]

## 3. Subsequent Experiment Design (Design Specification)

- Two consecutive input vectors proposed to observe carry propagation across repeated additions: [Fill in]
- Expected values for `total` / `zero` / `carry` after first accumulation: [Fill in]
- Expected values for `total` / `zero` / `carry` after second accumulation: [Fill in]

## 4. Chapter Key Takeaways

- CH06 (Structural hierarchy, named port mapping, and `generate` loop instantiation): [Fill in]
- CH07 (Synchronous memory read timing and 2-always-block FSM design): [Fill in]
- CH08 (Self-checking testbenches, output sampling timing, and boundary stimulus design): [Fill in]
- CH09 (Synthesizable RTL constructs vs. simulation-only constructs): [Fill in]
- CH10 (Verilog-2001 standards vs. modern SystemVerilog syntax improvements): [Fill in]

## 5. Technical Inquiries

- One technical inquiry for discussion in subsequent sessions (Optional): [Fill in]
