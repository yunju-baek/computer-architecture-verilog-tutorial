# Chapter 02: Syntax and Data Types

## 1. Learning Objectives

Upon completing this chapter, you understand the core Verilog data types, literal formats, and bit-level manipulation operators. The concepts presented here apply directly across assignments HW02 through HW05. In particular, the bit-slicing and sign-extension techniques in Sections 6 and 7 provide the foundational implementation knowledge for the HW03 Immediate Generator (ImmGen).

Seven core competencies:

1. Format numeric literals with explicit bit widths.
2. Navigate Verilog 4-state logic (`0`, `1`, `x`, `z`).
3. Apply structural driving rules for `wire` and `reg` data types.
4. Extract vector slices using three indexing methods (Bit, Part, Indexed Part Select).
5. Assemble sign-extended immediates via concatenation (`{}`) and replication (`{N{}}`).
6. Parameterize reusable hardware modules using `parameter` and `localparam`.
7. Diagnose and avoid the four most common RTL coding pitfalls.

---

## 2. Lexical Conventions and Grammar Rules

Standard hardware description guidelines:

1. Identifier naming: Identifiers begin with an alphabetic letter or underscore (`_`) and remain strictly case-sensitive; `data` and `Data` represent two distinct physical wires.
2. Comments: Single-line comments use `//`; block comments use `/* ... */`.
3. Semicolon termination: All port declarations and continuous assignments terminate with a semicolon (`;`). Structural headers (`begin`, `end`, `endmodule`, `always @*`) omit trailing semicolons.
4. Lowercase reserved keywords: Core language keywords (`input`, `output`, `wire`, `reg`, `assign`, `always`, `module`) must be written in lowercase.
5. System tasks and functions: Built-in simulator routines (`$display`, `$fatal`, `$signed`, `$time`) begin with a `$` prefix.

---

## 3. Numeric Literal System

Review numeric representations across bases in [`ex01_numbers.v`](ex01_numbers.v):

```bash
make test
```

```text
--- 같은 값을 4가지 진법으로 적는다 ---
8'b1010_0011 -> 10100011 = a3 = 163
8'o243       -> 10100011 = a3 = 163
8'd163       -> 10100011 = a3 = 163
8'ha3        -> 10100011 = a3 = 163
--- underscore는 자리를 끊어 읽는 표기다 ---
32'hdead_beef -> deadbeef
32비트 2진 -> f0f0f0f0
--- 폭과 진법을 생략하면 기본값이 적용된다 ---
'h1f  -> 0000001f  폭 생략은 32비트로 처리된다
17    -> 00000011  진법 생략은 10진수로 처리된다
--- 폭보다 값이 작으면 상위 비트가 0으로 채워진다 ---
8'h5  -> 00000101
--- 모든 비트를 같은 값으로 채운다 ---
{8{1'b1}} -> 11111111 = ff
8'hff     -> 11111111 = ff
```

### Literal Syntax Format

```text
<width>'<base><value>
   8   '   h     a3
```

| Base Format | Number System | Example |
|---|---|---|
| `'b` | Binary | `4'b1010` |
| `'o` | Octal | `8'o243` |
| `'d` | Decimal | `8'd163` |
| `'h` | Hexadecimal | `32'hdead_beef` |

Underscores (`_`) improve visual readability across byte boundaries and do not affect numerical value.

### Mandatory Sizing Principle

Unsized numeric literals default to 32-bit integers, frequently causing unintended bit-width expansion in surrounding expressions. Explicitly declare bit widths for all hardware constants: `1'b0`, `1'b1`, `32'h0000_0000`.

---

## 4. 4-State Logic System (`0`, `1`, `x`, `z`)

Verilog models physical digital logic states using four distinct values:

| Logic State | Physical Definition | Common Causes in Simulation |
|---|---|---|
| `0` | Logic zero (Low / Ground) | Actively driven low |
| `1` | Logic one (High / VDD) | Actively driven high |
| `x` | Unknown / Conflict | Uninitialized `reg`, omitted conditional branch, multidriver contention |
| `z` | High Impedance (Floating) | Undriven `wire`, tri-state buffer in high-impedance mode |

Review [`ex02_xz.v`](ex02_xz.v):

```text
--- 선언만 한 reg는 x로 시작한다 ---
uninitialized = xxxx
--- 구동원이 열린 wire는 z가 된다 ---
floating      = zzzz
--- x가 섞인 연산은 결과에도 x가 번진다 ---
4'b10xz       = 10xz
4'b10xz + 1   = xxxx
4'b10xz & 0   = 0000
--- == 와 === 의 차이 ---
a=1x01 b=1x01
a == b  -> x  x가 있으면 결과가 x가 된다
a === b -> 1  x 자리까지 같으면 1이 된다
a != b  -> x
a !== b -> 0
```

### `x` Propagation and 4-State Equality Operators

In arithmetic operations (`+`), an `x` or `z` bit on any operand propagates through the carry chain, rendering upper result bits unknown (`x`).

Standard equality operators (`==`, `!=`) return `x` (treated as false in conditional branches) if either operand contains `x` or `z`. Self-checking testbenches require 4-state equality operators (`===`, `!==`) to test exact bitwise identity, including `x` and `z` states.

---

## 5. Hardware Driving Rules: `wire` versus `reg`

| Driving Mechanism | Required Data Type | Synthesized Structure |
|---|---|---|
| Continuous assignment `assign` | `wire` | Combinational interconnect |
| Connection to sub-module output port | `wire` | Inter-module wiring net |
| Procedural assignment in `always @*` | `reg` | Combinational functional unit |
| Procedural assignment in `always @(posedge clk)` | `reg` | Clock-synchronized flip-flop |
| Testbench stimulus generation in `initial` | `reg` | Simulation driver |

[`ex03_wire_reg.v`](ex03_wire_reg.v) contrasts two implementation styles for a 2:1 multiplexer:

```verilog
// Style 1: Continuous assign driving a wire output
module mux_with_assign(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       sel,
  output wire [3:0] y
);
  assign y = sel ? b : a;
endmodule

// Style 2: Procedural block driving a reg output
module mux_with_always(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       sel,
  output reg  [3:0] y
);
  always @* begin
    y = a;            // Pre-assigned default value
    if (sel)
      y = b;          // Selective override
  end
endmodule
```

Implement simple routing using continuous `assign`; implement multi-way decoders and ALUs using procedural `always @*` blocks with `case` statements.

---

## 6. Vector Bit-Slicing Techniques

[`ex04_select.v`](ex04_select.v) disassembles a 32-bit RV32I instruction into its architectural bit fields:

```verilog
module ex04_select(
  input  wire [31:0] instr,
  output wire [6:0]  opcode,
  output wire [4:0]  rd,
  output wire [2:0]  funct3,
  output wire [4:0]  rs1,
  output wire [4:0]  rs2,
  output wire [6:0]  funct7,
  output wire        sign_bit
);

  assign opcode   = instr[6:0];      // Part Select
  assign rd       = instr[11:7];
  assign funct3   = instr[14:12];
  assign rs1      = instr[19:15];
  assign rs2      = instr[24:20];
  assign funct7   = instr[31:25];
  assign sign_bit = instr[31];       // Bit Select

endmodule
```

Bit-slicing taxonomy:

| Method | Syntax | Width Property | Typical Application |
|---|---|---|---|
| Bit Select | `instr[31]` | 1 bit | Extracting sign bits and valid flags |
| Part Select | `instr[19:15]` | Constant bit range | Extracting instruction fields (`opcode`, `rd`, `rs1`) |
| Indexed Part Select | `data[base +: 8]` | Fixed width (8 bits), variable offset | Byte selection in memory interfaces and cache indexing |

In `data[base +: 8]`, the operator `+:` specifies an 8-bit slice ascending from dynamic starting index `base`.

---

## 7. Concatenation and Sign Extension

[`ex05_concat.v`](ex05_concat.v) demonstrates the sign-extension mechanism required by the Immediate Generator.

### Concatenation and Replication

- Concatenation `{A, B}`: Joins signals A and B into a unified wider vector.
- Replication `{N{Bit}}`: Replicates the target bit or vector N times consecutively.

### 32-Bit Sign Extension

Reconstruct a 12-bit signed I-Type immediate (`instr[31:20]`) into a 32-bit word:

```verilog
assign imm_i = { {20{instr[31]}}, instr[31:20] };   // 20-bit sign replication + 12-bit raw immediate
```

The outer braces perform concatenation; the inner braces perform replication. If MSB sign bit `instr[31]` is `1`, the upper 20 bits fill with `1`, preserving two's complement negative value.

Empirical verification:

```text
--- Positive immediate ---
instr[31:20] = 005
imm_i        = 00000005 (5)
--- Negative immediate ---
instr[31:20] = fff
imm_i        = ffffffff (-1)    // Sign-extended: upper 20 bits replicated from MSB (1)
zero_ext_i   = 00000fff (4095)  // Zero-extended: upper 20 bits forced to 0
```

### Carry Preservation Idiom

To extract carry-out from 4-bit addition, capture the operation in a 5-bit context:

```verilog
wire [4:0] sum_with_carry;
assign sum_with_carry = op_a + op_b;
assign carry = sum_with_carry[4];
assign sum   = sum_with_carry[3:0];
```

---

## 8. Module Parameterization: `parameter` and `localparam`

[`ex06_param.v`](ex06_param.v) implements a parameterized N-bit adder:

```verilog
module ex06_adder #(
  parameter WIDTH = 8
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  output wire [WIDTH-1:0] sum,
  output wire             carry
);

  localparam RESULT_WIDTH = WIDTH + 1;
  wire [RESULT_WIDTH-1:0] wide_sum;

  assign wide_sum = a + b;
  assign sum      = wide_sum[WIDTH-1:0];
  assign carry    = wide_sum[WIDTH];

endmodule
```

Parameter classification:

| Keyword | External Override | Application |
|---|---|---|
| `parameter` | Configurable during instantiation: `#(.WIDTH(32))` | Bus widths, memory depths, port scaling |
| `localparam` | Fixed module-internal constant | Internal derived widths, FSM state constants |

---

## 9. Four RTL Pitfalls and Diagnostic Countermeasures

| Pitfall | Symptom & Latent Bug | Corrective Action |
|---|---|---|
| Driving `reg` with continuous `assign` | Silent pass in SystemVerilog; fails in strict Verilog-2001 | Declare nets driven by continuous assign as `wire` |
| Undeclared intermediate net | Implicitly declared as 1-bit `wire`, silently truncating upper bits | Explicitly declare all intermediate nets with widths |
| Literal bit-width truncation | Upper bits discarded, corrupting arithmetic values | Match literal widths exactly to destination net sizes |
| Multidriver contention (`double driver`) | Multiple active drivers force net into `x` state | Enforce a single physical driver per net |

---

## 10. Complete Chapter Verification

```bash
make test      # Run valid circuit examples
make errors    # Inspect intentional diagnostic failure examples
make clean
```

---

## 11. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| 32-bit hexadecimal literals | Pre-assigning default outputs in HW02 `rtl/rv32_alu.v` |
| `!==` and `$fatal` assertions | Custom student testbenches across all assignments |
| Part-Select bit extraction | Instruction field decoding in HW03 `rtl/rv32i_decode.v` |
| Sign-extension replication | Immediate assembly in HW03 `rtl/rv32i_immgen.v` |
| Width expansion for carry-out | Carry flag generation in the HW02 ALU |
| Indexed Part Select (`+:`) | Byte extraction in memory sub-systems |

---

## 12. Concept Check Questions

1. Contrast the bit-width handling between `8'h5` and unsized `'h5`.
2. What initial simulation values are held by an uninitialized `reg` and an undriven `wire`?
3. Why do self-checking testbenches require 4-state equality `===` instead of standard `==`?
4. What data type must be declared for variables assigned inside procedural `always @*` blocks?
5. Write the concatenation expression that sign-extends a 12-bit immediate to 32 bits.
6. What destination width is required to compute a 4-bit addition without losing carry-out?

---

Previous Chapter: [Chapter 01: Toolchain and First Module](../ch01/README.md) | Next Chapter: [Chapter 03: Operators and Bit-Width Rules](../ch03/README.md)
