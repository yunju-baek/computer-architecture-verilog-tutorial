# ch02. 문법과 자료형

## 1. 학습 도달 목표

본 챕터를 완료하면 Verilog 하드웨어 기술에 필요한 자료형 체계와 비트 조작 문법을 완벽히 습득한다. 본 챕터의 내용은 HW02–HW05 전 과제에 걸쳐 매 행 적용된다. 특히 3절과 6절의 비트 슬라이싱 및 부호 확장(Sign Extension) 기법은 HW03 즉치수 생성기(ImmGen)의 핵심 구현 지식이다.

본 챕터의 7대 학습 핵심:

1. 숫자 리터럴 표기법과 비트 폭 명시 원칙
2. Verilog 4치 논리 시스템 (`0`, `1`, `x`, `z`)
3. `wire`와 `reg` 자료형의 하드웨어 구동 원칙
4. 벡터 비트 추출 3대 기법 (Bit, Part, Indexed Part Select)
5. 비트 결합(Concatenation) 및 복제(Replication)를 활용한 부호 확장
6. `parameter`와 `localparam`을 활용한 모듈 파라미터화
7. RTL 설계 시 빈번히 발생하는 4대 함정 및 디버깅 대응

---

## 2. 어휘 및 문법 규칙

하드웨어 기술 시 준수해야 하는 기본 문법 체계:

1. 식별자 명명: 영문자 또는 밑줄(`_`)로 시작하며, 대소문자를 엄격히 구분한다. `data`와 `Data`는 상이한 물리 도선으로 취급된다.
2. 주석 표기: 한 줄 주석은 `//`, 다중 행 주석은 `/* ... */` 형식을 사용한다.
3. 문장 종결자: 모든 선언문과 연속 할당문은 세미콜론(`;`)으로 종결한다. `begin`, `end`, `endmodule`, `always @*` 헤더는 종결자를 생략한다.
4. 예약어 소문자 원칙: `input`, `output`, `wire`, `reg`, `assign`, `always`, `module` 등 핵심 예약어는 반드시 소문자로 작성한다.
5. 시스템 작업 및 함수: `$display`, `$fatal`, `$signed`, `$time` 등 시스템 태스크는 접두사 `$`로 시작한다.

---

## 3. 숫자 리터럴 체계

[`ex01_numbers.v`](ex01_numbers.v) 실행으로 진법별 리터럴 표현을 확인한다.

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

### 리터럴 구문 형식

```text
<비트폭>'<진법><상수값>
   8   '   h     a3
```

| 진법 표기 | 진법 체계 | 작성 예시 |
|---|---|---|
| `'b` | 2진수 (Binary) | `4'b1010` |
| `'o` | 8진수 (Octal) | `8'o243` |
| `'d` | 10진수 (Decimal) | `8'd163` |
| `'h` | 16진수 (Hexadecimal) | `32'hdead_beef` |

밑줄(`_`)은 자릿수 가독성을 높이기 위한 구분 기호이며 하드웨어 값은 동일하게 유지된다.

### 비트 폭 명시 원칙

비트 폭을 생략한 상수는 32비트로 자동 확장되므로 주변 연산 문맥에서 의도치 않은 비트 확장을 유발할 수 있다. 따라서 모든 하드웨어 상수는 `1'b0`, `1'b1`, `32'h0000_0000`처럼 비트 폭을 명시적으로 선언한다.

---

## 4. 4치 논리 시스템 (`0`, `1`, `x`, `z`)

Verilog는 물리적 전기 신호 상태를 모델링하기 위해 4치 논리를 지원한다.

| 상태값 | 물리적 상태 정의 | 발생 원인 및 시나리오 |
|---|---|---|
| `0` | 논리 0 (Low / Ground) | 정상 구동 회로 |
| `1` | 논리 1 (High / VDD) | 정상 구동 회로 |
| `x` | 미정/충돌 상태 (Unknown) | 초기화되지 않은 `reg`, 누락된 조건 분기, 복수 구동원의 충돌 |
| `z` | 고임피던스 (High-Impedance) | 구동원이 단선된 `wire`, 3상태 버퍼의 비활성화 출력 |

[`ex02_xz.v`](ex02_xz.v) 실행 결과:

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

### `x` 전파 특성 및 4치 비교 연산자

산술 연산(`+`) 중 피연산자에 `x` 또는 `z`가 포함되면 캐리 전파 경로를 따라 상위 비트 전체가 `x`로 오염된다.

일반 비교 연산자(`==`, `!=`)는 피연산자에 `x`가 포함될 경우 결과로 `x`(조건문에서 거짓 취급)를 반환하므로 잠재적 결함을 은폐할 위험이 있다. 따라서 자가검사 testbench에서는 `x`와 `z` 상태까지 엄격히 일치해야 참을 반환하는 4치 비교 연산자(`===`, `!==`)를 적용한다.

---

## 5. `wire`와 `reg`의 하드웨어 구동 원칙

| 신호 구동 방식 | 권장 자료형 선언 | 하드웨어적 실체 |
|---|---|---|
| `assign` 연속 할당문 | `wire` | 조합논리 도선 |
| 하위 모듈 인스턴스의 출력 포트 연결 | `wire` | 모듈 간 상호 연결선 |
| `always @*` 절차 블록 내 대입 | `reg` | 조합논리 연산 회로 |
| `always @(posedge clk)` 절차 블록 내 대입 | `reg` | 클록 동기 플립플롭 레지스터 |
| `initial` 블록 내 자극 인가 (Testbench) | `reg` | 시뮬레이션 구동 레지스터 |

[`ex03_wire_reg.v`](ex03_wire_reg.v)는 2:1 멀티플렉서를 두 방식으로 구현한 예제다.

```verilog
// 방식 1: wire 출력을 assign으로 구동
module mux_with_assign(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       sel,
  output wire [3:0] y
);
  assign y = sel ? b : a;
endmodule

// 방식 2: reg 출력을 always @* 블록으로 구동
module mux_with_always(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       sel,
  output reg  [3:0] y
);
  always @* begin
    y = a;            // 기본값 선행 배정
    if (sel)
      y = b;          // 조건 활성화 시 선택 배정
  end
endmodule
```

단순 다중화는 `assign`으로 간결히 기술하고, 복합 디코더 및 ALU 연산은 `always @*`와 `case` 문으로 기술한다.

---

## 6. 벡터 비트 슬라이싱 3대 기법

[`ex04_select.v`](ex04_select.v)는 RV32I 명령어를 디코딩하기 위해 32비트 명령어를 필드별로 분할한다.

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

비트 슬라이싱 기법 체계:

| 기법 | 문법 형식 | 비트 폭 결정 | 주요 적용 분야 |
|---|---|---|---|
| Bit Select | `instr[31]` | 1비트 | 부호 비트 및 유효 플래그 추출 |
| Part Select | `instr[19:15]` | 고정 상수 폭 | 명령어 필드(`opcode`, `rd`, `rs1`) 분해 |
| Indexed Part Select | `data[base +: 8]` | 고정 폭 8비트, 가변 시작 위치 | 가변 바이트 오프셋 선택 및 캐시 메모리 접근 |

`data[base +: 8]` 구문에서 `+:`는 `base` 인덱스부터 상위 방향으로 8비트를 슬라이싱함을 명시한다.

---

## 7. 비트 결합 및 부호 확장 기법

[`ex05_concat.v`](ex05_concat.v)는 즉치수 생성기의 부호 확장 원리를 실증한다.

### 비트 결합(Concatenation) 및 복제(Replication)

- 비트 결합: `{A, B}`는 신호 A와 B를 상위/하위로 이어 붙인다.
- 비트 복제: `{N{Bit}}`는 지정 비트를 N회 연속 복제한다.

### 32비트 부호 확장 (Sign Extension)

12비트 I-Type 즉치수(`instr[31:20]`)를 32비트로 확장하는 하드웨어 결합식:

```verilog
assign imm_i = { {20{instr[31]}}, instr[31:20] };   // 20비트 부호 복제 + 12비트 원본
```

바깥 중괄호는 결합 연산자, 안쪽 중괄호는 복제 연산자다. 최상위 부호 비트 `instr[31]`이 `1`인 경우 상위 20비트가 `1`로 채워져 음수 값이 보존된다.

실측 비교 결과:

```text
--- 양수 즉치수 ---
instr[31:20] = 005
imm_i        = 00000005 (5)
--- 음수 즉치수 ---
instr[31:20] = fff
imm_i        = ffffffff (-1)  // 부호 확장: 상위 20비트를 1로 복제
zero_ext_i   = 00000fff (4095) // 0 확장: 상위 20비트를 0으로 채움
```

### Carry 비트 보존 관용구

4비트 덧셈에서 자리올림(Carry)을 추출하려면 결과를 5비트 폭으로 수신한다.

```verilog
wire [4:0] sum_with_carry;
assign sum_with_carry = op_a + op_b;
assign carry = sum_with_carry[4];
assign sum   = sum_with_carry[3:0];
```

---

## 8. `parameter`와 `localparam`

[`ex06_param.v`](ex06_param.v)는 파라미터를 활용하여 가변 폭 가산기를 구현한다.

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

파라미터 분류:

| 키워드 | 외부 재정의 가능 여부 | 주요 적용 목적 |
|---|---|---|
| `parameter` | 인스턴스화 시 `#(.WIDTH(32))`로 재정의 가능 | 버스 폭, 배열 깊이 등 모듈 설정값 |
| `localparam` | 모듈 내부 고정 (외부 변경 불가) | 내부 유도 비트 폭 계산, FSM 상태 인코딩 상수 |

---

## 9. RTL 설계 시 4대 함정 및 디버깅 대응

| 함정 유형 | 증상 및 잠재 결함 | 올바른 해결 방안 |
|---|---|---|
| `reg`를 `assign`으로 구동 | SystemVerilog 모드에서 경고 없이 통과 | 연속 할당 신호는 반드시 `wire`로 선언 |
| 미선언 중간 신호 | 1비트 `wire`로 자동 묵시 선언되어 상위 비트 절단 | 모든 중간 신호는 명시적 비트 폭과 함께 선언 |
| 상수 폭 절단 (`truncation`) | 상위 비트가 절단되어 의도치 않은 연산값 출력 | 상수 리터럴의 비트 폭을 좌변 신호 폭에 정확히 일치 |
| 복수 구동원 충돌 (`double driver`) | 신호 충돌로 인해 시뮬레이션 값이 `x`로 전파 | 단일 신호 구동원을 물리적으로 1개로 단일화 |

---

## 10. 챕터 전체 검증 실행

```bash
make test      # 정상 예제 검증
make errors    # 함정 예제 메시지 분석
make clean
```

---

## 11. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| 32비트 16진수 리터럴 표기 | HW02 `rtl/rv32_alu.v`의 기본값 배정 |
| `!==` 및 `$fatal` 검증문 | 모든 과제의 학생 추가 검증 testbench |
| Part Select 필드 분해 | HW03 `rtl/rv32i_decode.v`의 명령어 디코더 |
| Replication 부호 확장 | HW03 `rtl/rv32i_immgen.v`의 즉치수 조립 |
| 폭 확장을 통한 Carry 추출 | HW02 ALU의 Carry 플래그 생성 논리 |
| Indexed Part Select | HW05 캐시 데이터의 바이트 선택 회로 |

---

## 12. 핵심 개념 확인 질문

1. `8'h5`와 `'h5`의 비트 폭 처리 차이는 무엇인가?
2. 선언만 수행한 `reg`와 구동원이 연결되지 않은 `wire`의 초기 시뮬레이션 상태값은 각각 무엇인가?
3. testbench의 검증문에 `==` 대신 `===`를 사용하는 하드웨어적 이유는 무엇인가?
4. `always @*` 블록에서 대입하는 신호의 문법적 선언 자료형은 무엇인가?
5. 12비트 즉치수를 32비트로 부호 확장하는 복제 및 결합 연산식을 작성하라.
6. 4비트 덧셈의 결과에서 Carry 비트를 유실 없이 검출하기 위해 필요한 합산 버스의 비트 폭은 몇 비트인가?

---

이전 챕터: [ch01. 도구와 첫 모듈](../ch01/README.md) | 다음 챕터: [ch03. 연산자와 비트 폭 규칙](../ch03/README.md)
