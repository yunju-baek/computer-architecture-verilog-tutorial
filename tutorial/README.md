# Verilog 자습서

## 1. 자습서의 목적 및 특징

HW02부터 HW05까지는 Verilog HDL로 디지털 하드웨어를 직접 설계한다. 본 자습서는 수강생이 컴퓨터구조 과제를 자립적으로 수행할 수 있도록 문법 체계와 하드웨어 설계 규약을 체계적으로 확립한다.

본 자습서의 3대 핵심 특징:

1. 전 예제 100% 실행 가능: 코드 조각의 수동 분석을 지양하고, 모든 예제를 독립 소스로 제공하여 `make test`로 실제 시뮬레이션 출력을 검증한다. 본문에 수록된 모든 로그는 실제 시뮬레이터 실행 결과를 정합하여 수록하였다.
2. 과제 프레임워크와 완벽히 일치하는 문법 표준: 본문 예제는 Verilog-2001 표준(`wire`, `reg`, `always @*`, `always @(posedge clk)`)을 채택하여 `assignments/` starter RTL과의 표기 일관성을 확보한다. 제공 testbench에서 활용하는 SystemVerilog 문법은 ch10 대조표에서 명확히 규정한다.
3. 의도적 결함(`badNN`) 기반의 디버깅 훈련: 각 챕터마다 컴파일 실패 및 잠재적 로직 결함을 유발하는 함정 코드를 제공한다. `make errors`를 실행하여 컴파일러 진단 메시지를 분석하고 문제 해결 능력을 배양한다.

---

## 2. 빠른 실행 가이드

### 2.1 개발 도구 확인

```bash
iverilog -V | head -1
vvp -V | head -1
```

버전 문자열이 출력되면 준비가 완료된 상태다. 세부 설치 방법은 [ch01](ch01/README.md) 1절에 수록되어 있다.

### 2.2 전체 자습서 일괄 검증

```bash
make test
```

콘솔 마지막 행에 `PASS tutorial 전체`가 출력되면 모든 예제가 정상 통과한 상태다.

### 2.3 Make 타깃 체계

| 명령 | 핵심 동작 |
|---|---|
| `make setup-check` | 필수 도구 환경 점검 |
| `make test` | 10개 챕터 전체 예제 일괄 컴파일 및 실행 |
| `make errors` | 각 챕터의 오류/함정 예제 실행 및 진단 메시지 출력 |
| `make waves` | ch10 통합 예제의 VCD 파형 생성 및 뷰어 연동 |
| `make clean` | 빌드 산출물 초기화 |
| `make help` | 지원 타깃 목록 출력 |

개별 챕터 디렉터리에서도 동일한 방식으로 실행할 수 있다.

```bash
cd ch03
make test
make errors
```

---

## 3. 10개 챕터 및 부록 목차

| 챕터 | 주제 | 다루는 핵심 내용 | 연계 과제 |
|---|---|---|---|
| [ch01](ch01/README.md) | 도구와 첫 모듈 | `iverilog`/`vvp` 실행 파이프라인, `module` 포트 선언, `assign`, 자가검사 testbench, 오류 메시지 분석 | 전 과제 |
| [ch02](ch02/README.md) | 문법과 자료형 | 리터럴 표기, `0`/`1`/`x`/`z` 4치 논리, `wire`/`reg` 구동 원칙, 비트 슬라이싱, 비트 결합 및 부호 확장, `parameter` | HW02 |
| [ch03](ch03/README.md) | 연산자와 비트 폭 규칙 | 연산자 우선순위, 5대 비트 폭 확장 규칙, 부호 해석, 3종 시프트 연산, 4대 ALU 플래그 독립성 | HW02 |
| [ch04](ch04/README.md) | 조합논리 회로 설계 | `always @*`, `case` 완결성, 기본값 선행 배정, 우선순위 인코딩, `function`, 래치(Latch) 추론 방지 | HW02 |
| [ch05](ch05/README.md) | 순차논리 회로 설계 | `always @(posedge clk)`, 논블로킹 대입(`<=`), 동기 리셋, reset > load > enable 우선순위 | HW02, HW03, HW04 |
| [ch06](ch06/README.md) | 계층 구조와 파라미터화 | 계층 모듈화, 이름 기반 명시적 포트 결합, 계층 경로 신호 관측, `generate` 반복문 | HW03 |
| [ch07](ch07/README.md) | 메모리와 FSM | 2차원 배열 선언, 조합 읽기와 동기 읽기 타이밍, `$readmemh`, 2-블록 FSM 표준 골격 | HW02, HW03, HW04 |
| [ch08](ch08/README.md) | testbench 작성 기법 | 자가검사 표준 골격, `task` 모듈화, 32비트 경계값 벡터, 황금 참조 모델 대조, VCD 및 CSV trace 생성 | 전 과제 |
| [ch09](ch09/README.md) | 합성 가능 RTL 코딩 | 합성 가능 하드웨어 부분집합, 시뮬레이션 전용 구문 격리, 하드웨어 27대 점검 체크리스트 | 전 과제 |
| [ch10](ch10/README.md) | SystemVerilog 대조표 | `logic`, `always_comb`/`always_ff`, `typedef enum`, packed struct, 프레임워크 소스 독해 5단계 | 전 과제 |
| [부록](appendix/README.md) | 종합 빠른 참조 | 핵심 명령어, 관용 패턴, 32비트 경계값 목록, 컴파일러 오류 대응표, 증상별 디버깅 가이드 | 전 과제 |

---

## 4. 개념 단계별 학습 권장 경로

| 학습 단계 | 학습 대상 챕터 | 학습 도달 목표 |
|---|---|---|
| 1단계: 도구 환경 및 기초 | ch01 | 시뮬레이션 컴파일 및 실행, 컴파일러 진단 메시지 분석 |
| 2단계: 자료형 및 비트 산술 | ch02, ch03 | 비트 폭 확장 규칙 및 부호 해석, HW02 산술 연산 준비 |
| 3단계: 조합논리 및 자가검사 | ch04, ch08 | 기본값 선행 배정 및 testbench 작성, HW02 ALU 완성 |
| 4단계: 순차논리 및 계층 결합 | ch05, ch06 | 논블로킹 상태 전이 및 모듈 계층 결합, HW02 단위 모듈 완성 |
| 5단계: 메모리 타이밍 및 합성 | ch07, ch09 | 레지스터 배열 타이밍 및 FSM, HW03 단일사이클 통합 완성 |
| 6단계: 현대적 표기 체계 독해 | ch10 | SystemVerilog 검증 구문 독해, HW04 파이프라인 프레임워크 분석 |
| 상시 참조 | [부록](appendix/README.md) | 하드웨어 구현 및 디버깅 중 수시 참조 |

---

## 5. SystemVerilog 통합 예제

[`ch10/overview.sv`](ch10/overview.sv)와 [`ch10/tb_overview.sv`](ch10/tb_overview.sv)는 조합논리와 순차논리를 단일 파일에 통합한 기준 예제다. 4비트 단위 모듈 5종(`inv4`, `add4`, `mux4`, `dff1`, `mini_alu`)과 이를 통합 검증하는 자가검사 testbench로 구성된다.

```bash
make waves       # VCD 파형 생성 및 뷰어 실행
```

---

## 6. 평가 과제와의 연계 맵핑

| 과제 | 과제 주요 내용 | 필수 사전 학습 챕터 |
|---|---|---|
| HW01 | Architectural-State Programming | ch02 (명령어 필드 구조 참조) |
| HW02 | TinyRV Building Blocks | ch02, ch04, ch05, ch06, ch07 |
| HW03 | TinyRV Core Integration | ch05, ch06, ch07, ch08 |
| HW04 | Forwarding and Load-Use Interlock | ch05, ch07, ch09, ch10 |

---

## 7. 예제 소스 파일 명명 규약

| 접두사/명칭 | 파일 성격 및 실행 방법 |
|---|---|
| `exNN_이름.v` | 정상 설계 모듈 소스 또는 독립 실행 예제 (`make test`) |
| `tb_exNN.v` | 해당 예제의 전용 자가검사 testbench 소스 |
| `badNN_이름.v` | 문법 오류 또는 잠재 결함을 학습하기 위한 함정 예제 (`make errors`) |

검사 결과는 프로세스 종료 규약으로 자동 판정한다. 검사 통과 시 `$display("PASS ...")` 실행 후 `$finish(0)`로 정상 종료하며, 결함 검출 시 `$fatal(1, "FAIL ...")`로 비정상 종료하여 Make 빌드 시스템이 실패를 즉시 감지한다. 과제의 공개 테스트 스위트도 동일한 종료 규약을 엄격히 적용한다.
