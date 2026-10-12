#!/usr/bin/env python3
"""Small RV32I assembler and architectural-state simulator for HW01.

The supported subset covers the RV32I integer instructions and common
pseudo-instructions needed by state_contract.s (see SUPPORTED_SYNTAX). Every
assembled instruction is a real 32-bit RV32I encoding. The simulator records
the state transition committed by each instruction.
"""

from __future__ import annotations

import argparse
import csv
import json
import re
import struct
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


MASK32 = 0xFFFF_FFFF
DATA_BASE = 0x400
DEFAULT_SP = 0x800
DEFAULT_STOP_PC = 0xFFC

ABI_NAMES = [
    "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6",
]
REGISTERS = {name: index for index, name in enumerate(ABI_NAMES)}
REGISTERS.update({f"x{index}": index for index in range(32)})
REGISTERS["fp"] = 8

R_OPS = {
    "add": (0, 0x00), "sub": (0, 0x20), "sll": (1, 0x00), "slt": (2, 0x00),
    "sltu": (3, 0x00), "xor": (4, 0x00), "srl": (5, 0x00), "sra": (5, 0x20),
    "or": (6, 0x00), "and": (7, 0x00),
}
I_ALU_OPS = {"addi": 0, "slti": 2, "sltiu": 3, "xori": 4, "ori": 6, "andi": 7}
SHIFT_OPS = {"slli": (1, 0x00), "srli": (5, 0x00), "srai": (5, 0x20)}
IMMEDIATE_BASE = {
    "addi": "add", "slti": "slt", "sltiu": "sltu", "xori": "xor", "ori": "or",
    "andi": "and", "slli": "sll", "srli": "srl", "srai": "sra",
}
BRANCH_OPS = {"beq": 0, "bne": 1, "blt": 4, "bge": 5, "bltu": 6, "bgeu": 7}
ZERO_BRANCHES = {
    "beqz": ("beq", False), "bnez": ("bne", False), "bltz": ("blt", False),
    "bgez": ("bge", False), "blez": ("bge", True), "bgtz": ("blt", True),
}
SWAPPED_BRANCHES = {"bgt": "blt", "ble": "bge", "bgtu": "bltu", "bleu": "bgeu"}
SUPPORTED_SYNTAX = (
    "R: add sub sll slt sltu xor srl sra or and",
    "I: addi slti sltiu xori ori andi slli srli srai lw jalr",
    "S/B/J: sw beq bne blt bge bltu bgeu jal ebreak",
    "pseudo: nop mv li la neg not seqz snez j jr call ret "
    "beqz bnez bltz bgez blez bgtz bgt ble bgtu bleu",
    "directives: .data .text .globl .word; li immediate: -2048..2047",
)
TRACE_FIELDS = ["seq", "pc", "word", "asm", "rd", "rd_value", "mem_addr", "mem_value", "next_pc", "sp"]
HEX_TRACE_FIELDS = {"pc", "word", "rd_value", "mem_addr", "mem_value", "next_pc", "sp"}


class AssemblyError(ValueError):
    """Raised when source falls outside the documented HW01 subset."""


@dataclass(frozen=True)
class PendingInstruction:
    pc: int
    op: str
    args: tuple[str, ...]
    source: str
    line: int


@dataclass(frozen=True)
class Instruction:
    pc: int
    op: str
    args: tuple[str, ...]
    word: int
    source: str
    line: int


@dataclass(frozen=True)
class Program:
    instructions: dict[int, Instruction]
    labels: dict[str, int]
    data_words: dict[int, int]

    @property
    def text_words(self) -> list[int]:
        return [self.instructions[pc].word for pc in sorted(self.instructions)]


@dataclass(frozen=True)
class RunResult:
    registers: tuple[int, ...]
    memory_words: dict[int, int]
    trace: tuple[dict[str, int | str], ...]
    pc: int
    halted: bool


def u32(value: int) -> int:
    return value & MASK32


def s32(value: int) -> int:
    value &= MASK32
    return value - (1 << 32) if value & (1 << 31) else value


def register_index(token: str) -> int:
    key = token.strip().lower()
    if key not in REGISTERS:
        raise AssemblyError(f"unknown register: {token}")
    return REGISTERS[key]


def immediate(token: str) -> int:
    try:
        return int(token, 0)
    except ValueError as exc:
        raise AssemblyError(f"invalid immediate: {token}") from exc


def signed_field(value: int, bits: int, name: str) -> int:
    low = -(1 << (bits - 1))
    high = (1 << (bits - 1)) - 1
    if not low <= value <= high:
        raise AssemblyError(f"{name} out of range: {value}")
    return value & ((1 << bits) - 1)


def parse_memory_operand(token: str) -> tuple[int, int]:
    match = re.fullmatch(r"([^()]*)\(([^()]+)\)", token.replace(" ", ""))
    if not match:
        raise AssemblyError(f"invalid memory operand: {token}")
    return immediate(match.group(1) or "0"), register_index(match.group(2))


def split_statement(text: str) -> tuple[str, tuple[str, ...]]:
    pieces = text.replace(",", " ").split()
    if not pieces:
        raise AssemblyError("empty instruction")
    return pieces[0].lower(), tuple(pieces[1:])


def require_args(op: str, args: tuple[str, ...], count: int) -> None:
    if len(args) != count:
        raise AssemblyError(f"{op} expects {count} operands, received {len(args)}")


def encode_r(rd: int, rs1: int, rs2: int, funct3: int, funct7: int) -> int:
    return (
        (funct7 << 25) | (rs2 << 20) | (rs1 << 15) |
        (funct3 << 12) | (rd << 7) | 0x33
    )


def encode_i(rd: int, rs1: int, imm: int, funct3: int, opcode: int) -> int:
    raw = signed_field(imm, 12, "I-immediate")
    return (raw << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode


def encode_s(rs1: int, rs2: int, imm: int, funct3: int) -> int:
    raw = signed_field(imm, 12, "S-immediate")
    return (
        ((raw >> 5) << 25) | (rs2 << 20) | (rs1 << 15) |
        (funct3 << 12) | ((raw & 0x1F) << 7) | 0x23
    )


def encode_b(rs1: int, rs2: int, offset: int, funct3: int) -> int:
    if offset % 2:
        raise AssemblyError(f"branch offset must be even: {offset}")
    raw = signed_field(offset, 13, "B-offset")
    return (
        (((raw >> 12) & 1) << 31) |
        (((raw >> 5) & 0x3F) << 25) |
        (rs2 << 20) | (rs1 << 15) | (funct3 << 12) |
        (((raw >> 1) & 0xF) << 8) |
        (((raw >> 11) & 1) << 7) | 0x63
    )


def encode_j(rd: int, offset: int) -> int:
    if offset % 2:
        raise AssemblyError(f"jump offset must be even: {offset}")
    raw = signed_field(offset, 21, "J-offset")
    return (
        (((raw >> 20) & 1) << 31) |
        (((raw >> 1) & 0x3FF) << 21) |
        (((raw >> 11) & 1) << 20) |
        (((raw >> 12) & 0xFF) << 12) |
        (rd << 7) | 0x6F
    )


def resolve_label(labels: dict[str, int], token: str, line: int) -> int:
    if token not in labels:
        raise AssemblyError(f"line {line}: unknown label {token}")
    return labels[token]


def normalize_instruction(item: PendingInstruction, labels: dict[str, int]) -> tuple[str, tuple[str, ...]]:
    op, args = item.op, item.args
    if op == "mv":
        require_args(op, args, 2)
        return "addi", (args[0], args[1], "0")
    if op == "li":
        require_args(op, args, 2)
        signed_field(immediate(args[1]), 12, "li immediate")
        return "addi", (args[0], "zero", args[1])
    if op == "la":
        require_args(op, args, 2)
        address = resolve_label(labels, args[1], item.line)
        signed_field(address, 12, "la address")
        return "addi", (args[0], "zero", str(address))
    if op == "ret":
        require_args(op, args, 0)
        return "jalr", ("zero", "0(ra)")
    if op == "jr":
        require_args(op, args, 1)
        return "jalr", ("zero", f"0({args[0]})")
    if op == "j":
        require_args(op, args, 1)
        return "jal", ("zero", args[0])
    if op == "call" or (op == "jal" and len(args) == 1):
        require_args(op, args, 1)
        return "jal", ("ra", args[0])
    if op == "jalr" and len(args) == 1:
        return "jalr", ("ra", f"0({args[0]})")
    if op == "jalr" and len(args) == 3:
        return "jalr", (args[0], f"{args[2]}({args[1]})")
    if op == "nop":
        require_args(op, args, 0)
        return "addi", ("zero", "zero", "0")
    if op == "neg":
        require_args(op, args, 2)
        return "sub", (args[0], "zero", args[1])
    if op == "not":
        require_args(op, args, 2)
        return "xori", (args[0], args[1], "-1")
    if op == "seqz":
        require_args(op, args, 2)
        return "sltiu", (args[0], args[1], "1")
    if op == "snez":
        require_args(op, args, 2)
        return "sltu", (args[0], "zero", args[1])
    if op in ZERO_BRANCHES:
        require_args(op, args, 2)
        base, swap = ZERO_BRANCHES[op]
        return base, ("zero", args[0], args[1]) if swap else (args[0], "zero", args[1])
    if op in SWAPPED_BRANCHES:
        require_args(op, args, 3)
        return SWAPPED_BRANCHES[op], (args[1], args[0], args[2])
    return op, args


def encode_instruction(item: PendingInstruction, labels: dict[str, int]) -> Instruction:
    op, args = normalize_instruction(item, labels)
    if op in R_OPS:
        require_args(op, args, 3)
        funct3, funct7 = R_OPS[op]
        word = encode_r(register_index(args[0]), register_index(args[1]), register_index(args[2]), funct3, funct7)
    elif op in I_ALU_OPS:
        require_args(op, args, 3)
        word = encode_i(register_index(args[0]), register_index(args[1]), immediate(args[2]), I_ALU_OPS[op], 0x13)
    elif op in SHIFT_OPS:
        require_args(op, args, 3)
        shamt = immediate(args[2])
        if not 0 <= shamt <= 31:
            raise AssemblyError(f"line {item.line}: shift amount out of range: {shamt}")
        funct3, funct7 = SHIFT_OPS[op]
        word = encode_i(register_index(args[0]), register_index(args[1]), (funct7 << 5) | shamt, funct3, 0x13)
    elif op == "lw":
        require_args(op, args, 2)
        offset, rs1 = parse_memory_operand(args[1])
        word = encode_i(register_index(args[0]), rs1, offset, 2, 0x03)
    elif op == "jalr":
        require_args(op, args, 2)
        offset, rs1 = parse_memory_operand(args[1])
        word = encode_i(register_index(args[0]), rs1, offset, 0, 0x67)
    elif op == "sw":
        require_args(op, args, 2)
        offset, rs1 = parse_memory_operand(args[1])
        word = encode_s(rs1, register_index(args[0]), offset, 2)
    elif op in BRANCH_OPS:
        require_args(op, args, 3)
        target = resolve_label(labels, args[2], item.line)
        word = encode_b(register_index(args[0]), register_index(args[1]), target - item.pc, BRANCH_OPS[op])
    elif op == "jal":
        require_args(op, args, 2)
        target = resolve_label(labels, args[1], item.line)
        word = encode_j(register_index(args[0]), target - item.pc)
    elif op == "ebreak":
        require_args(op, args, 0)
        word = 0x0010_0073
    else:
        raise AssemblyError(f"line {item.line}: unsupported instruction {op}")
    return Instruction(item.pc, op, args, word, item.source, item.line)


def assemble_text(source: str) -> Program:
    section = "text"
    text_pc = 0
    data_address = DATA_BASE
    labels: dict[str, int] = {}
    pending: list[PendingInstruction] = []
    data_words: dict[int, int] = {}

    for line_number, raw in enumerate(source.splitlines(), 1):
        source_line = raw.split("#", 1)[0].strip()
        if not source_line:
            continue
        while ":" in source_line:
            label, remainder = source_line.split(":", 1)
            label = label.strip()
            if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", label):
                raise AssemblyError(f"line {line_number}: invalid label {label}")
            if label in labels:
                raise AssemblyError(f"line {line_number}: duplicate label {label}")
            labels[label] = text_pc if section == "text" else data_address
            source_line = remainder.strip()
            if not source_line:
                break
        if not source_line:
            continue
        if source_line in {".text", ".data"}:
            section = source_line[1:]
            continue
        if source_line.startswith(".globl"):
            continue
        if source_line.startswith(".word"):
            if section != "data":
                raise AssemblyError(f"line {line_number}: .word belongs in .data")
            values = source_line[len(".word"):].split(",")
            if not any(value.strip() for value in values):
                raise AssemblyError(f"line {line_number}: .word requires data")
            for value in values:
                data_words[data_address] = u32(immediate(value.strip()))
                data_address += 4
            continue
        if source_line.startswith("."):
            raise AssemblyError(f"line {line_number}: unsupported directive {source_line}")
        if section != "text":
            raise AssemblyError(f"line {line_number}: instruction belongs in .text")
        op, args = split_statement(source_line)
        pending.append(PendingInstruction(text_pc, op, args, source_line, line_number))
        text_pc += 4

    instructions = {item.pc: encode_instruction(item, labels) for item in pending}
    if "main" not in labels:
        raise AssemblyError("program requires a main label")
    return Program(instructions=instructions, labels=labels, data_words=data_words)


def assemble(path: Path | str) -> Program:
    source_path = Path(path)
    return assemble_text(source_path.read_text(encoding="utf-8"))


def _read_word(memory: dict[int, int], address: int) -> int:
    if address % 4:
        raise RuntimeError(f"unaligned word load at 0x{address:08x}")
    return memory.get(address, 0)


def _write_word(memory: dict[int, int], address: int, value: int) -> None:
    if address % 4:
        raise RuntimeError(f"unaligned word store at 0x{address:08x}")
    memory[address] = u32(value)


def run(
    program: Program,
    *,
    entry: str = "main",
    initial_registers: dict[str, int] | None = None,
    memory_words: dict[int, int] | None = None,
    stop_pc: int | None = None,
    max_steps: int = 1000,
    allow_step_limit: bool = False,
) -> RunResult:
    if entry not in program.labels:
        raise RuntimeError(f"unknown entry label: {entry}")
    registers = [0] * 32
    registers[register_index("sp")] = DEFAULT_SP
    for name, value in (initial_registers or {}).items():
        registers[register_index(name)] = u32(value)
    registers[0] = 0
    memory = dict(program.data_words)
    memory.update({address: u32(value) for address, value in (memory_words or {}).items()})
    pc = program.labels[entry]
    trace: list[dict[str, int | str]] = []
    halted = False

    for sequence in range(max_steps):
        if stop_pc is not None and pc == stop_pc:
            halted = True
            break
        if pc not in program.instructions:
            raise RuntimeError(f"PC reached unmapped address 0x{pc:08x}")
        instruction = program.instructions[pc]
        op, args = instruction.op, instruction.args
        next_pc = u32(pc + 4)
        rd_index: int | None = None
        rd_value: int | None = None
        memory_address: int | None = None
        memory_value: int | None = None

        if op in R_OPS or op in I_ALU_OPS or op in SHIFT_OPS:
            rd_index = register_index(args[0])
            left = registers[register_index(args[1])]
            if op in R_OPS:
                right = registers[register_index(args[2])]
                base = op
            else:
                right = u32(immediate(args[2]))
                base = IMMEDIATE_BASE[op]
            if base == "add":
                rd_value = u32(left + right)
            elif base == "sub":
                rd_value = u32(left - right)
            elif base == "and":
                rd_value = left & right
            elif base == "or":
                rd_value = left | right
            elif base == "xor":
                rd_value = left ^ right
            elif base == "slt":
                rd_value = int(s32(left) < s32(right))
            elif base == "sltu":
                rd_value = int(left < right)
            elif base == "sll":
                rd_value = u32(left << (right & 0x1F))
            elif base == "srl":
                rd_value = left >> (right & 0x1F)
            else:
                rd_value = u32(s32(left) >> (right & 0x1F))
        elif op == "lw":
            rd_index = register_index(args[0])
            offset, rs1 = parse_memory_operand(args[1])
            memory_address = u32(registers[rs1] + offset)
            rd_value = _read_word(memory, memory_address)
        elif op == "sw":
            offset, rs1 = parse_memory_operand(args[1])
            memory_address = u32(registers[rs1] + offset)
            memory_value = registers[register_index(args[0])]
            _write_word(memory, memory_address, memory_value)
        elif op in BRANCH_OPS:
            left = registers[register_index(args[0])]
            right = registers[register_index(args[1])]
            taken = {
                "beq": left == right,
                "bne": left != right,
                "blt": s32(left) < s32(right),
                "bge": s32(left) >= s32(right),
                "bltu": left < right,
                "bgeu": left >= right,
            }[op]
            if taken:
                next_pc = program.labels[args[2]]
        elif op == "jal":
            rd_index = register_index(args[0])
            rd_value = u32(pc + 4)
            next_pc = program.labels[args[1]]
        elif op == "jalr":
            rd_index = register_index(args[0])
            offset, rs1 = parse_memory_operand(args[1])
            rd_value = u32(pc + 4)
            next_pc = u32(registers[rs1] + offset) & ~1
        elif op == "ebreak":
            halted = True
        else:
            raise RuntimeError(f"unsupported operation at runtime: {op}")

        if rd_index is not None and rd_index != 0:
            registers[rd_index] = u32(rd_value or 0)
        registers[0] = 0
        trace.append({
            "seq": sequence,
            "pc": pc,
            "word": instruction.word,
            "asm": instruction.source,
            "rd": "-" if rd_index in {None, 0} else ABI_NAMES[rd_index],
            "rd_value": "-" if rd_index in {None, 0} else u32(rd_value or 0),
            "mem_addr": "-" if memory_address is None else memory_address,
            "mem_value": "-" if memory_value is None else u32(memory_value),
            "next_pc": next_pc,
            "sp": registers[register_index("sp")],
        })
        pc = next_pc
        if op == "ebreak":
            break
    else:
        if not allow_step_limit:
            raise RuntimeError(f"execution exceeded max_steps={max_steps}")

    return RunResult(tuple(registers), memory, tuple(trace), pc, halted)


def write_binary(program: Program, target: Path | str) -> None:
    path = Path(target)
    path.write_bytes(b"".join(struct.pack("<I", word) for word in program.text_words))


def write_hex(program: Program, target: Path | str) -> None:
    Path(target).write_text("".join(f"{word:08x}\n" for word in program.text_words), encoding="utf-8")


def format_trace_row(row: dict[str, int | str]) -> dict[str, str]:
    """Render addresses and values as 0x%08x so trace rows match report notation."""
    rendered = {}
    for field in TRACE_FIELDS:
        value = row[field]
        rendered[field] = f"0x{value:08x}" if field in HEX_TRACE_FIELDS and isinstance(value, int) else str(value)
    return rendered


def write_trace(rows: Iterable[dict[str, int | str]], target: Path | str) -> None:
    with Path(target).open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=TRACE_FIELDS)
        writer.writeheader()
        writer.writerows(format_trace_row(row) for row in rows)


def state_dict(result: RunResult) -> dict[str, object]:
    registers = {f"x{index}/{ABI_NAMES[index]}": f"0x{value:08x}" for index, value in enumerate(result.registers)}
    memory = {f"0x{address:08x}": f"0x{value:08x}" for address, value in sorted(result.memory_words.items())}
    return {"halted": result.halted, "pc": f"0x{result.pc:08x}", "registers": registers, "memory_words": memory}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("--hex", type=Path)
    parser.add_argument("--binary", type=Path)
    parser.add_argument("--trace", type=Path)
    parser.add_argument("--state", type=Path)
    args = parser.parse_args()

    program = assemble(args.source)
    result = run(program)
    for target in (args.hex, args.binary, args.trace, args.state):
        if target:
            target.parent.mkdir(parents=True, exist_ok=True)
    if args.hex:
        write_hex(program, args.hex)
    if args.binary:
        write_binary(program, args.binary)
    if args.trace:
        write_trace(result.trace, args.trace)
    if args.state:
        args.state.write_text(json.dumps(state_dict(result), indent=2) + "\n", encoding="utf-8")
    print(f"PASS RV32I instructions={len(program.instructions)} trace_rows={len(result.trace)}")


if __name__ == "__main__":
    main()
