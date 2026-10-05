# ch06. 모듈 계층 구조와 파라미터화

## 1. 학습 도달 목표

본 챕터는 다수의 서브모듈을 유기적으로 결합하여 상위 프로세서 코어를 구축하는 계층적 하드웨어 설계 기법을 확립한다. HW03 단일사이클 RV32I 코어는 HW03에서 개발한 5대 핵심 모듈을 최상위 모듈(`rv32i_core.v`)로 통합하는 과제이며, 본 챕터의 인스턴스화 규약을 토대로 완성된다.

계층 설계 핵심 불변식: 모든 모듈 인스턴스화는 포트 이름을 명시하는 이름 기반 연결(`.port_name(signal_name)`)을 전면 적용하고, 모든 중간 연결선(Wire)의 비트 폭을 명시적으로 선언한다.

본 챕터의 6대 학습 핵심:

1. 모듈 계층 구조와 중간 결합 버스(`wire`) 선언
2. 계층 경로 참조(`.`)를 활용한 테스트벤치 내부 신호 관측 기법
3. 이름 기반 포트 매핑 vs 순서 기반 포트 매핑의 신뢰성 비교
4. `generate for` 구문을 통한 규칙적 하드웨어의 파라미터화 반복 생성
5. `generate if` 구문을 통한 합성 시점 조건부 하드웨어 선택
6. 포트 미연결(Floating Input) 및 파라미터 누락 결함 방지

---

## 2. 모듈 계층 구조와 연결 신호

[`ex01_hierarchy.v`](ex01_hierarchy.v)는 1비트 가산기 4개를 묶어 4비트 덧셈기(`adder4`)를 구성하고, 이를 다시 2개 결합하여 8비트 덧셈기를 구축하는 3단 계층 설계를 실증한다.

```verilog
module adder4(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       carry_in,
  output wire [3:0] sum,
  output wire       carry_out
);

  // 내부 자리올림 신호를 벡터로 집약 선언
  wire [4:0] carry_chain;

  assign carry_chain[0] = carry_in;
  assign carry_out      = carry_chain[4];

  // 이름 기반 포트 연결로 1비트 가산기 4개 인스턴스화
  full_adder u_bit0 (.a(a[0]), .b(b[0]), .carry_in(carry_chain[0]), .sum(sum[0]), .carry_out(carry_chain[1]));
  full_adder u_bit1 (.a(a[1]), .b(b[1]), .carry_in(carry_chain[1]), .sum(sum[1]), .carry_out(carry_chain[2]));
  full_adder u_bit2 (.a(a[2]), .b(b[2]), .carry_in(carry_chain[2]), .sum(sum[2]), .carry_out(carry_chain[3]));
  full_adder u_bit3 (.a(a[3]), .b(b[3]), .carry_in(carry_chain[3]), .sum(sum[3]), .carry_out(carry_chain[4]));

endmodule
```

### 계층 설계 3대 명명 규칙

1. 인스턴스 접두어: 모든 서브모듈 인스턴스 이름에 `u_` 접두어를 부여하여 신호선과 명확히 구분한다 (`u_bit0`, `u_alu`, `u_regfile`).
2. 최상위 검증 대상 표준: 테스트벤치 내부의 DUT 인스턴스 명칭은 `dut`로 통일한다.
3. 중간 연결선 명시성: 모듈 간 데이터를 교환하는 내부 선로는 반드시 명시적 비트 폭을 갖는 `wire`로 최상단에 선언한다.

---

## 3. 계층 경로 참조 기반의 디버깅

시뮬레이션 환경에서는 점(`.`) 연산자로 하위 계층에 직접 접근하여 내부 레지스터 및 캐리 신호 상태를 프로빙한다.

```verilog
$display("dut.middle_carry           = %b", dut.middle_carry);
$display("dut.u_low.carry_chain      = %b", dut.u_low.carry_chain);
$display("dut.u_low.u_bit3.carry_out = %b", dut.u_low.u_bit3.carry_out);
```

실행 결과:

```text
--- 계층 이름으로 내부 신호를 읽는다 ---
a=0f b=01 -> sum=10 carry=0
dut.middle_carry            = 1
dut.u_low.carry_chain       = 11110
dut.u_low.u_bit3.carry_out  = 1
PASS ch06 ex01 hierarchy, 65536 vectors
```

계층 참조는 테스트벤치 검증 전용이며, RTL 합성 대상 코드 내부에서는 모듈 독립성을 위해 명시적 입출력 포트 연결만을 사용한다.

---

## 4. 이름 기반 포트 매핑 표준

[`ex02_connection.v`](ex02_connection.v)는 이름 기반 매핑과 순서 기반 매핑을 비교한다.

### 1. 이름 기반 포트 연결 (`.port(signal)`)

이름 기반 포트 연결은 모듈 정의의 포트명과 연결 신호명을 1:1로 결합하는 산업 표준 설계 방식이다.

장점:
1. 포트 순서 무관성: 신호 나열 순서가 바뀌어도 결선 무결성이 유지된다.
2. 인터페이스 변경 저항성: 서브모듈의 포트 순서가 바뀌거나 신규 포트가 추가되어도 기존 포트 매핑의 정확성이 그대로 유지된다.
3. 명시적 가독성: 코드 검토 시 어떤 내부 신호가 어떤 포트에 인가되는지 즉시 파악할 수 있다.

---

## 5. `generate for` 구문을 통한 파라미터화 인스턴스 생성

[`ex03_generate.v`](ex03_generate.v)는 `parameter`와 `generate for`를 결합하여 임의의 비트 폭 N을 지원하는 가산기를 구성한다.

```verilog
module ex03_generate #(
  parameter WIDTH = 8
)(
  input  wire [WIDTH-1:0] a,
  input  wire [WIDTH-1:0] b,
  input  wire             carry_in,
  output wire [WIDTH-1:0] sum,
  output wire             carry_out
);

  wire [WIDTH:0] carry_chain;
  assign carry_chain[0]     = carry_in;
  assign carry_out          = carry_chain[WIDTH];

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : adder_stage
      full_adder u_fa(
        .a         (a[i]),
        .b         (b[i]),
        .carry_in  (carry_chain[i]),
        .sum       (sum[i]),
        .carry_out (carry_chain[i+1])
      );
    end
  endgenerate

endmodule
```

4대 작성 원칙:

1. `genvar` 변수: 루프 인덱스는 하드웨어 신호가 아닌 합성 시점 전개 전용 변수인 `genvar`로 선언한다.
2. 명명된 블록(`: adder_stage`): `begin` 뒤에 블록 라벨을 명시하여 각 생성 하드웨어의 계층적 경로(`dut.adder_stage[0].u_fa`)를 확립한다.
3. `parameter` 연동: 루프의 경계값은 모듈 상단에 선언된 파라미터를 참조한다.

---

## 6. `generate if` 기반의 조건부 하드웨어 합성

[`ex04_generate_if.v`](ex04_generate_if.v)는 파라미터 조건에 따라 상이한 아키텍처를 선택 합성한다.

```verilog
generate
  if (USE_BARREL) begin : barrel
    assign result = value << amount;
  end else begin : staged
    wire [7:0] stage1 = amount[0] ? {value[6:0],  1'b0} : value;
    wire [7:0] stage2 = amount[1] ? {stage1[5:0], 2'b0} : stage1;
    assign result     = amount[2] ? {stage2[3:0], 4'b0} : stage2;
  end
endgenerate
```

`generate if`는 합성 시점에 조건에 부합하는 단 하나의 하드웨어 블록만 게이트 레벨로 생성하고 미선택 경로는 완전히 제거한다.

---

## 6. 계층 구조 설계 3대 결함 및 디버깅

`make errors` 실행으로 결함을 분석한다.

```bash
make errors
```

### 함정 1: 순서 기반 연결 시 포트 순서 역전 (`bad01_positional.v`)

동일한 비트 폭을 갖는 두 입력의 순서를 뒤바꿔 인스턴스화할 경우 컴파일러 경고 없이 논리적 오동작(예: $100 - 30$ 대신 $30 - 100$ 수행)이 발생한다.

### 함정 2: 입력 포트 결선 누락 (`bad02_unconnected.v`)

인스턴스화 시 특정 입력 포트를 연결하지 않으면 해당 포트에 High-Z(`z`)가 유입되어 연산 결과 전체가 미정의(`x`)로 오염된다. 컴파일러 경고(`dangling input port ... floating`)를 반드시 점검한다.

### 함정 3: 모듈 파라미터 재정의 누락 (`bad03_param.v`)

서브모듈의 파라미터(`WIDTH`)를 명시하지 않으면 기본값으로 회로가 합성되어 상위 비트가 절단되는 비트 폭 불일치 경고가 발생한다.

---

## 8. 최상위 코어 통합 5단계 표준 절차

1. 서브모듈 단위 검증: HW02 단위 검증을 완벽히 통과한 모듈들을 준비한다.
2. 중간 버스 및 제어선 선언: 최상위 모듈에 각 서브모듈 간 데이터/제어 인터페이스 선로를 폭과 함께 선언한다.
3. 이름 기반 인스턴스화: 모든 서브모듈을 이름 기반 매핑으로 결합하고 컴파일 경고를 0건으로 정합한다.
4. 통합 테스트벤치 실행: 어셈블리 명령어 시퀀스를 주입하여 전체 데이터 경로의 통합 동작을 검증한다.
5. 계층 경로 프로빙: 결함 발생 시 계층 참조를 활용하여 문제가 발생한 서브모듈의 입출력을 정밀 추적한다.

---

## 9. 챕터 전체 검증 실행

```bash
make test      # 정상 계층 예제 검증
make errors    # 결함 예제 메시지 분석
make clean
```

---

## 10. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| 이름 기반 모듈 인스턴스화 | HW03 `rtl/rv32i_core.v`의 하위 모듈 4개 연결 |
| 중간 연결선 벡터화 | HW03 `alu_src1`, `alu_src2`, `imm_ext` 버스 연결 |
| 계층적 신호 관측 | HW03, HW04 파이프라인 데이터 해저드 디버깅 |
| `parameter` 기반 모듈 구성 | HW04 5단 파이프라인 레지스터 데이터 폭 커스터마이징 |

---

## 11. 핵심 개념 확인 질문

1. 모듈 인스턴스화 시 순서 기반 매핑 대신 이름 기반 매핑을 필수 적용해야 하는 이유는 무엇인가?
2. `genvar` 변수와 일반 `integer` 신호의 근본적인 차이는 무엇인가?
3. 입력 포트가 미연결(`Floating`) 상태일 때 시뮬레이션에서 발생하는 현상은 무엇인가?
4. `generate if`와 `always @*` 내부의 `if-else`가 생성하는 하드웨어 회로의 차이점은 무엇인가?
5. 다중 모듈 최상위 통합 시 권장되는 5단계 프로세스를 기술하라.

---

이전 챕터: [ch05. 순차논리](../ch05/README.md) | 다음 챕터: [ch07. 메모리와 FSM](../ch07/README.md)
