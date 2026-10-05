# ch08. 자체 검증 테스트벤치(Self-Checking Testbench) 설계

## 1. 학습 도달 목표

본 챕터는 하드웨어 검증을 자동화하고 결함을 신속히 식별하는 자체 검증 테스트벤치(Self-Checking Testbench)의 표준 아키텍처를 확립한다. HW02부터 HW05까지 모든 평가 과제는 공개 테스트벤치 통과와 더불어 학생이 직접 작성한 확장 테스트벤치의 검증 완성도를 주요 평가 지표로 반영한다.

테스트벤치 핵심 불변식: 모든 검증 시나리오는 `$display`에 의한 육안 확인을 배제하고, 반드시 기대값 비교 조건문과 `$fatal` 시스템 태스크를 결합하여 자동화된 PASS/FAIL 판정을 보장한다.

본 챕터의 6대 학습 핵심:

1. 자체 검증 테스트벤치 7단 표준 골격 구성
2. 즉시 중단(Fail-Fast) vs 누적 집계(Error-Counting) 검증 전략
3. 32비트 아키텍처 6대 경계값(Boundary Case) 선정 기준
4. 참조 모델(Reference Model) 및 고정 시드(Seed) 기반 의사 난수 검증
5. VCD 파형 덤프 및 CSV 트레이스 로깅 기법
6. 타이밍 레이스 컨디션 방지 및 시뮬레이션 타임아웃 안전장치

---

## 2. 테스트벤치 7단 표준 아키텍처

[`tb_ex01.v`](tb_ex01.v)는 16비트 누적기(`ex01_dut.v`)를 검증하는 표준 7단 구조를 실증한다.

```verilog
`timescale 1ns / 1ps

module tb_ex01;

  // 1. 신호 선언: DUT 입력은 reg, DUT 출력은 wire
  reg         clk = 1'b0;      // 0으로 명시적 초기화하여 무한 x 락 차단
  reg         reset;
  reg         enable;
  reg  [15:0] addend;
  wire [15:0] total;
  wire        zero, carry;

  // 2. 파라미터 상수화: 반주기 5ns (100MHz 동작 모델링)
  localparam CLOCK_HALF = 5;

  // 3. DUT 인스턴스화: 이름 기반 매핑 적용
  ex01_dut dut (
    .clk    (clk),
    .reset  (reset),
    .enable (enable),
    .addend (addend),
    .total  (total),
    .zero   (zero),
    .carry  (carry)
  );

  // 4. 클록 생성기
  always #CLOCK_HALF clk = ~clk;

  // 5. 검증 태스크(Task) 모듈화: @(posedge clk) 직후 #1 지연으로 안정 샘플링
  task apply_reset;
    begin
      reset  = 1'b1;
      enable = 1'b0;
      addend = 16'h0000;
      @(posedge clk);
      #1;
      reset = 1'b0;
    end
  endtask

  task check_total;
    input [15:0]     expected;
    input [8*32-1:0] label;
    begin
      if (total !== expected)
        $fatal(1, "FAIL [%0s] total=%h (expected=%h)", label, total, expected);
    end
  endtask

  // 6. 메인 검증 시나리오
  initial begin
    $timeformat(-9, 0, "ns", 6);

    apply_reset;
    check_total(16'h0000, "리셋 직후");

    // 시나리오 실행...

    $display("PASS ch08 ex01 골격");
    $finish(0);
  end

  // 7. 시뮬레이션 무한 루프 차단 안전 타임아웃
  initial begin
    #10000;
    $fatal(1, "FAIL 시뮬레이션 제한 시간 초과");
  end

endmodule
```

### 7대 구성 요소 분석

1. 신호 선언: DUT 입력에 인가하는 신호는 절차 블록에서 제어하므로 `reg`로 선언하고 `clk = 1'b0`으로 초기화한다.
2. 클록 주기 파라미터화: `CLOCK_HALF` 상수를 선언하여 주파수 변경 시 단일 위치 수정을 보장한다.
3. 이름 기반 DUT 결합: `.port(signal)` 표기로 포트 오결선을 차단한다.
4. 자동 클록 토글: `always #CLOCK_HALF clk = ~clk;`로 대칭 구형파를 생성한다.
5. `task` 기반 검증 절차화: 시간 지연(`#`, `@`)을 수반하는 재사용 루틴을 `task`로 캡슐화한다.
6. 자체 검증 시나리오: 자가 판정 로직으로 실행 후 `PASS` 메시지와 함께 정상 종료한다.
7. 타임아웃 안전장치: 하드웨어 데드락 발생 시 시뮬레이션을 강제 종료하여 무한 정지를 방지한다.

---

## 3. 실패 처리 2대 전략 (즉시 중단 vs 누적 집계)

[`tb_ex02.v`](tb_ex02.v)는 두 검증 모드를 제공한다.

### 전략 1: 즉시 중단 (Fail-Fast)

첫 번째 불일치 발생 시 즉시 `$fatal`로 시뮬레이션을 정지한다. 단일 결함의 원인을 파형 분석으로 집중 추적할 때 적용한다.

### 전략 2: 누적 집계 (Error-Counting)

불일치를 카운터에 기록하고 전체 테스트를 완료한 후 최종 요약본을 출력한다. 대규모 회귀 테스트 및 결함 분포도 측정 시 적용한다.

```verilog
$display("검사 완료: 총 %0d회 검증 중 결함 %0d건", check_count, error_count);
if (error_count != 0)
  $fatal(1, "FAIL 총 %0d건의 결함 발생", error_count);
```

---

## 4. 32비트 아키텍처 6대 경계값 선정 기준

32비트 연산기(HW02 ALU 등) 검증 시 다음 6대 범주의 경계값 벡터를 필수로 구성한다.

| 경계값 범주 | 대표 32비트 헥스 패턴 | 검증 목적 및 타깃 결함 |
|---|---|---|
| 최소/최대 극값 | `32'h0000_0000`, `32'hffff_ffff` | 0 처리 및 전체 비트 High 상태 연산 |
| 극값 인접 지점 | `32'h0000_0001`, `32'hffff_fffe` | 대소 비교 연산자의 `<` vs `<=` 오동작 |
| 부호 전환 경계 | `32'h7fff_ffff`, `32'h8000_0000` | 2의 보수 오버플로 및 Signed 비교 |
| 바이트/하프워드 경계 | `32'h0000_ffff`, `32'hffff_0000` | 즉치수 부호 확장 및 바이트 정렬 |
| 교번 비트 패턴 | `32'h5555_5555`, `32'haaaa_aaaa` | 인접 데이터 도선 간 브리지 결함 |
| 자리올림 유발 조합 | `32'hffff_ffff` + `32'h0000_0001` | 캐리 체인 전파 및 MSB 자리올림 |

---

## 5. 독립 참조 모델과 의사 난수 검증

[`tb_ex04.v`](tb_ex04.v)는 독립적인 참조 모델과 고정 시드 난수 발생기를 결합하여 수백 회의 무작위 검증을 자동 수행한다.

```verilog
integer seed = 32'd20260825;    // 재현 가능한 고정 시드
...
addend = $random(seed);

// 소프트웨어 레퍼런스 모델 연산
reference_wide  = {1'b0, reference_total} + {1'b0, addend};
reference_total = reference_wide[15:0];
reference_carry = reference_wide[16];

// DUT 출력과 레퍼런스 모델 출력의 자동 일치 검증
if (total !== reference_total || carry !== reference_carry)
  $fatal(1, "FAIL 난수 검증 불일치");
```

---

## 6. VCD 파형 덤프 및 CSV 트레이스 로깅

[`tb_ex05.v`](tb_ex05.v)는 디버깅 및 과제 제출용 증거 파일을 생성한다.

```verilog
// 1. VCD 파형 덤프 설정
$dumpfile("build/ex05.vcd");
$dumpvars(0, tb_ex05);

// 2. CSV 트레이스 파일 출력
trace_file = $fopen("build/trace.csv", "w");
if (trace_file == 0) $fatal(1, "FAIL CSV 파일을 열 수 없습니다.");
$fwrite(trace_file, "cycle,time_ns,enable,addend,total,zero,carry\n");

// 매 사이클 커밋 시점마다 로그 기록
$fwrite(trace_file, "%0d,%0d,%b,%h,%h,%b,%b\n",
        cycle, $time, enable, addend, total, zero, carry);

$fclose(trace_file);
```

---

## 7. 테스트벤치 3대 함정 분석

`make errors` 실행으로 결함을 분석한다.

```bash
make errors
```

### 함정 1: 클록 에지 직후 `#1` 대기 누락 (`bad01_no_delay.v`)

`@(posedge clk);` 직후 지연 없이 값을 읽으면 논블로킹 대입 전의 이전 사이클 값이 샘플링되어 검증이 1사이클 어긋난다. 반드시 `#1` 지연 후 판정한다.

### 함정 2: `$display` 단순 출력에 의존 (`bad02_display_only.v`)

기대값 비교문 없이 화면 출력만 남길 경우 하드웨어 결함이 발생해도 테스트벤치가 성공으로 종료된다.

### 함정 3: 의사 난수 시드 미지정 (`bad03_random_seed.v`)

시드를 지정하지 않으면 시뮬레이션 실행마다 난수 수열이 변경되어 결함 발생 시 동일 조건 재현이 불가능하다.

---

## 8. 테스트벤치 RTL 10대 자가 점검 체크리스트

1. DUT 입력은 `reg`, 출력은 `wire`로 선언되었는가?
2. 클록 신호가 `1'b0`으로 초기화되었는가?
3. 클록 상승 에지 검증 시 `@(posedge clk);` 직후 `#1;` 지연을 부여하였는가?
4. 모든 검증 단계가 기대값과의 등가 연산(`!==`)으로 자동 판정되는가?
5. 실패 메시지에 기대값과 실제 측정값이 모두 명시되어 있는가?
6. 6대 경계값 벡터와 난수 테스트가 상호 보완적으로 구성되었는가?
7. `$random`에 고정 정수 시드(Seed)를 전달하였는가?
8. 총 검증 횟수와 결함 건수가 집계 출력되는가?
9. 무한 루프 방지용 안전 타임아웃 블록이 존재하는가?
10. 검증 통과 시 명시적인 `PASS` 메시지와 `$finish(0)`으로 종료되는가?

---

## 9. 챕터 전체 검증 실행

```bash
make test      # 예제 검증
make errors    # 함정 예제 분석
make waves     # VCD 파형 뷰어 실행
make clean
```

---

## 10. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| 7단 자체 검증 테스트벤치 골격 | HW02–HW04 학생 확장 테스트 작성 |
| 6대 경계값 테이블 | HW02 ALU 4대 플래그 및 RV32 연산 검증 |
| 고정 시드 난수 검증 | HW02 레지스터 파일 무작위 R/W 검증 |
| CSV 커밋 트레이스 로깅 | HW03 `commit_trace.csv` 및 HW04 `cpi_audit.csv` |
| 타임아웃 안전장치 | HW03, HW04 프로그램 루프 시뮬레이션 보호 |

---

## 11. 핵심 개념 확인 질문

1. 테스트벤치에서 클록 신호를 `reg clk = 1'b0;`으로 초기화해야 하는 이유는 무엇인가?
2. `task`와 `function`의 시간 지연(`#`, `@`) 지원 차이는 무엇인가?
3. 순차논리 검증 시 `@(posedge clk);` 직후 `#1;` 지연을 부여하는 하드웨어적 이유는 무엇인가?
4. 32비트 프로세서 검증 시 필수 포함해야 하는 6대 경계값 범주를 설명하라.
5. `$random` 함수에 고정 시드(Seed)를 전달하여 얻는 검증상의 이점은 무엇인가?

---

이전 챕터: [ch07. 메모리와 FSM](../ch07/README.md) | 다음 챕터: [ch09. 합성 가능 코딩](../ch09/README.md)
