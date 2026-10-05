# TinyRV interface contract

This teaching subset defines the HW02 module interfaces and behavior. Preserve the module ports and the register array `regs`.

## Control codes

- `imm_sel`: I=0, S=1, B=2, U=3, J=4; unsupported selector produces zero.
- `alu_op`: ADD=0, SUB=1, AND=2, OR=3, XOR=4, SLL=5, SRL=6, SRA=7, SLT=8, SLTU=9. Code 10 marks LUI immediate bypass; ALU default result remains zero.
- `branch`: none=0, BEQ=1, BNE=2.
- PC reset value is 0. Clocked PC priority is reset, load, enable, then hold. Default step is 4.
- Register file: 32 words, two combinational reads, one rising-edge write, x0 reads zero and discards writes. Match the provided interface; initial-state checks follow the public testbench.

## Decoder subset

| Class | Opcode | Supported operations | Main controls |
|---|---|---|---|
| R | 0x33 | ADD, SUB, AND, OR, XOR, SLT, SLTU | reg_write=1, register operands |
| I | 0x13 | ADDI, ANDI, ORI, XORI | I immediate, alu_src_imm=1, reg_write=1 |
| Load | 0x03 | LW (funct3=2) | I immediate, ADD, reg_write=1, mem_to_reg=1 |
| Store | 0x23 | SW (funct3=2) | S immediate, ADD, mem_write=1 |
| Branch | 0x63 | BEQ (funct3=0), BNE (funct3=1) | B immediate, SUB, branch=1 or 2 |
| LUI | 0x37 | LUI | U immediate, alu_src_imm=1, reg_write=1, alu_op=10 |
| JAL | 0x6f | JAL | J immediate, alu_src_imm=1, reg_write=1, jump=1 |

R funct3: ADD/SUB=0, AND=7, OR=6, XOR=4, SLT=2, SLTU=3. ADD uses funct7=0, SUB uses funct7=0x20. Other supported R operations use base encodings in assignment tests. I funct3: ADDI=0, ANDI=7, ORI=6, XORI=4. Shift operations are tested directly at the ALU; this decoder subset uses the listed instruction set.

Default control values: imm_sel=I, alu_op=ADD, all enables and branch/jump zero. Recognized supported instructions set their relevant controls. Unsupported opcodes and unsupported funct3 values set illegal=1. ADD/SUB with unsupported funct7 also sets illegal=1. On illegal, clear reg_write, mem_write, branch, and jump. Tests use the defined teaching subset; complete ISA exception handling is outside this contract.

## Immediate formats

I selects bits 31:20; S concatenates 31:25 and 11:7. B orders 31, 7, 30:25, 11:8, then zero. J orders 31, 19:12, 20, 30:21, then zero. Sign-extend I/S/B/J to 32 bits. U places bits 31:12 above twelve zeros.
