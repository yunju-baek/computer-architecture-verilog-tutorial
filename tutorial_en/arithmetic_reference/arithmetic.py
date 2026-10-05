"""Fixed-width arithmetic and numerical-contract reference functions."""

from __future__ import annotations

import math
import struct
from dataclasses import asdict, dataclass


def mask(width: int) -> int:
    if not 2 <= width <= 64:
        raise ValueError("width must be in [2,64]")
    return (1 << width) - 1


def to_unsigned(value: int, width: int) -> int:
    return value & mask(width)


def to_signed(value: int, width: int) -> int:
    raw = to_unsigned(value, width)
    return raw - (1 << width) if raw & (1 << (width - 1)) else raw


def add_fixed(a: int, b: int, width: int) -> tuple[int, bool, bool]:
    ua, ub = to_unsigned(a, width), to_unsigned(b, width)
    full = ua + ub
    result = full & mask(width)
    carry = full > mask(width)
    sa, sb, sr = to_signed(ua, width), to_signed(ub, width), to_signed(result, width)
    overflow = (sa >= 0 and sb >= 0 and sr < 0) or (sa < 0 and sb < 0 and sr >= 0)
    return result, carry, overflow


def sub_fixed(a: int, b: int, width: int) -> tuple[int, bool, bool]:
    ua, ub = to_unsigned(a, width), to_unsigned(b, width)
    result = (ua - ub) & mask(width)
    no_borrow = ua >= ub
    sa, sb, sr = to_signed(ua, width), to_signed(ub, width), to_signed(result, width)
    overflow = (sa >= 0 > sb and sr < 0) or (sa < 0 <= sb and sr >= 0)
    return result, no_borrow, overflow


@dataclass(frozen=True)
class MultiplyStep:
    step: int
    multiplier_lsb: int
    multiplicand: int
    multiplier: int
    accumulator_before: int
    accumulator_after: int


def shift_add_unsigned(a: int, b: int, width: int) -> tuple[int, list[MultiplyStep]]:
    m = mask(width)
    multiplicand, multiplier, accumulator = a & m, b & m, 0
    trace: list[MultiplyStep] = []
    for step in range(width):
        before = accumulator
        if multiplier & 1:
            accumulator = (accumulator + multiplicand) & ((1 << (2 * width)) - 1)
        trace.append(MultiplyStep(step, multiplier & 1, multiplicand, multiplier, before, accumulator))
        multiplicand <<= 1
        multiplier >>= 1
    return accumulator, trace


@dataclass(frozen=True)
class DivideStep:
    step: int
    incoming_bit: int
    remainder_before: int
    shifted: int
    subtract: bool
    remainder_after: int
    quotient_after: int


def restoring_divide_unsigned(dividend: int, divisor: int, width: int) -> tuple[int, int, list[DivideStep]]:
    m = mask(width)
    dividend, divisor = dividend & m, divisor & m
    if divisor == 0:
        return m, dividend, []
    quotient = remainder = 0
    trace: list[DivideStep] = []
    for step in range(width - 1, -1, -1):
        before = remainder
        incoming = (dividend >> step) & 1
        shifted = (remainder << 1) | incoming
        take = shifted >= divisor
        remainder = shifted - divisor if take else shifted
        if take:
            quotient |= 1 << step
        trace.append(DivideStep(width - 1 - step, incoming, before, shifted, take, remainder, quotient))
    return quotient, remainder, trace


def riscv_divrem_signed(dividend: int, divisor: int, width: int = 32) -> tuple[int, int]:
    m = mask(width)
    a, b = to_signed(dividend, width), to_signed(divisor, width)
    if b == 0:
        return m, a & m
    min_int = -(1 << (width - 1))
    if a == min_int and b == -1:
        return a & m, 0
    q_abs = abs(a) // abs(b)
    q = -q_abs if (a < 0) ^ (b < 0) else q_abs
    r = a - q * b
    return q & m, r & m


def dot_i16(a: list[int], b: list[int], *, narrow_accumulator: bool = False) -> int:
    if len(a) != len(b):
        raise ValueError("vectors must have equal length")
    total = 0
    for x, y in zip(a, b):
        product = to_signed(x, 16) * to_signed(y, 16)
        total += product
        if narrow_accumulator:
            total = to_signed(total, 16)
    return total


def float32(value: float) -> float:
    return struct.unpack("!f", struct.pack("!f", value))[0]


def float32_bits(value: float) -> int:
    return struct.unpack("!I", struct.pack("!f", value))[0]


def naive_sum_f32(values: list[float]) -> float:
    total = float32(0.0)
    for value in values:
        total = float32(total + float32(value))
    return total


def kahan_sum_f32(values: list[float]) -> float:
    total = float32(0.0)
    correction = float32(0.0)
    for value in values:
        y = float32(float32(value) - correction)
        t = float32(total + y)
        correction = float32(float32(t - total) - y)
        total = t
    return total


def arithmetic_reference() -> dict[str, object]:
    product, mul_trace = shift_add_unsigned(13, 11, 8)
    quotient, remainder, div_trace = restoring_divide_unsigned(93, 7, 8)
    values = [1.0e20, -1.0e20, 3.14]
    dot_a = [32767, 32767, -32768, 7]
    dot_b = [32767, 2, -32768, -9]
    return {
        "add_7fffffff_1": add_fixed(0x7FFF_FFFF, 1, 32),
        "sub_80000000_1": sub_fixed(0x8000_0000, 1, 32),
        "mul_13_11": product,
        "mul_trace": [asdict(row) for row in mul_trace],
        "div_93_7": {"quotient": quotient, "remainder": remainder},
        "div_trace": [asdict(row) for row in div_trace],
        "signed_div_cases": {
            "-7/3": riscv_divrem_signed(-7, 3),
            "min/-1": riscv_divrem_signed(-(1 << 31), -1),
            "7/0": riscv_divrem_signed(7, 0),
        },
        "dot_i16": {
            "wide": dot_i16(dot_a, dot_b),
            "narrow_wrong": dot_i16(dot_a, dot_b, narrow_accumulator=True),
        },
        "float_non_associative": {
            "(a+b)+c": float32(float32(float32(values[0]) + float32(values[1])) + float32(values[2])),
            "a+(b+c)": float32(float32(values[0]) + float32(float32(values[1]) + float32(values[2]))),
            "naive": naive_sum_f32(values),
            "kahan": kahan_sum_f32(values),
            "0.1_bits": f"0x{float32_bits(0.1):08x}",
            "isfinite": math.isfinite(naive_sum_f32(values)),
        },
    }
