# 부록. Verilog HDL 빠른 참조 가이드(Quick Reference)

본 가이드는 하드웨어 과제 구현 및 디버깅 과정에서 즉시 참조할 수 있도록 문법, 규칙, 점검표, 에러 코드를 집약한 빠른 참조 매뉴얼이다.

---

## 1. 표준 실행 명령어 체계

### 튜토리얼 챕터별 검증 명령

```bash
make test          # 10개 챕터 전체 예제 일괄 검증
make chapters      # 챕터별 기본 회로 예제 검증
make errors        # 챕터별 결함 함정 예제 실행
make clean         # 빌드 산출물 초기화

cd ch03 && make test      # 개별 챕터 검증 실행
cd ch03 && make errors    # 개별 챕터 결함 분석
```

### Icarus Verilog 직접 컴파일 및 시뮬레이션

```bash
iverilog -g2012 -Wall -s <최상위모듈> -o build/out.vvp <소스파일목록...>
vvp build/out.vvp
echo $?            # 0: 정상 통과, 1: $fatal 에러 종료
```

### 과제별 검증 및 릴리스 아티팩트 생성

```bash
cd assignments/hw02
make setup-check   # 개발 환경 툴체인 적합성 검사
make test          # 공개 테스트벤치 일괄 실행
make student-test  # 학생 구현 확장 테스트벤치 실행
make evidence      # 채점 제출용 VCD/CSV 증거 패키징
make clean
```

---

## 2. 자료형 선언 및 신호 분류 규칙 (ch02)

```verilog
wire        single_net;                // 1비트 연속 할당 신호 (assign 구동)
wire [31:0] bus_data;                  // 32비트 버스 신호
reg  [31:0] state_reg;                 // 절차 블록(always/initial) 대입 신호
reg  [31:0] memory_array [0:255];      // 32비트 데이터 폭 x 256개 엔트리 2차원 배열
integer     loop_idx;                  // 테스트벤치 전용 32비트 정수 루프 변수
genvar      g_idx;                     // 하드웨어 반복 생성(generate) 전용 인덱스
parameter   WIDTH = 32;                // 모듈 외부 재정의 가능 파라미터
localparam  DEPTH = 1 << 8;            // 모듈 내부 상수 (외부 수정 불가)
```

| 신호 구동 원천 (Driver Source) | 선언 자료형 (Data Type) |
|---|---|
| `assign` 연속 대입문 좌변 | `wire` |
| 하위 모듈 인스턴스의 출력 포트 수신선 | `wire` |
| `always` 조합/순차 절차 블록 내부 대입 | `reg` |
| `initial` 테스트 절차 블록 내부 대입 | `reg` |

---

## 3. 정수 리터럴 및 비트 상수 표기법 (ch02)

```verilog
4'b1010          // 4비트 2진수 (10진수 10)
8'o377           // 8비트 8진수 (10진수 255)
8'd255           // 8비트 10진수
32'hdead_beef    // 32비트 16진수 (가독성 향상 언더스코어 적용)
{8{1'b1}}        // 8비트 전체를 1로 채움 (8'hff)
{WIDTH{1'b0}}    // 파라미터화된 비트 폭 전체를 0으로 채움
```

| 논리 상태값 | 하드웨어적 상태 의미 |
|---|---|
| `0`, `1` | 확정된 논리 Low / High 레벨 |
| `x` | 미확정, 미정의, 경쟁(Contention) 충돌 상태 |
| `z` | 고임피던스(High-Z), 플로팅, 비구동 단자 상태 |

---

## 4. 비트 조작 및 결합 연산 (ch02)

```verilog
instr[31]                        // 단일 비트 추출 (Bit-Select)
instr[19:15]                     // 고정 범위 비트 슬라이싱 (Part-Select, 상수 인덱스)
data[idx*8 +: 8]                 // 가변 시작 위치 기반 8비트 슬라이싱 (Indexed Part-Select)
{a, b}                           // 비트 결합 연산 (Concatenation)
{20{sign_bit}}                   // 비트 복제 연산 (Replication)
{{20{instr[31]}}, instr[31:20]}  // 12비트 즉치수의 32비트 부호 확장 (Sign-Extension)
{20'b0, instr[31:20]}            // 12비트 즉치수의 32비트 0 확장 (Zero-Extension)
{1'b0, a} + {1'b0, b}            // 최상위 캐리를 보존하는 33비트 덧셈
```

---

## 5. 하드웨어 연산자 우선순위 체계 (ch03)

| 우선순위 | 연산자 범주 | 연산 기호 |
|---|---|---|
| 1 (최고) | 단항 및 Reduction | `~`, `!`, `+`, `-`, `&`, `~&`, `\|`, `~\|`, `^`, `~^` |
| 2 | 승제산 | `*`, `/`, `%` |
| 3 | 가감산 | `+`, `-` |
| 4 | 시프트 | `<<`, `>>`, `<<<`, `>>>` |
| 5 | 관계 비교 | `<`, `<=`, `>`, `>=` |
| 6 | 등가 비교 | `==`, `!=`, `===`, `!==` |
| 7 | 비트 AND | `&` |
| 8 | 비트 XOR/XNOR | `^`, `~^` |
| 9 | 비트 OR | `\|` |
| 10 | 논리 AND | `&&` |
| 11 | 논리 OR | `\|\|` |
| 12 (최저) | 조건 삼항 연산자 | `? :` |

산술 연산과 논리/비트 연산이 복합 적용될 때는 항상 명시적 괄호를 사용하여 모호성을 제거한다.

---

## 6. 비트 폭 확장 5대 규칙 (ch03)

| 연산 상황 | 권장 설계 패턴 |
|---|---|
| Carry 비트 보존 | 피연산자에 `{1'b0, x}`를 결합하여 N+1 비트 문맥을 강제 |
| 정수 상수 사용 | 상수의 비트 폭을 상시 명시 (`32'd1`, `4'b0001`) |
| 복합 중간 수식 | 명시적 폭을 갖는 중간 `wire` 신호로 수식을 분할 |
| Signed 연산 수행 | 비교/시프트 연산 대상 양측 피연산자 모두에 `$signed` 명시 |

수식의 전체 연산 폭은 좌변 신호 폭과 우변 피연산자 폭 중 최댓값으로 결정된다.

---

## 7. 부호 해석 및 시프트 연산 (ch03)

```verilog
$signed(a) < $signed(b)      // Signed 대소 비교: 양측 모두 캐스팅 필수
$signed(value) >>> shamt     // 산술 우측 시프트: 부호 비트 복제 확장
value >> shamt               // 논리 우측 시프트: 최상위 0 채움
value << shamt               // 논리 좌측 시프트
b[4:0]                       // RV32I 시프트 양은 하위 5비트(0~31)로 한정
```

---

## 8. ALU 4대 상태 플래그 도출 수식 (ch03)

```verilog
wire [32:0] wide_sum = {1'b0, a} + {1'b0, b};

assign sum      = wide_sum[31:0];
assign carry    = wide_sum[32];                                           // Unsigned 자리올림
assign zero     = ~|sum;                                                  // 32비트 0 판정 (Reduction NOR)
assign negative = sum[31];                                                // 최상위 부호 비트
assign overflow = (a[31] == b[31]) && (sum[31] != a[31]);                 // Signed 덧셈 오버플로
// 뺄셈 오버플로: (a[31] != b[31]) && (sum[31] != a[31])
```

---

## 9. 조합논리 5대 점검 체크리스트 (ch04)

```verilog
always @* begin
  // 1. 모든 출력에 기본값을 선행 배정
  out_a = 1'b0;
  out_b = 2'b00;

  // 2. 분기별 활성화 제어
  case (sel)
    2'b00: out_a = 1'b1;
    2'b01: out_b = 2'b11;
    default: ;
  endcase
end
```

1. 출력 신호가 `reg`로 선언되었는가?
2. 감지 목록이 `always @*`로 기술되었는가?
3. 절차 대입에 블로킹 대입자(`=`)를 사용하였는가?
4. 절차 블록 최상단에 모든 출력의 기본값이 선행 배정되었는가?
5. 모든 `case` 문에 `default` 분기가 존재하는가?

---

## 10. 순차논리 6대 점검 체크리스트 (ch05)

```verilog
always @(posedge clk) begin
  if (reset)
    state <= 32'h0;
  else if (load)
    state <= load_val;
  else if (enable)
    state <= state + 32'd4;
  // 조건 미충족 시 이전 상태를 자동 유지 (플립플롭 정상 동작)
end
```

1. 상태 신호가 `reg`로 선언되었는가?
2. 감지 목록이 `always @(posedge clk)`로 기술되었는가?
3. 모든 상태 갱신에 논블로킹 대입자(`<=`)를 사용하였는가?
4. 각 상태 신호가 단 하나의 `always` 블록에서만 대입되는가?
5. 제어 우선순위(`reset > load > enable`)가 명세와 일치하는가?
6. 전체 리셋 방식이 동기 리셋으로 통일되어 있는가?

---

## 11. 계층화 및 모듈 결합 규칙 (ch06)

```verilog
wire [4:0] carry_chain;                  // 중간 연결 신호 폭 명시 선언

// 이름 기반 매핑 인스턴스화
full_adder u_bit0 (
  .a         (a[0]),
  .b         (b[0]),
  .carry_in  (carry_chain[0]),
  .sum       (sum[0]),
  .carry_out (carry_chain[1])
);

adder #(.WIDTH(32)) u_add32 (...);       // 파라미터 오버라이딩

genvar i;
generate
  for (i = 0; i < WIDTH; i = i + 1) begin : stage
    full_adder u_fa (...);
  end
endgenerate
```

---

## 12. 2-블록 FSM 표준 아키텍처 (ch07)

```verilog
localparam [1:0] IDLE = 2'd0, RUN = 2'd1, DONE = 2'd2;
reg [1:0] state, next_state;

// 블록 1: 상태 전이 순차논리 (동기 리셋)
always @(posedge clk) begin
  if (reset) state <= IDLE;
  else       state <= next_state;
end

// 블록 2: 차기 상태 및 출력 결정 조합논리
always @* begin
  next_state  = state;
  output_flag = 1'b0;
  case (state)
    IDLE: if (start) next_state = RUN;
    RUN:  if (done)  next_state = DONE;
    DONE: begin output_flag = 1'b1; next_state = IDLE; end
    default: next_state = IDLE;
  endcase
end
```

---

## 13. 자체 검증 테스트벤치 템플릿 (ch08)

```verilog
module tb_target;
  reg         clk = 1'b0;                // 1'b0으로 명시적 초기화
  reg  [31:0] in_data;
  wire [31:0] out_data;

  target dut (.a(in_data), .y(out_data));

  always #5 clk = ~clk;                  // 100MHz 클록 생성

  task check;
    input [31:0]     expected;
    input [8*32-1:0] label;
    begin
      if (out_data !== expected)
        $fatal(1, "FAIL [%0s] actual=%h (expected=%h)", label, out_data, expected);
    end
  endtask

  initial begin
    $timeformat(-9, 0, "ns", 6);
    $dumpfile("build/target.vcd");
    $dumpvars(0, tb_target);

    // 클록 에지 직후 1ns 대기 후 검증 수행
    @(posedge clk); #1;
    check(32'h0000_0000, "리셋 검증");

    $display("PASS tb_target");
    $finish(0);
  end

  initial begin                          // 무한 루프 차단 타임아웃
    #100000;
    $fatal(1, "FAIL 시뮬레이션 타임아웃");
  end
endmodule
```

---

## 14. 대표적 컴파일 에러 및 조치 방안 (ch01)

| 에러 메시지 패턴 | 발생 원인 및 해결 조치 |
|---|---|
| `syntax error` | 세미콜론 누락, 괄호 짝 불일치, `begin-end` 누락 |
| `Unknown module type` | 모듈명 오타 또는 컴파일 명령어에 소스 파일 누락 |
| `port ... is not a port of ...` | 인스턴스화 포트명 오타 또는 인터페이스 불일치 |
| `expects N bit(s), given M` | 포트와 연결 신호 간 비트 폭 불일치 |
| `is not a valid l-value` | `always` 절차 블록 대입 신호의 `reg` 선언 누락 |
| `dangling input port ... floating` | 모듈 인스턴스의 입력 포트 결선 누락 |
| `also continuously assigned` | 동일한 신호를 복수 경로에서 중복 구동 |

---

## 15. 결함 증상별 디버깅 가이드

| 관측 증상 | 1차 점검 대상 및 조치 |
|---|---|
| 파형에 `x`가 광범위하게 전파됨 | 입력 포트 미연결, 조합 블록 기본값 누락, 배열 범위 초과 |
| 검증 데이터가 1사이클 지연됨 | 테스트벤치 에지 대기 직후 `#1` 지연 누락 여부 확인 |
| 상위 캐리 비트가 0으로 잘림 | 덧셈 연산 문맥 폭 확장(`{1'b0, a}`) 적용 여부 확인 |
| 음수 연산만 오작동함 | `$signed` 캐스팅 누락 여부 확인 |
| 특정 조건에서 이전 출력이 래치됨 | 조합 블록의 `if-else` 분기 누락 또는 `case`의 `default` 누락 |
| 시뮬레이션 무한 대기 상태 지속 | 무한 루프 검증 및 안전 타임아웃 블록 추가 |

---

## 16. 전체 챕터 목차

| 챕터 | 핵심 학습 내용 |
|---|---|
| [ch01](../ch01/README.md) | Icarus Verilog 도구 사용법, 포트 선언, `assign`, 컴파일 에러 분석 |
| [ch02](../ch02/README.md) | 리터럴, 4치 논리(`x`, `z`), `wire` vs `reg`, 부호 확장 |
| [ch03](../ch03/README.md) | 5대 비트 폭 확장 규칙, Signed 해석, 3종 시프트, ALU 플래그 |
| [ch04](../ch04/README.md) | `always @*`, 기본값 선행 배정, 우선순위 인코더, 래치 추론 방지 |
| [ch05](../ch05/README.md) | `always @(posedge clk)`, 논블로킹 대입(`<=`), 동기 리셋 |
| [ch06](../ch06/README.md) | 이름 기반 계층 인스턴스화, 계층 신호 참조, `generate` |
| [ch07](../ch07/README.md) | 2차원 레지스터 배열, 조합/동기 읽기, 2-블록 FSM |
| [ch08](../ch08/README.md) | 7단 자체 검증 테스트벤치, 6대 경계값, 의사 난수 검증, VCD/CSV |
| [ch09](../ch09/README.md) | RTL 합성 가능 부분집합, 27대 자가 점검 체크리스트 |
| [ch10](../ch10/README.md) | Verilog-2001 vs SystemVerilog 1:1 대조 및 호환성 |
