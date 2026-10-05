# Chapter 03: Operators and Bit-Width Rules

## 1. Learning Objectives

This chapter connects directly to HW02, where you implement 32-bit ALU results and inspect the supplied `zero`, `carry`, and `overflow` logic. Accurate arithmetic design depends on the bit-width expansion rules and sign-interpretation mechanisms established here.

Bit-width truncation errors represent the most frequent class of silent failures in Verilog HDL. Mastering standard operator semantics prevents unflagged upper-bit drops and arithmetic distortion.

Six core competencies:

1. Classify hardware operators and apply strict operator precedence.
2. Formulate expressions using the five bit-width context rules.
3. Distinguish signed from unsigned numeric interpretations on identical bit patterns.
4. Implement three shift variants (`<<`, `>>`, `>>>`) with `$signed` casting.
5. Derive the four core ALU status flags (`zero`, `negative`, `carry`, `overflow`).
6. Identify operator precedence traps and mixed-sign comparison hazards.

---

## 2. Hardware Operator Classification

Review operator classes in [`ex01_operators.v`](ex01_operators.v):

```bash
make test
```

Outputs for `a = 4'b1100` (12) and `b = 4'b0101` (5):

```text
--- Arithmetic operators: result is numeric ---
a + b  = 0001
a - b  = 0111
a * b  = 1100
a / b  = 0010  (integer division)
a % b  = 0010  (modulus)
--- Bitwise operators: evaluate bit-by-bit independently ---
~a     = 0011
a & b  = 0100
a | b  = 1101
a ^ b  = 1001
--- Logical operators: result is 1-bit boolean ---
!a         = 0  (tests if a equals zero)
!zero_value= 1
a && b     = 1  (asserts 1 if both operands non-zero)
a || b     = 1
zero_value && b = 0
--- Distinguishing bitwise from logical operators ---
a & b  = 0100  (bitwise AND)
a && b = 1     (boolean condition evaluation)
--- Reduction operators: reduce a vector to a single bit ---
&a     = 0  (tests if all bits equal 1)
|a     = 1  (tests if any bit equals 1)
^a     = 0  (tests odd parity)
~|a    = 0  (tests if all bits equal 0)
~|zero_value = 1
```

### Operator Taxonomy

| Category | Operators | Result Width | Hardware Mapping |
|---|---|---|---|
| Arithmetic | `+`, `-`, `*` | Determined by LHS/context width | Adders, subtractors, multipliers |
| Bitwise | `~`, `&`, `\|`, `^`, `~^` | Operand width | Bit-parallel logic gate arrays |
| Logical | `!`, `&&`, `\|\|` | 1-bit boolean | Control branch condition evaluators |
| Reduction | `&`, `~&`, `\|`, `~\|`, `^`, `~^` | 1-bit scalar | Tree reduction logic (e.g., zero detectors) |
| Relational | `>`, `<`, `>=`, `<=` | 1 bit | Signed/unsigned magnitude comparators |
| Equality | `==`, `!=` | 1 bit | Bitwise match comparators |
| 4-State Equality | `===`, `!==` | 1 bit | Full-match testbench comparators including `x`, `z` |
| Shift | `<<`, `>>`, `>>>` | Width of shifted operand | Barrel shifter arrays |
| Conditional Ternary | `? :` | Context width | 2:1 multiplexers |
| Concatenation / Replication | `{}`, `{N{}}` | Sum of component widths | Wiring routing and sign extension |

### Zero Flag Derivation via Reduction NOR

Detecting when all 32 result bits equal zero uses Reduction NOR (`~|`):

```verilog
assign zero = ~|result;      // Asserts 1'b1 when all 32 bits equal 0
```

---

## 3. Five Bit-Width Expansion Rules

Analyze the five rules from [`ex02_width_rules.v`](ex02_width_rules.v):

```text
a = f (15), b = 1 (1)
--- Rule 1: LHS width determines operation context width ---
4-bit target: a + b = 0000 (0)   (carry-out discarded)
5-bit target: a + b = 10000 (16)  (carry-out preserved)
--- Rule 2: Carry-out requires an expanded target width ---
wide_result[4] = 1  (this is carry-out)
--- Rule 3: Intermediate expressions inherit context width ---
(a + b) >> 4 stored in 1 bit = 0
({1'b0,a} + {1'b0,b}) >> 4   = 1  (context forced explicitly)
--- Rule 4: Unsized constants expand to 32 bits ---
a + 1 == 16   -> 1  (constant 1 expands expression context to 32 bits)
a + 4'b1 == 0 -> 1  (4-bit constant confines operation to 4-bit context)
--- Rule 5: Unsigned subtraction wraps modulo 2^N ---
4-bit: 2 - 7 = 1011 (11)   (wraps around modulo 16)
5-bit: 2 - 7 = 11011 (27)  (remains unsigned without cast)
With $signed:  2 - 7 = 11011 (-5)  (sign preserved)
```

### Rule 1: Context-Determined Width

Verilog sets the operational context width of an expression to the maximum bit width among the LHS destination net and all RHS operands:

```verilog
reg [3:0] a, b;
reg [3:0] narrow_sum;
reg [4:0] wide_sum;

narrow_sum = a + b;   // 4-bit context: computes 4-bit sum, discarding carry-out (15 + 1 = 0)
wide_sum   = a + b;   // 5-bit context: computes 5-bit sum, preserving carry-out (15 + 1 = 16)
```

### Rule 2: Carry-Out Preservation via Explicit Width Expansion

To preserve carry-out reliably, concatenate an explicit `1'b0` prefix to operands to enforce an N+1 bit context:

```verilog
wire [32:0] wide_sum = {1'b0, a} + {1'b0, b};   // Evaluated on 32-bit operands a, b
wire [31:0] sum      = wide_sum[31:0];
wire        carry    = wide_sum[32];
```

### Rule 3: Context Propagation Through Intermediate Sub-Expressions

Sub-expressions inherit the width of the enclosing expression context. Split complex compound expressions into intermediate `wire` nets with explicit widths to prevent accidental bit drops.

### Rule 4: 32-Bit Default Expansion of Unsized Literals

Unsized integer constants (such as bare `1`) default to 32-bit signed integers, expanding the context of the entire expression to at least 32 bits. Use sized literals (`4'b0001`) to maintain tight control over expression bit widths.

### Rule 5: Modulo Wrap-Around in Fixed-Width Arithmetic

Unsigned 4-bit subtraction `2 - 7` wraps modulo $2^4 = 16$, yielding `11` (`4'b1011`). Applying `$signed` interprets this identical bit pattern as two's complement integer `-5`.

---

## 4. Signed versus Unsigned Numeric Interpretation

Review [`ex03_signed.v`](ex03_signed.v):

```text
--- Declarations govern interpretation ---
4'b1111 read unsigned: 15
4'b1111 read signed:   -1
--- Type casting via $signed and $unsigned ---
u          = 1010 -> 10
$signed(u) = 1010 -> -6
s          = 1010 -> -6
$unsigned(s) = 1010 -> 10
--- Comparison outcomes diverge based on interpretation ---
u > 4'd0  -> 1  (15 > 0 is True)
s > 4'sd0 -> 0  (-1 > 0 is False)
--- Mixed-sign rule: Any unsigned operand forces unsigned evaluation ---
s        = 1111 (-1)
s < 4'sd1 -> 1  (Signed comparison)
s < u     -> 0  (u is unsigned; forces s into unsigned 15, yielding False)
$signed(s) < $signed(u) -> 1  (Casting both operands restores signed comparison)
```

### Mixed-Sign Expression Rule

If any operand in an expression is unsigned, Verilog casts all other operands in that expression to unsigned. When implementing signed comparisons, **cast both operands explicitly using `$signed`**:

```verilog
// Correct implementation of Signed Less-Than (SLT)
assign slt_result = ($signed(a) < $signed(b) ? 1'b1 : 1'b0);
```

---

## 5. Three Shift Variants

[`ex04_shift.v`](ex04_shift.v) models the three RV32I shift operations: `sll`, `srl`, and `sra`.

```verilog
assign sll_result = a << shamt;              // Shift Left Logical (SLL)
assign srl_result = a >> shamt;              // Shift Right Logical (SRL, zero-fill)
assign sra_result = $signed(a) >>> shamt;    // Shift Right Arithmetic (SRA, sign-replicated fill)
```

Arithmetic right shift (`>>>`) replicates the MSB sign bit into vacant upper positions only when the shifted operand is signed (`$signed(a)`). Applying `>>>` to an unsigned operand executes a logical shift, filling upper bits with zeros.

In 32-bit RV32I hardware, the shift amount uses only the lower 5 bits of the register operand (`b[4:0]`, values 0 to 31).

---

## 6. Mathematical Derivation of Four ALU Status Flags

[`ex05_flags.v`](ex05_flags.v) verifies flag generation logic on 4-bit addition:

```verilog
wire [4:0] wide_sum = {1'b0, a} + {1'b0, b};

assign sum      = wide_sum[3:0];
assign carry    = wide_sum[4];
assign zero     = ~|sum;
assign negative = sum[3];
assign overflow = (a[3] == b[3]) && (sum[3] != a[3]);
```

### Flag Hardware Detection Equations

1. Zero Flag (`zero`): Asserts when all 32 result bits equal zero (`~|sum`).
2. Negative Flag (`negative`): Reflects the MSB sign bit of the 32-bit result (`sum[31]`).
3. Carry Flag (`carry`): Asserts when unsigned addition produces a 33rd carry-out bit (`wide_sum[32]`).
4. Signed Overflow Flag (`overflow`): Asserts when adding two operands of identical sign produces a result with an inverted sign (`(a[31] == b[31]) && (sum[31] != a[31])`).

### Independence of Carry and Overflow

| Operand A | Operand B | Unsigned Evaluation | Two's Complement Evaluation | `carry` | `overflow` |
|---|---|---|---|---:|---:|
| `4'b1111` (15) | `4'b0001` (1) | $15+1=16$ (Exceeds 4 bits) | $-1+1=0$ (Within $[-8, 7]$) | 1 | 0 |
| `4'b0111` (7) | `4'b0001` (1) | $7+1=8$ (Within 4 bits) | $7+1=8$ (Exceeds maximum $+7$) | 0 | 1 |
| `4'b1000` (8) | `4'b1000` (8) | $8+8=16$ (Exceeds 4 bits) | $-8+(-8)=-16$ (Exceeds minimum $-8$) | 1 | 1 |
| `4'b0011` (3) | `4'b0010` (2) | $3+2=5$ (Within 4 bits) | $3+2=5$ (Within $[-8, 7]$) | 0 | 0 |

Carry and Signed Overflow represent completely orthogonal hardware status conditions.

---

## 7. Operator Precedence and Comparison Traps

1. Equality precedence trap: `a & b == c` evaluates as `a & (b == c)` because equality binds tighter than bitwise AND. Always use explicit parentheses: `(a & b) == c`.
2. Unsigned magnitude trap: Comparing `32'hffff_ffff` with `32'h0000_0001` under unsigned comparison (`sltu`) yields false ($4294967295 > 1$), whereas signed comparison (`slt`) yields true ($-1 < 1$).

---

## 8. Complete Chapter Verification

```bash
make test      # Verify example circuits
make errors    # Inspect operator precedence and sign comparison pitfalls
make clean
```

---

## 9. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| 33-bit addition for carry-out | Carry flag generation in HW02 ALU |
| Two's complement sign-inversion check | Overflow flag generation in HW02 ALU |
| Reduction NOR operator (`~|`) | Zero flag in HW02 ALU and `x0` ground checks in HW02 |
| Dual-operand `$signed` casting | HW02 ALU `slt` and `sra` instructions |
| Lower 5-bit shift masking | HW02 ALU and HW03 datapath shift execution |
| Parenthesized precedence enforcement | Control signal decoding in HW03 and HW04 |

---

## 10. Concept Check Questions

1. What context width principle causes carry-out loss in 4-bit assignment `narrow = a + b;`?
2. Write the standard Verilog expression preserving carry-out in 32-bit addition.
3. What arithmetic failure occurs in `$signed(a) < b` when operand `b` is unsigned?
4. Under what condition does arithmetic right shift (`>>>`) behave identically to logical right shift (`>>`)?
5. Provide a 4-bit addition input vector where `carry = 1` while `overflow = 0`.
6. State the two hardware conditions that trigger signed addition overflow.

---

Previous Chapter: [Chapter 02: Syntax and Data Types](../ch02/README.md) | Next Chapter: [Chapter 04: Combinational Circuit Design](../ch04/README.md)
