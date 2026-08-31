# ch10. Verilog-2001 vs SystemVerilog 구문 대조 가이드

## 1. 학습 도달 목표

본 챕터는 학생이 구현하는 Verilog-2001 표준 RTL 코드와 평가 환경에서 제공되는 SystemVerilog(IEEE 1800-2012) 테스트벤치/레퍼런스 모델 간의 상호 연동 및 문법적 매핑 기준을 확립한다. Icarus Verilog 컴파일러의 `-g2012` 옵션으로 두 표준은 단일 시뮬레이션 환경에서 원활히 통합된다.

2대 상호 운용성 규칙:

1. 학생 구현 RTL은 엄격한 하드웨어 합성 규칙을 위해 Verilog-2001 문법 표준을 유지한다.
2. 테스트벤치 및 레퍼런스 모델에서 사용되는 SystemVerilog 확장 구문(`logic`, `always_comb`, `enum`, `struct`)을 정확히 해석하여 인터페이스 규격을 완벽히 정합한다.

본 챕터의 5대 학습 핵심:

1. Verilog-2001 RTL과 SystemVerilog 테스트벤치 간의 인스턴스화 호환성
2. `always_comb`, `always_ff`, `always_latch`의 정적 의도 명시와 감지 목록 차이
3. `logic` 단일 자료형의 `wire`/`reg` 자동 추론 메커니즘
4. `typedef enum` 및 `packed struct`를 활용한 데이터 필드 패킹/언패킹
5. 자료형·구문·제어문 1:1 완결 대응표

---

## 2. Verilog-2001과 SystemVerilog 상호 연동 아키텍처

[`ex01_style.sv`](ex01_style.sv)는 동일한 2:1 멀티플렉서를 두 문법 표준으로 비교 구현한다.

```verilog
// 1. Verilog-2001 표기 (학생 RTL 구현 표준)
module mux_verilog2001(
  input  wire [7:0] a,
  input  wire [7:0] b,
  input  wire       sel,
  output reg  [7:0] y
);
  always @* begin
    y = a;
    if (sel) y = b;
  end
endmodule

// 2. SystemVerilog 표기 (테스트벤치 및 레퍼런스 모델 표준)
module mux_systemverilog(
  input  logic [7:0] a,
  input  logic [7:0] b,
  input  logic       sel,
  output logic [7:0] y
);
  always_comb begin
    y = a;
    if (sel) y = b;
  end
endmodule
```

[`tb_ex01.sv`](tb_ex01.sv)에서 SystemVerilog 테스트벤치가 Verilog-2001 모듈을 인스턴스화하여 검증한다.

```verilog
logic [7:0] a, b;
logic       sel;
logic [7:0] mux_v, mux_sv;

// Verilog-2001 모듈을 SystemVerilog 테스트벤치에서 직접 인스턴스화
mux_verilog2001   u_mux_v  (.a(a), .b(b), .sel(sel), .y(mux_v));
mux_systemverilog u_mux_sv (.a(a), .b(b), .sel(sel), .y(mux_sv));
```

실행 결과:

```text
--- 조합 논리 대조 ---
sel=0 -> Verilog aa, SystemVerilog aa
sel=1 -> Verilog bb, SystemVerilog bb
--- 순차 논리 대조 ---
reset 뒤 -> Verilog 00, SystemVerilog 00
d=5a 뒤  -> Verilog 5a, SystemVerilog 5a
PASS ch10 ex01 표기 대조
```

---

## 3. `always_comb` vs `always @*`의 동작 비교

[`ex03_always_comb.sv`](ex03_always_comb.sv)는 시뮬레이션 시각 0에서의 초기 평가 동작 차이를 실증한다.

```verilog
logic [3:0] a = 4'd3;
logic [3:0] b = 4'd4;
```

실행 결과 비교:

```text
   0ns always_comb=xxxx  always @*=xxxx
   1ns always_comb=0111  always @*=xxxx
   2ns 입력을 바꾼 뒤 always_comb=1001  always @*=1001
```

`always_comb`는 시뮬레이션 시각 0 시점에 강제 1회 초기 실행되어 입력 변화가 없는 선언 초기화 상태에서도 출력을 즉시 계산한다. 반면 `always @*`는 신호 변경 이벤트 발생 시 실행된다. 본 랩의 테스트벤치는 리셋 시퀀스를 선행 인가하므로 두 방식 모두 실제 검증 구간에서는 동일하게 동작한다.

---

## 4. SystemVerilog 확장 자료형 분석

[`ex02_enum_struct.sv`](ex02_enum_struct.sv)는 레퍼런스 모델에서 사용하는 고수준 데이터 구조를 정의한다.

### 1. `typedef enum` 열거형

```verilog
typedef enum logic [1:0] {
  IDLE     = 2'd0,
  SAW_ONE  = 2'd1,
  SAW_TWO  = 2'd2,
  SAW_MANY = 2'd3
} detect_state_t;

detect_state_t state;
```

Verilog-2001의 `localparam` 묶음과 동일한 하드웨어로 합성되며, 시뮬레이션 파형 및 로그 출력 시 `.name()` 메서드로 문자열 라벨을 직접 출력할 수 있다.

### 2. `typedef struct packed` 패킹 구조체

```verilog
typedef struct packed {
  logic [6:0] funct7;
  logic [4:0] rs2;
  logic [4:0] rs1;
  logic [2:0] funct3;
  logic [4:0] rd;
  logic [6:0] opcode;
} rv32_r_type_t;

rv32_r_type_t decoded;
decoded = raw_word;    // 32비트 버스를 구조체 필드로 즉시 매핑
```

Verilog-2001의 비트 슬라이싱(`instr[19:15]`)에 대응하며, 필드명을 명시적으로 부여하여 디코더의 가독성을 극대화한다.

---

## 5. Verilog-2001 vs SystemVerilog 1:1 종합 대조표

### 1. 자료형 및 신호 선언

| SystemVerilog | Verilog-2001 | 하드웨어 매핑 및 비고 |
|---|---|---|
| `logic` | `wire` (연속 할당) / `reg` (절차 할당) | 신호 구동 방식에 따라 컴파일러가 자동 판정 |
| `bit` | `reg` | 2치 논리(`0`, `1`), 하드웨어 모델링 전용 |
| `int` | `integer` | 32비트 부호 있는 정수형 루프 인덱스 |
| `typedef enum` | `localparam` 정의 묶음 | FSM 상태 변수 인코딩 정의 |
| `struct packed` | 비트 결합(`{}`) 및 Part-Select | 필드 단위 벡터 구조체 |

### 2. 절차 블록 및 제어문

| SystemVerilog | Verilog-2001 | 하드웨어 매핑 및 비고 |
|---|---|---|
| `always_comb` | `always @*` | 순수 조합논리 블록 |
| `always_ff @(posedge clk)` | `always @(posedge clk)` | 플립플롭 순차논리 블록 |
| `always_latch` | `always @*` (조건 누락) | 의도적 래치 블록 (지양) |
| `unique case` | `case` + `default` | 상호 배타적 병렬 선택기 |
| `priority case` | `if-else` 연쇄 | 우선순위 인코더 |

### 3. 연산자 및 시스템 구문

| SystemVerilog | Verilog-2001 | 비고 |
|---|---|---|
| `i++`, `i--`, `i += 4` | `i = i + 1`, `i = i - 1`, `i = i + 4` | 복합 대입 연산자 |
| `'0`, `'1` | `{WIDTH{1'b0}}`, `{WIDTH{1'b1}}` | 비트 폭 적응형 상수 |
| `for (int i=0; ...)` | `integer i;` 선언 후 `for (i=0; ...)` | 루프 인덱스 인라인 선언 |
| `$error(...)` | `$display` + 에러 카운터 증가 | 에러 로깅 |
| `assert (cond) else $fatal` | `if (!(cond)) $fatal(1, ...)` | 조건 검증 어설션 |

---

## 6. 통합 실습 및 검증 실행

[`overview.sv`](overview.sv) 및 [`tb_overview.sv`](tb_overview.sv)는 5대 기초 모듈(`inv4`, `add4`, `mux4`, `dff1`, `mini_alu`)의 SystemVerilog 구현 및 검증 구조를 포괄한다.

```bash
make test      # 전체 대조 예제 실행
make waves     # 통합 파형 검증
make clean
```

---

## 7. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| Verilog-2001 RTL 작성 | HW02–HW05 학생 제출 `rtl/*.v` 소스 코드 |
| SystemVerilog 테스트벤치 분석 | HW02–HW05 제공 공개 테스트벤치(`tests/*.v`) 분석 |
| `logic` vs `wire`/`reg` 매핑 | 최상위 인터페이스 포트 정합 |
| `packed struct` 필드 매핑 | HW03 `rv32i_decode.v` 및 HW04 데이터 경로 디코딩 |

---

## 8. 핵심 개념 확인 질문

1. 학생 구현 RTL 코드는 Verilog-2001을 유지하면서 테스트벤치에서 SystemVerilog를 사용하는 목적은 무엇인가?
2. SystemVerilog의 `logic` 키워드가 Verilog-2001의 `wire`와 `reg`를 통합 대체하는 동작 메커니즘은 무엇인가?
3. `always_comb`가 시각 0에서 `always @*`와 다르게 동작하는 하드웨어적 이유는 무엇인가?
4. `typedef struct packed`의 각 필드가 32비트 버스 벡터와 매핑되는 순서 규칙은 무엇인가?
5. SystemVerilog의 `'0` 상수를 Verilog-2001 표준으로 변환하는 수식을 작성하라.

---

이전 챕터: [ch09. 합성 가능 코딩](../ch09/README.md) | 부록: [빠른 참조 가이드](../appendix/README.md)
