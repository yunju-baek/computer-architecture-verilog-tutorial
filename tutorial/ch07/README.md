# ch07. 메모리 배열과 유한 상태 기계(FSM)

## 1. 학습 도달 목표

본 챕터는 대용량 데이터를 저장하는 2차원 레지스터 메모리 배열 구조와 복합 제어 시퀀스를 관리하는 2-블록 유한 상태 기계(FSM)의 설계 원리를 확립한다. HW03의 32비트 레지스터 파일(`regfile.v`), HW04의 단일사이클 명령어/데이터 메모리, HW04 파이프라인 제어 구조가 본 챕터의 표준에 기반한다.

2대 핵심 불변식:

1. 2차원 배열 선언 시 데이터 비트 폭을 신호 이름 좌측에, 엔트리 개수(Depth)를 우측에 명시한다.
2. 2-블록 FSM 설계 시 상태 갱신 순차 블록(`always @(posedge clk)`)과 차기 상태/출력 결정 조합 블록(`always @*`)을 물리적으로 명확히 분리한다.

본 챕터의 6대 학습 핵심:

1. 2차원 레지스터 배열의 표준 선언 및 메모리 어레이 구성
2. 비동기/조합 읽기(Combinational Read)와 동기 읽기(Synchronous Read)의 타이밍 비교
3. `$readmemh`를 활용한 16진수 바이너리 이미지 초기화
4. 2-블록 표준 FSM 아키텍처 (Moore Type)
5. `localparam`을 활용한 상태 인코딩 캡슐화
6. 동일 주소 동시 읽기/쓰기(Read-First vs Write-First) 및 FSM 래치 방지

---

## 2. 2차원 메모리 어레이 설계

[`ex01_memory.v`](ex01_memory.v)는 16개 엔트리를 갖는 8비트 메모리 어레이를 구현한다.

```verilog
module ex01_memory #(
  parameter ADDR_WIDTH = 4,
  parameter DATA_WIDTH = 8
)(
  input  wire                  clk,
  input  wire                  write_enable,
  input  wire [ADDR_WIDTH-1:0] write_addr,
  input  wire [DATA_WIDTH-1:0] write_data,
  input  wire [ADDR_WIDTH-1:0] read_addr,
  output wire [DATA_WIDTH-1:0] read_data
);

  localparam DEPTH = 1 << ADDR_WIDTH;

  // 2차원 레지스터 배열 선언: [데이터폭-1:0] 배열이름 [0:엔트리수-1]
  reg [DATA_WIDTH-1:0] storage [0:DEPTH-1];

  // 동기 쓰기: 클록 상승 에지에 쓰기 인에이블 신호 확인 후 반영
  always @(posedge clk) begin
    if (write_enable)
      storage[write_addr] <= write_data;
  end

  // 비동기/조합 읽기: 주소 입력 즉시 데이터 출력 버스에 반영
  assign read_data = storage[read_addr];

endmodule
```

### 2차원 배열 선언 규칙

```text
reg [DATA_WIDTH-1:0] storage [0:DEPTH-1];
    └─ 엔트리당 비트 폭 ─┘       └─ 전체 엔트리 깊이 ─┘
```

엔트리 개수(`DEPTH`)는 주소 비트 폭(`ADDR_WIDTH`)으로부터 `1 << ADDR_WIDTH`로 자동 유도하여 주소 범위 초과 결함을 원천 방지한다.

실행 결과:

```text
--- 조합 읽기는 주소가 바뀌면 곧바로 값을 낸다 ---
addr | data
-----+-----
  0  |  10
  1  |  11
  2  |  12
  3  |  13
  4  |  14
--- write_enable이 0이면 값을 유지한다 ---
write_enable=0 -> addr 3 data=13
--- 배열 원소를 계층 이름으로 직접 읽는다 ---
dut.storage[7] = 17
PASS ch07 ex01 memory
```

---

## 3. 조합 읽기와 동기 읽기의 타이밍 비교

[`ex02_sync_read.v`](ex02_sync_read.v)는 두 읽기 구조의 출력 타이밍 차이를 검증한다.

```verilog
// 조합 읽기: 0-지연 즉시 출력 (단일사이클 프로세서 Regfile 표준)
assign read_data = storage[addr];

// 동기 읽기: 1사이클 클록 지연 후 레지스터 출력 (FPGA BRAM/SRAM 표준)
always @(posedge clk) begin
  read_data <= storage[addr];
end
```

실행 결과 비교:

```text
  시각 addr | 조합 동기
-----------+----------
  37ns   0  |  a0   xx  주소를 넣은 직후
  46ns   0  |  a0   a0  에지를 지난 뒤
  47ns   2  |  a2   a0  주소를 바꾼 직후
  56ns   2  |  a2   a2  에지를 지난 뒤
```

단일사이클 RV32I 코어(HW02, HW03)는 명령어 인출 및 레지스터 읽기를 단일 사이클 내에 완료해야 하므로 조합 읽기 구조를 채택한다.

---

## 4. `$readmemh`를 활용한 메모리 이미지 적재

[`ex03_readmem.v`](ex03_readmem.v)는 외부 16진수 텍스트 파일(`program.hex`)을 읽어 메모리 어레이를 초기화한다.

```verilog
reg [31:0] instruction_memory [0:DEPTH-1];
integer    i;

initial begin
  // 1. 전체 메모리를 0으로 초기화하여 미정의(x) 상태 전파 차단
  for (i = 0; i < DEPTH; i = i + 1)
    instruction_memory[i] = 32'h0000_0000;

  // 2. 16진수 헥스 파일 로드
  $readmemh(INIT_FILE, instruction_memory);
end
```

### 메모리 초기화 4대 규약

1. `$readmemh` (16진수) vs `$readmemb` (2진수)를 명확히 구분하여 사용한다.
2. 헥스 파일 내에 어셈블리 주석(`//`)을 기재하여 명령어 가독성을 유지한다.
3. 헥스 파일 로드 전 메모리 전 영역을 `32'h0000_0000`으로 선행 초기화한다.
4. `initial` 기반의 `$readmemh`는 시뮬레이션 및 테스트벤치 환경에서 프로그램 적재용으로 한정 사용한다.

---

## 5. 2-블록 표준 유한 상태 기계 (FSM)

[`ex04_fsm.v`](ex04_fsm.v)는 2-블록 구조로 3개 연속 `1` 패턴 검출기를 구현한다.

```verilog
localparam [1:0] IDLE     = 2'd0;
localparam [1:0] SAW_ONE  = 2'd1;
localparam [1:0] SAW_TWO  = 2'd2;
localparam [1:0] SAW_MANY = 2'd3;

reg [1:0] state, next_state;

// 블록 1: 상태 전이 순차논리 (동기 리셋 적용)
always @(posedge clk) begin
  if (reset)
    state <= IDLE;
  else
    state <= next_state;
end

// 블록 2: 차기 상태 및 출력 결정 조합논리
always @* begin
  // 기본값 선행 배정 (래치 추론 원천 차단)
  next_state = state;
  detected   = 1'b0;

  case (state)
    IDLE: begin
      if (bit_in) next_state = SAW_ONE;
    end
    SAW_ONE: begin
      if (bit_in) next_state = SAW_TWO;
      else        next_state = IDLE;
    end
    SAW_TWO: begin
      if (bit_in) next_state = SAW_MANY;
      else        next_state = IDLE;
    end
    SAW_MANY: begin
      detected = 1'b1;
      if (bit_in) next_state = SAW_MANY;
      else        next_state = IDLE;
    end
    default: next_state = IDLE;
  endcase
end
```

### 2-블록 FSM 설계 원칙

1. 상태 상수 선언: 모듈 내부 전용 상태 인코딩 상수는 `localparam`으로 정의한다.
2. 조합 블록 기본값 배정: `next_state = state;` 및 제어 출력 기본값을 블록 최상단에 선행 배정하여 분기 누락에 따른 래치 생성을 차단한다.
3. Moore 기계 표준: 출력 신호(`detected`)를 현재 상태(`state`)에 의존하도록 설계하여 글리치 없는 결정론적 타이밍을 확립한다.

---

## 6. 메모리 및 FSM 3대 결함 분석

`make errors` 실행으로 결함을 분석한다.

```bash
make errors
```

### 함정 1: 동일 클록 사이클 동시 읽기/쓰기 충돌 (`bad01_same_addr.v`)

동일 주소에서 동일 사이클에 쓰기와 읽기가 경합할 때, 조합 읽기는 갱신된 최신 데이터(Write-First)를 반영하고 동기 읽기는 이전 사이클 데이터(Read-First)를 반환한다. 프로세서 설계 명세에 맞추어 포워딩 회로를 설계한다.

### 함정 2: FSM 조합 블록 기본값 누락에 따른 래치 발생 (`bad02_fsm_state.v`)

FSM 출력 신호의 기본값 배정을 누락할 경우 특정 상태에서 활성화된 플래그가 비활성화 상태로 복귀하지 못하고 이전 값을 래치 유지하는 심각한 결함이 발생한다.

### 함정 3: 주소 폭과 메모리 깊이 불일치 (`bad03_array_range.v`)

4비트 주소선(16개 공간 접근 가능) 조건에서 배열을 8개 엔트리로 축소 선언하면 주소 8 이상 접근 시 시뮬레이터는 미정의 값(`x`)을 반환한다. 깊이를 `1 << ADDR_WIDTH`로 통일한다.

---

## 7. 챕터 전체 검증 실행

```bash
make test      # 정상 메모리 및 FSM 예제 검증
make errors    # 결함 예제 메시지 분석
make clean
```

---

## 8. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| 2차원 배열 선언 및 동기 쓰기 | HW02 `rtl/regfile.v` 32개 32비트 범용 레지스터 |
| 2포트 조합 읽기 구조 | HW02 레지스터 파일의 `rs1_data`, `rs2_data` 출력 |
| `$readmemh` 헥스 로더 | HW03 단일사이클 통합 테스트벤치 명령어 적재 |
| 2-블록 FSM 구조 | HW04 캐시 컨트롤러 및 다중 사이클 버스 FSM |
| `localparam` 상태 정의 | HW03 ALU 제어 상태 및 HW04 파이프라인 제어 신호 |

---

## 9. 핵심 개념 확인 질문

1. `reg [31:0] rf [0:31];` 선언에서 한 엔트리의 비트 폭과 총 엔트리 개수는 각각 얼마인가?
2. 단일사이클 프로세서의 레지스터 파일이 동기 읽기 대신 조합 읽기를 사용하는 이유는 무엇인가?
3. 2-블록 FSM 설계 시 1번 블록과 2번 블록의 담당 역할과 대입문 규칙을 기술하라.
4. FSM 조합 블록 최상단에 `next_state = state;`를 선행 배정해야 하는 하드웨어적 이유는 무엇인가?
5. `$readmemh` 실행 전 메모리 전 영역을 0으로 초기화하는 목적은 무엇인가?

---

이전 챕터: [ch06. 계층과 파라미터화](../ch06/README.md) | 다음 챕터: [ch08. testbench 작성법](../ch08/README.md)
