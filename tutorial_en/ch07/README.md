# Chapter 07: Memory and FSM

## 1. Learning Objectives

This chapter establishes design methods for two-dimensional register memory arrays storing large data blocks and two-block Finite State Machines (FSMs) managing complex control flows. The 32-bit register file (`regfile.v`) in HW03, single-cycle instruction/data memories in HW04, and pipeline controllers in HW05 directly build upon the design patterns developed here.

Two core invariants:

1. In 2D array declarations, specify data word width to the left of the identifier and array depth to the right.
2. In 2-block FSM architectures, physically separate sequential state transitions (`always @(posedge clk)`) from combinational next-state/output logic (`always @*`).

Six core competencies:

1. Formulate standard 2D register array declarations.
2. Compare timing characteristics between asynchronous/combinational reads and synchronous registered reads.
3. Initialize memory arrays from hexadecimal binary text images using `$readmemh`.
4. Construct standard 2-block Moore FSM architectures.
5. Encapsulate state enumerations using `localparam`.
6. Resolve same-cycle read/write conflicts and prevent latch inference in FSM blocks.

---

## 2. Two-Dimensional Memory Array Architecture

[`ex01_memory.v`](ex01_memory.v) implements a 16-entry by 8-bit memory array:

```verilog
module ex01_memory #(
  parameter ADDR_WIDTH = 4,
  parameter DATA_WIDTH = 8
)(
  input  wire                  clk,
  input  wire                  write_enable,
  input  wire [ADDR_WIDTH-1:0] write_addr,
  input  wire [DATA_WIDTH-1:0] write_data,
  input  wire [ADDR_WIDTH-1:0] read_addr,
  output wire [DATA_WIDTH-1:0] read_data
);

  localparam DEPTH = 1 << ADDR_WIDTH;

  // 2D register array declaration: [word_width-1:0] array_name [0:depth-1]
  reg [DATA_WIDTH-1:0] storage [0:DEPTH-1];

  // Synchronous write: commits data on rising clock edge when write_enable asserts
  always @(posedge clk) begin
    if (write_enable)
      storage[write_addr] <= write_data;
  end

  // Asynchronous/combinational read: routes data immediately upon address change
  assign read_data = storage[read_addr];

endmodule
```

### 2D Array Declaration Syntax

```text
reg [DATA_WIDTH-1:0] storage [0:DEPTH-1];
    └─ Word bit width ─┘       └─ Total array depth ─┘
```

Array depth (`DEPTH`) is derived from address width (`ADDR_WIDTH`) via `1 << ADDR_WIDTH`, preventing out-of-bounds address indexing.

Simulation output:

```text
--- Combinational reads update immediately upon address transitions ---
addr | data
-----+-----
  0  |  10
  1  |  11
  2  |  12
  3  |  13
  4  |  14
--- Storage holds state when write_enable is low ---
write_enable=0 -> addr 3 data=13
--- Probing array element via hierarchical identifier ---
dut.storage[7] = 17
PASS ch07 ex01 memory
```

---

## 3. Timing Comparison: Combinational versus Synchronous Reads

[`ex02_sync_read.v`](ex02_sync_read.v) highlights timing differences between memory read architectures:

```verilog
// Combinational read: zero-delay immediate output (standard in single-cycle Regfiles)
assign read_data = storage[addr];

// Synchronous read: 1-cycle clocked registered output (standard in FPGA BRAM / SRAM)
always @(posedge clk) begin
  read_data <= storage[addr];
end
```

Timing trace comparison:

```text
  Time  addr | Comb  Sync
-------------+------------
  37ns   0   |  a0    xx  (Immediately after address application)
  46ns   0   |  a0    a0  (Following rising clock edge)
  47ns   2   |  a2    a0  (Immediately after address change)
  56ns   2   |  a2    a2  (Following rising clock edge)
```

Single-cycle RV32I cores (HW03, HW04) adopt combinational reads to complete instruction fetch and register read within a single clock cycle.

---

## 4. Memory Image Initialization via `$readmemh`

[`ex03_readmem.v`](ex03_readmem.v) initializes memory contents from an external hexadecimal file (`program.hex`):

```verilog
reg [31:0] instruction_memory [0:DEPTH-1];
integer    i;

initial begin
  // 1. Zero-fill full memory depth to suppress unknown (x) states
  for (i = 0; i < DEPTH; i = i + 1)
    instruction_memory[i] = 32'h0000_0000;

  // 2. Load hexadecimal memory image
  $readmemh(INIT_FILE, instruction_memory);
end
```

### Memory Initialization Guidelines

1. Distinguish `$readmemh` (hexadecimal text) from `$readmemb` (binary text).
2. Embed assembly comments (`//`) inside hex files to document instruction meanings.
3. Clear memory arrays to `32'h0000_0000` before loading images.
4. Confine `initial` blocks containing `$readmemh` to simulation testbenches.

---

## 5. Standard Two-Block Moore FSM Architecture

[`ex04_fsm.v`](ex04_fsm.v) implements a sequence detector recognizing three consecutive `1` bits:

```verilog
localparam [1:0] IDLE     = 2'd0;
localparam [1:0] SAW_ONE  = 2'd1;
localparam [1:0] SAW_TWO  = 2'd2;
localparam [1:0] SAW_MANY = 2'd3;

reg [1:0] state, next_state;

// Block 1: Sequential state register (Synchronous Reset)
always @(posedge clk) begin
  if (reset)
    state <= IDLE;
  else
    state <= next_state;
end

// Block 2: Combinational next-state and output logic
always @* begin
  // Default value pre-assignment prevents latch inference
  next_state = state;
  detected   = 1'b0;

  case (state)
    IDLE: begin
      if (bit_in) next_state = SAW_ONE;
    end
    SAW_ONE: begin
      if (bit_in) next_state = SAW_TWO;
      else        next_state = IDLE;
    end
    SAW_TWO: begin
      if (bit_in) next_state = SAW_MANY;
      else        next_state = IDLE;
    end
    SAW_MANY: begin
      detected = 1'b1;
      if (bit_in) next_state = SAW_MANY;
      else        next_state = IDLE;
    end
    default: next_state = IDLE;
  endcase
end
```

### 2-Block FSM Design Principles

1. Local state encodings: Define state enumerations using `localparam` within the module scope.
2. Combinational default assignments: Pre-assign `next_state = state;` and deassert control outputs at the top of Block 2 to eliminate latches.
3. Moore output standard: Tie output signals (`detected`) strictly to the current state (`state`), ensuring glitch-free synchronous transitions.

---

## 6. Diagnostic Analysis: Three Memory and FSM Defects

Execute `make errors` to inspect compiler diagnostics across three intentional defects:

```bash
make errors
```

### Defect 1: Same-Cycle Read/Write Address Collision (`bad01_same_addr.v`)

When read and write operations target identical addresses in the same cycle, combinational reads return newly written data (write-first), whereas synchronous reads return prior-cycle data (read-first). Pipelined processor architectures implement forwarding bypasses to maintain consistency across colliding memory stages.

### Defect 2: Omitted FSM Combinational Defaults (`bad02_fsm_state.v`)

Omitting default assignments in Block 2 causes control signals to latch into unwanted transparent storage when leaving active states.

### Defect 3: Address Bus and Memory Depth Mismatches (`bad03_array_range.v`)

Connecting a 4-bit address bus (16 reachable words) to an 8-entry array causes accesses to addresses 8–15 to return unknown values (`x`). Maintain depth matching: `DEPTH = 1 << ADDR_WIDTH`.

---

## 7. Complete Chapter Verification

```bash
make test      # Verify functional memory and FSM examples
make errors    # Inspect intentional defect diagnostics
make clean
```

---

## 8. Connection to Course Assignments

| Chapter Concept | Assignment Application |
|---|---|
| 2D array with synchronous write | 32-entry register file in HW03 `rtl/regfile.v` |
| 2-port combinational read | `rs1_data` and `rs2_data` read ports in HW03 |
| `$readmemh` hex loader | Loading test programs in HW04 and HW05 testbenches |
| 2-block FSM architecture | Bus interface and cache controllers in HW05 |
| `localparam` state enumeration | ALU operation encodings and pipeline control vectors |

---

## 9. Concept Check Questions

1. In declaration `reg [31:0] rf [0:31];`, identify the word width and total entry depth.
2. Why does the single-cycle processor register file require combinational rather than synchronous reads?
3. In a 2-block FSM, define the distinct roles and assignment operators assigned to Block 1 versus Block 2.
4. Why does pre-assigning `next_state = state;` at the top of Block 2 eliminate latch inference?
5. Why must memory arrays be pre-cleared to zero before loading files with `$readmemh`?

---

Previous Chapter: [Chapter 06: Hierarchy and Parameterization](../ch06/README.md) | Next Chapter: [Chapter 08: Testbench Methodologies](../ch08/README.md)
