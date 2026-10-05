# ch04. 조합논리 회로 설계

## 1. 학습 도달 목표

본 챕터는 복합 조건 분기를 갖는 조합논리 회로를 `always @*` 절차 블록으로 설계하는 기법을 확립한다. HW02의 RV32 ALU 본체와 HW03의 단일사이클 명령어 디코더가 모두 본 챕터의 표준 설계 골격에 기반한다.

조합논리 설계 불변식: 조합 블록 내의 모든 출력 신호는 모든 실행 분기 경로에서 명시적인 값을 배정받아야 한다. 이 불변식을 준수하면 순수 조합논리 회로로 합성되며, 특정 분기에서 배정이 누락될 경우 의도치 않은 래치(Latch)가 추론된다.

본 챕터의 6대 학습 핵심:

1. `always @*` 자동 감지 목록의 동작 원리
2. `case` 구문을 활용한 상호 배타적 병렬 선택 회로
3. 기본값 선행 배정(Default Value Pre-assignment) 기법
4. `if-else` 연쇄 및 `casez` 기반 우선순위 인코더 설계
5. `function` 구문을 활용한 조합논리 매크로 모듈화
6. 래치 추론 방지 및 `default` 분기 완결성 보장

---

## 2. `always @*` 조합 블록의 기본 구조

```verilog
module ex_comb(
  input  wire [7:0] in_data,
  output reg  [7:0] out_data     // 절차 블록에서 대입하므로 reg 선언
);

  always @* begin
    out_data = in_data + 8'd1;   // 블로킹 대입 (=) 적용
  end

endmodule
```

3대 필수 설계 수칙:

1. 출력 포트의 `reg` 선언: 절차 블록(`always`) 내부에서 대입을 수신하는 신호는 문법적으로 `reg`로 선언한다.
2. 자동 감지 목록(`@*`): 수식 우변에 참조되는 모든 입력 신호를 컴파일러가 자동 등록하여 감지 신호 누락에 따른 시뮬레이션 왜곡을 원천 차단한다.
3. 블로킹 대입(`=`): 조합 블록 내부에서는 기술된 순서대로 즉시 연산 결과가 반영되는 블로킹 대입문을 사용한다.

---

## 3. `case` 구문 기반의 병렬 다중화기

[`ex01_mux4.v`](ex01_mux4.v)는 4:1 멀티플렉서를 구현한다.

```verilog
module ex01_mux4(
  input  wire [7:0] in0,
  input  wire [7:0] in1,
  input  wire [7:0] in2,
  input  wire [7:0] in3,
  input  wire [1:0] sel,
  output reg  [7:0] y
);

  always @* begin
    case (sel)
      2'b00:   y = in0;
      2'b01:   y = in1;
      2'b10:   y = in2;
      default: y = in3;   // 2'b11 및 x/z 예외를 포괄하는 기본 분기
    endcase
  end

endmodule
```

```bash
make test
```

실행 결과:

```text
sel | y
----+----
 00 | aa
 01 | bb
 10 | cc
 11 | dd
sel=x0 -> y=dd  default 경로가 값을 정한다
PASS ch04 ex01 mux4
```

### `default` 분기 완결성

1. 4치 논리 예외 포괄: 선택 신호에 `x` 또는 `z`가 유입되는 과도 상태에서도 `default` 분기로 결정론적인 출력값을 보장한다.
2. 미정의 분기 래치 차단: 모든 가능한 비트 조합을 명시적으로 수용하여 래치 추론 위험을 완전히 제거한다.

`case` 구문 계열 비교:

| 구문 형식 | 패턴 매칭 규칙 | 주요 적용 분야 |
|---|---|---|
| `case` | 모든 비트의 정확한 일치 판정 | 일반 명령어 디코더 및 ALU 연산 코드 분기 |
| `casez` | `?` 및 `z` 비트를 Don't-Care로 처리 | 우선순위 인코더 및 비트 마스크 디코딩 |
| `casex` | `x`까지 Don't-Care로 처리 | 시뮬레이션/합성 불일치를 유발하므로 사용을 금지 |

---

## 4. 기본값 선행 배정 기법

[`ex02_default.v`](ex02_default.v)는 복수 출력 제어 블록을 설계하는 두 방식을 비교한다.

```verilog
// 권장 표준: 기본값 선행 배정 구조
always @* begin
  // 1. 모든 출력 신호에 안전 기본값을 선행 배정
  alu_select   = 2'b00;
  write_enable = 1'b0;
  memory_read  = 1'b0;
  illegal      = 1'b0;

  // 2. 해당 명령어 분기에서 필요한 제어 신호만 활성화
  case (opcode)
    4'h1: begin alu_select = 2'b00; write_enable = 1'b1;                     end
    4'h2: begin alu_select = 2'b01; write_enable = 1'b1;                     end
    4'h3: begin alu_select = 2'b10; write_enable = 1'b1; memory_read = 1'b1; end
    4'h4: begin                     write_enable = 1'b1;                     end
    default: illegal = 1'b1;
  endcase
end
```

기본값을 블록 최상단에 선행 배정하면 분기별로 특정 신호의 대입이 생략되더라도 기본값이 유지되므로 래치 발생이 원천 차단된다. 이는 HW02 `rv32i_decode.v`의 표준 코딩 규약이다.

---

## 5. 우선순위 인코더 설계

여러 요청 신호가 동시 활성화될 때 우선순위에 따라 단일 대상을 선택하는 [`ex03_priority.v`](ex03_priority.v)를 분석한다.

```verilog
// 방식 1: if-else 연쇄 기반 우선순위 구조
always @* begin
  granted_index = 2'd0;
  any_granted   = 1'b1;

  if (request[0])
    granted_index = 2'd0;
  else if (request[1])
    granted_index = 2'd1;
  else if (request[2])
    granted_index = 2'd2;
  else if (request[3])
    granted_index = 2'd3;
  else
    any_granted = 1'b0;
end

// 방식 2: casez 기반 병렬 마스크 구조
always @* begin
  granted_index = 2'd0;
  any_granted   = 1'b1;

  casez (request)
    4'b???1: granted_index = 2'd0;
    4'b??10: granted_index = 2'd1;
    4'b?100: granted_index = 2'd2;
    4'b1000: granted_index = 2'd3;
    default: any_granted   = 1'b0;
  endcase
end
```

`if-else` 연쇄의 선행 조건이 우선 선택되는 구조는 HW04 파이프라인 포워딩 우선순위(EX/MEM > MEM/WB) 구현의 핵심 토대다.

---

## 6. `function`을 활용한 조합논리 매크로화

[`ex04_function.v`](ex04_function.v)는 반복 사용되는 조합논리를 함수로 캡슐화한다.

```verilog
function [31:0] pick_larger_signed;
  input [31:0] left;
  input [31:0] right;
  begin
    pick_larger_signed = ($signed(left) > $signed(right)) ? left : right;
  end
endfunction

assign max_signed = pick_larger_signed(a, b);
```

`function` 규약:

1. 시간 지연 구문(`#`, `@`)을 배제하여 0-지연 순수 조합논리로 합성한다.
2. 내부 상수 반복문(`for`)은 합성 시 병렬 하드웨어 게이트로 전개(Unroll)된다.

---

## 7. 조합 블록 3대 결함 및 래치 추론 분석

`make errors` 실행으로 3대 함정을 분석한다.

```bash
make errors
```

### 함정 1: 조건 분기 누락에 따른 래치 추론 (`bad01_latch.v`)

```verilog
always @* begin
  if (sel)
    y = in1;
  // sel=0 분기 누락: 이전 상태를 유지하기 위해 투명 래치가 자동 생성됨
end
```

특정 조건에서 신호 배정이 누락되면 하드웨어는 이전 값을 유지하는 기억 소자(Latch)를 추론한다. 이는 글리치(Glitch) 및 타이밍 결함의 원인이 된다. 기본값 선행 배정으로 래치 생성을 차단한다.

### 함정 2: `case` 분기 미완결 (`bad02_incomplete_case.v`)

`case` 문에서 일부 비트 패턴과 `default` 분기를 동시에 생략할 때 발생한다.

### 함정 3: 수동 감지 목록 누락 (`bad03_sensitivity.v`)

`always @(a)`처럼 입력 신호 `b`를 감지 목록에서 누락하면 시뮬레이터는 `b` 변화 시 재계산을 건너뛰고 이전 값을 유지한다. 반면 합성기는 완전한 회로를 생성하므로 시뮬레이션과 실제 회로 간의 불일치가 발생한다. 상시 `always @*`를 적용한다.

---

## 8. 조합논리 RTL 5대 자가 점검 체크리스트

1. 모든 출력 포트 및 내부 절차 대입 신호가 `reg`로 선언되었는가?
2. 감지 목록이 `always @*`로 기술되었는가?
3. 절차 대입에 블로킹 대입자(`=`)를 사용하였는가?
4. 절차 블록 최상단에 모든 출력의 기본값을 선행 배정하였는가?
5. 모든 `case` 문에 `default` 분기가 명시되어 있는가?

---

## 9. 챕터 전체 검증 실행

```bash
make test      # 정상 예제 검증
make errors    # 결함 예제 메시지 분석
make clean
```

---

## 10. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| `always @*` 및 블로킹 대입 | HW02 `rtl/alu.v` 연산기 |
| 기본값 선행 배정 구조 | HW02 ALU 출력 및 HW02 `rtl/rv32i_decode.v` 제어 디코더 |
| `case` 완결성 및 `default` | HW02 연산 코드 매핑, HW02 명령어 분기 |
| `if-else` 우선순위 인코딩 | HW04 포워딩 경로 선택 및 Load-Use 인터록 판정 |
| 래치 추론 없는 완전 조합논리 | 과제 무결성 검증 및 채점 기준 |

---

## 11. 핵심 개념 확인 질문

1. `always @*` 블록에서 출력 신호를 `reg`로 선언해야 하는 문법적 이유는 무엇인가?
2. 기본값 선행 배정 기법이 래치 추론을 원천 방지하는 하드웨어적 메커니즘은 무엇인가?
3. `casez`와 `case`의 비교 동작 차이는 무엇인가?
4. 수동 감지 목록 `always @(a)`에서 발생할 수 있는 시뮬레이션-합성 불일치 현상은 무엇인가?
5. 조합논리 5대 점검 체크리스트 항목을 열거하라.

---

이전 챕터: [ch03. 연산자와 비트 폭 규칙](../ch03/README.md) | 다음 챕터: [ch05. 순차논리](../ch05/README.md)
