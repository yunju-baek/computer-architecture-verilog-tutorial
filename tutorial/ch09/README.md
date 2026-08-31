# ch09. RTL 합성 가능 코딩 규칙(Synthesizable Verilog Guidelines)

## 1. 학습 도달 목표

본 챕터는 시뮬레이션 전용 문법과 실제 실리콘/FPGA 하드웨어 게이트로 변환 가능한 RTL 합성 가능 부분집합(Synthesizable Subsets)의 명확한 경계를 확립한다. 본 과제형 랩의 모든 하드웨어 모듈(`rtl/*.v`)은 산업 표준 하드웨어 합성 규칙을 100% 준수하여 구현한다.

합성 가능 설계 3대 기본 원칙:

1. 시간 지연(`#`) 및 `initial` 블록은 테스트벤치(`tests/*.v`) 전용으로 엄격히 격리한다.
2. RTL 내부의 모든 상태 초기화는 전원 인가 직후 동작하는 동기 리셋(`reset`) 신호로 통제한다.
3. 반복문은 합성 시점에 물리적 게이트로 전개 가능한 상수 범위의 `for` 루프만을 사용한다.

본 챕터의 5대 학습 핵심:

1. 합성 가능 Verilog-2001 문법 표준 목록
2. 시뮬레이션 전용 비합성 문법 요소와 대체 하드웨어 설계법
3. 동일 시뮬레이션 결과 대비 합성 불가 코드의 구조적 결함 분석
4. 하드웨어 나눗셈 연산자(`/`, `%`)의 비트 시프트 대체 기법
5. 27개 항목으로 구성된 과제 제출 전 RTL 무결성 자가 점검표

---

## 2. RTL 합성 가능 부분집합(Synthesizable Subset)

[`ex01_synthesizable.v`](ex01_synthesizable.v)는 표준 합성을 지원하는 핵심 문법 요소를 종합 구현한다.

```verilog
module ex01_synthesizable #(
  parameter WIDTH = 8
)(
  input  wire             clk,
  input  wire             reset,
  input  wire             enable,
  input  wire [1:0]       operation,
  input  wire [WIDTH-1:0] operand,
  output reg  [WIDTH-1:0] result,
  output wire             is_zero
);

  localparam [1:0] OP_ADD = 2'd0, OP_SUB = 2'd1, OP_AND = 2'd2, OP_OR = 2'd3;

  reg [WIDTH-1:0] next_result;

  // 조합논리 블록: 블로킹 대입 (=) 및 기본값 선행 배정
  always @* begin
    next_result = result;
    case (operation)
      OP_ADD:  next_result = result + operand;
      OP_SUB:  next_result = result - operand;
      OP_AND:  next_result = result & operand;
      default: next_result = result | operand;
    endcase
  end

  // 순차논리 블록: 논블로킹 대입 (<=) 및 동기 리셋
  always @(posedge clk) begin
    if (reset)
      result <= {WIDTH{1'b0}};
    else if (enable)
      result <= next_result;
  end

  assign is_zero = ~|result;

endmodule
```

실행 결과:

```text
add 30 -> result=30 is_zero=0
add 05 -> result=35 is_zero=0
sub 05 -> result=30 is_zero=0
and 0f -> result=00 is_zero=1
or ab -> result=ab is_zero=0
PASS ch09 ex01 합성 가능 구조
```

### 합성 불가 문법 요소 및 표준 대체 기법

| 비합성 문법 요소 | 주 사용처 | RTL 설계 시 표준 대체 기법 |
|---|---|---|
| `initial` 블록 | 시뮬레이션 초기화 | `always @(posedge clk)` 내 동기 리셋 분기 |
| 지연문 (`#10`) | 테스트 타이밍 제어 | 클록 신호 및 플립플롭 상태 전이 |
| `$display`, `$finish` | 콘솔 로깅/종료 | 테스트벤치 파일(`tests/`)로 전면 이관 |
| `$readmemh` (RTL 내) | 메모리 초기화 | FPGA BRAM 전용 속성 또는 동기 쓰기 인터페이스 |
| `task` | 절차적 테스트 루틴 | 조합논리 `function` 또는 순차 FSM |
| 4치 비교 (`===`, `!==`) | `x`/`z` 포함 비교 | 2치 하드웨어 비교자 (`==`, `!=`) |
| 가변 `while`, `repeat` | 소프트웨어 루프 | 고정 상수 `for` 루프 전개 또는 다중 사이클 FSM |
| 변수 나눗셈 (`/`, `%`) | 수학 나눗셈 | 배럴 시프터(`>>`, `&`) 또는 전용 나눗셈기 IP |

---

## 3. 시뮬레이션 동일성과 합성 가능성의 괴리 분석

[`ex02_compare.v`](ex02_compare.v)는 동일한 시뮬레이션 동작을 보이는 두 모듈의 하드웨어 적합성을 비교한다.

```verilog
// 1. 완벽한 합성 가능 카운터
module counter_synthesizable (
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  always @(posedge clk) begin
    if (reset) count <= 4'd0;
    else       count <= count + 4'd1;
  end
endmodule

// 2. 비합성 시뮬레이션 전용 카운터 (RTL 사용 금지)
module counter_simulation_only (
  input  wire       clk,
  input  wire       reset,
  output reg  [3:0] count
);
  initial count = 4'd0;        // 실리콘 플립플롭 초기 상태 보장 불가

  always @(posedge clk) begin
    #1;                        // 합성 도구가 지연값을 무시하여 타이밍 불일치 발생
    if (reset) count = 4'd0;   // 블로킹 대입 사용으로 다단 회로 왜곡 위험
    else       count = count + 4'd1;
  end
endmodule
```

시뮬레이션 파형이 일치하더라도 `initial`, `#1`, `=`가 포함된 코드는 실제 하드웨어 합성 시 게이트 생성 실패 또는 타이밍 결함을 유발한다.

---

## 4. 하드웨어 나눗셈 연산자 최적화

[`bad03_division.v`](bad03_division.v)는 나눗셈 연산자의 하드웨어적 비용을 실증한다.

```verilog
// 1. 임의 변수 나눗셈: 대규모 다단 뺄셈기 회로가 합성되어 면적 및 지연 급증
assign by_variable = value / divisor;

// 2. 2의 거듭제곱(2^N) 나눗셈: 배선 재배치(Shift)로 0-지연 하드웨어 구현
assign by_power_of_two = value >> 4;       // value / 16과 동일

// 3. 2의 거듭제곱 나머지: 비트 마스크(AND)로 1단 게이트 구현
assign mod_power = value & 16'h000f;       // value % 16과 동일
```

프로세서의 캐시 주소 태그/인덱스/오프셋 분해(HW05)는 블록 크기가 2의 거듭제곱이므로 비트 슬라이싱(`addr[9:4]`)과 마스크로 0-비용 하드웨어를 구현한다.

---

## 5. RTL 27대 자가 점검 체크리스트

과제 제출 전 다음 27개 불변식을 검증한다.

### 1. 신호 선언 및 자료형
1. `assign` 구동 신호가 `wire`로 선언되었는가?
2. 절차 블록 대입 신호가 `reg`로 선언되었는가?
3. 중간 연결 버스의 비트 폭이 명시적으로 선언되었는가?
4. 모든 정수 상수에 비트 폭이 표기되었는가 (`32'h0000_0000`)?

### 2. 조합논리 회로
5. 감지 목록이 `always @*`로 기술되었는가?
6. 절차 대입에 블로킹 대입자(`=`)를 사용하였는가?
7. 절차 블록 최상단에 모든 출력의 기본값이 선행 배정되었는가?
8. 모든 `case` 문에 `default` 분기가 명시되었는가?
9. `casex` 대신 `case` 또는 `casez`를 사용하였는가?

### 3. 순차논리 회로
10. 감지 목록이 `always @(posedge clk)`로 기술되었는가?
11. 모든 상태 갱신에 논블로킹 대입자(`<=`)를 사용하였는가?
12. 각 상태 신호는 물리적으로 단 하나의 `always` 블록에서만 대입되는가?
13. `reset > load > enable` 우선순위가 명세와 일치하는가?
14. 전체 리셋 방식이 동기 리셋으로 통일되었는가?

### 4. 비트 폭 및 부호 처리
15. 덧셈 Carry 보존을 위해 33비트 연산 문맥을 적용하였는가?
16. Signed 비교 대상 양측 피연산자 모두에 `$signed`를 명시하였는가?
17. 산술 우측 시프트(`>>>`) 좌변에 `$signed`를 캐스팅하였는가?
18. 부호 확장과 0 확장을 올바르게 적용하였는가?

### 5. 모듈 계층화
19. 모든 서브모듈을 이름 기반 매핑(`.port(signal)`)으로 인스턴스화하였는가?
20. 미연결된 플로팅 입력 포트가 없는가?
21. 파라미터화 모듈 호출 시 `#(.PARAM(val))`로 재정의하였는가?

### 6. 합성 경계 준수
22. RTL 내부에서 시간 지연 구문(`#`)을 전면 배제하였는가?
23. RTL 내부에서 `initial` 초기화 대신 `reset`을 사용하였는가?
24. `$display` 계열 시스템 태스크를 테스트벤치로 전면 이관하였는가?
25. 내부 `for` 루프의 반복 경계가 상수로 확정되어 있는가?
26. 계층 경로 참조(`.`)를 테스트벤치 전용으로 한정하였는가?

### 7. 컴파일러 경고 검증
27. `iverilog -g2012 -Wall` 컴파일 시 경고(Warning)가 0건인가?

---

## 6. 챕터 전체 검증 실행

```bash
make test      # 합성 가능 예제 검증
make errors    # 비합성 결함 예제 분석
make clean
```

---

## 7. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| RTL 디렉터리 분리 규칙 | `rtl/` (합성 가능) vs `tests/` (시뮬레이션 전용) |
| 시프트 기반 고속 연산 | HW02 ALU 및 HW05 캐시 주소 계산기 |
| 27대 자가 점검 체크리스트 | HW02–HW05 전 과제 최종 제출 전 필수 감사 |
| 무경고 컴파일 표준 | CI/CD 자동 채점 파이프라인 통과 불변식 |

---

## 8. 핵심 개념 확인 질문

1. RTL 설계 코드에서 `initial` 블록을 배제하고 동기 리셋을 사용해야 하는 하드웨어적 이유는 무엇인가?
2. 합성 도구가 시간 지연 구문(`#3`)을 만났을 때 처리하는 방식과 그에 따른 부작용은 무엇인가?
3. `for` 루프가 하드웨어로 합성되기 위해 만족해야 하는 문법적 전제 조건은 무엇인가?
4. `value / 16`을 `value >> 4`로 대체할 수 있는 Unsigned 연산의 수학적 근거는 무엇인가?
5. `iverilog -g2012 -Wall` 명령어가 검출하는 대표적인 3대 잠재 결함은 무엇인가?

---

이전 챕터: [ch08. testbench 작성법](../ch08/README.md)
