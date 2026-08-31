# ch01. 도구와 첫 모듈

## 1. 학습 도달 목표

본 챕터를 완료하면 Verilog 소스 파일을 직접 생성하여 Icarus Verilog로 컴파일 및 시뮬레이션을 수행할 수 있다. 컴파일 실패 시 컴파일러 오류 메시지를 분석하여 결함 발생 위치를 정확히 진단한다.

본 챕터의 5대 학습 핵심:

1. `iverilog` 컴파일러와 `vvp` 런타임 엔진 기반의 실행 흐름
2. `module` 선언과 포트 인터페이스 정의
3. `assign` 구문을 활용한 조합논리 표현
4. 자가검사(Self-Checking) testbench의 기대값 대조 구조
5. 컴파일 오류 및 경고 메시지 분석 기법

---

## 2. 개발 도구 확인 및 환경 설정

본 자습서의 모든 하드웨어 예제는 Icarus Verilog를 기반으로 실행한다.

```bash
iverilog -V | head -1
vvp -V | head -1
```

버전 문자열이 출력되면 준비가 완료된 상태다. 본 자습서는 Icarus Verilog 13.0 환경에서 전수 검증을 완료하였다.

환경별 설치 명령:

| 운영체제 환경 | 설치 명령 |
|---|---|
| macOS (Homebrew) | `brew install icarus-verilog` |
| Ubuntu / WSL | `sudo apt install iverilog` |
| Windows | WSL 가상 환경을 설치한 후 Ubuntu 명령을 실행한다 |

---

## 3. 예제 1-1. 실행 가능한 최소 모듈

[`ex01_hello.v`](ex01_hello.v) 소스를 확인한다.

```verilog
`timescale 1ns/1ps

module ex01_hello;

  initial begin
    $display("hello from verilog");
    $display("simulation time = %0t", $time);
    $finish(0);
  end

endmodule
```

핵심 구문 분석:

1. `` `timescale 1ns/1ps ``: 시뮬레이션 시간 단위를 정의한다. 앞의 `1ns`는 지연 단위(`#1 = 1ns`)를 의미하며, 뒤의 `1ps`는 시뮬레이터 내부 시간 정밀도를 의미한다.
2. `module ex01_hello; ... endmodule`: 하드웨어 설계의 기본 단위를 선언한다. 포트가 없는 최상위 테스트 모듈이므로 모듈명 뒤에 세미콜론이 위치한다.
3. `initial begin ... end`: 시뮬레이션 시작 시점($t=0$)에 1회 실행되는 절차 블록이다. 시뮬레이션 전용 구문이므로 합성 대상 RTL 회로에서는 배제하고 testbench에서만 활용한다.
4. `$display`: 지정된 서식에 맞춰 콘솔에 텍스트를 출력한다.
5. `$finish(0)`: 시뮬레이션을 정상 종료한다. 인자 `0`은 종료 진단 메시지 출력을 생략하여 검증 로그를 간결하게 유지한다.

### 컴파일 및 실행 명령

```bash
iverilog -g2012 -Wall -s ex01_hello -o build/ex01.vvp ex01_hello.v
vvp build/ex01.vvp
```

실행 결과:

```text
hello from verilog
simulation time = 0
```

### 컴파일 옵션 분석

| 옵션 플래그 | 하드웨어적 역할 및 목적 |
|---|---|
| `iverilog` | Verilog 소스를 시뮬레이션 중간 바이너리로 컴파일 |
| `-g2012` | IEEE 1800-2012 언어 표준 적용 (SystemVerilog testbench 호환) |
| `-Wall` | 전체 컴파일 경고 활성화 (신호 폭 불일치 및 잠재 결함 포착) |
| `-s ex01_hello` | 시뮬레이션의 진입점이 되는 최상위(Root) 모듈 지정 |
| `-o build/ex01.vvp` | 출력 바이너리 파일명 지정 |
| `ex01_hello.v` | 컴파일 대상 소스 파일 목록 |
| `vvp` | 생성된 `.vvp` 시뮬레이션 바이너리 엔진 실행 |

과제 디렉터리의 `Makefile`도 동일한 플래그 조합을 사용하므로 실습 환경과 평가 환경이 완벽히 일치한다.

---

## 4. 예제 1-2. 첫 번째 조합논리 회로 모듈

[`ex02_inverter.v`](ex02_inverter.v)는 4비트 반전기 회로다.

```verilog
`timescale 1ns/1ps

module ex02_inverter(
  input  wire [3:0] a,   // 4비트 입력 포트
  output wire [3:0] y    // 4비트 출력 포트
);

  assign y = ~a;

endmodule
```

포트 선언 시 방향(`input`, `output`), 자료형(`wire`), 비트 폭(`[3:0]`)을 명시한다. `[3:0]`은 최상위 비트(MSB)가 3, 최하위 비트(LSB)가 0인 4비트 버스다.

`assign`은 연속 할당문(Continuous Assignment)으로, 우변 `~a` 신호의 변화가 발생하는 즉시 좌변 `y` 출력에 실시간 전파된다. 두 물리적 노드를 연결하는 도선 동작을 모델링한다.

### 자가검사(Self-Checking) Testbench

회로 모듈을 검증하기 위해 입력 자극을 생성하고 출력을 판정하는 [`tb_ex02.v`](tb_ex02.v)를 구성한다.

```verilog
module tb_ex02;

  reg  [3:0] a;     // DUT 입력을 구동하므로 reg 선언
  wire [3:0] y;     // DUT 출력을 관찰하므로 wire 선언
  integer    i;

  ex02_inverter dut(.a(a), .y(y));

  initial begin
    for (i = 0; i < 16; i = i + 1) begin
      a = i[3:0];
      #1;
      if (y !== ~a)
        $fatal(1, "FAIL a=%b y=%b expected=%b", a, y, ~a);
    end
    $display("PASS ch01 ex02 inverter, 16 vectors");
    $finish(0);
  end

endmodule
```

4대 핵심 검증 규칙:

1. `reg`와 `wire`의 구동 원칙: 절차 블록(`initial`, `always`) 내에서 대입되는 신호는 `reg`로 선언하고, 연속 할당(`assign`) 또는 하위 모듈 출력으로 구동되는 신호는 `wire`로 선언한다.
2. 명시적 이름 기반 인스턴스화: `ex02_inverter dut(.a(a), .y(y));`와 같이 포트명을 직접 매핑하여 연결 오류를 컴파일 단계에서 차단한다.
3. 신호 전파 지연(`#1`): 입력값 변경 후 신호가 조합 회로를 거쳐 안정화될 때까지 1ns의 시뮬레이션 지연을 부여한다.
4. 엄격한 4치 비교(`!==`) 및 비정상 종료(`$fatal`): `x`, `z` 부정 상태를 감지하기 위해 `!==` 연산자를 사용하며, 오류 검출 시 `$fatal(1, ...)`을 호출하여 프로세스 종료 코드 1을 반환한다.

### 컴파일 및 실행

```bash
iverilog -g2012 -Wall -s tb_ex02 -o build/ex02.vvp ex02_inverter.v tb_ex02.v
vvp build/ex02.vvp
```

실행 결과:

```text
PASS ch01 ex02 inverter, 16 vectors
```

---

## 5. 예제 1-3. 다중 출력 게이트 모듈

[`ex03_gates.v`](ex03_gates.v)는 4개의 논리 출력을 생성한다.

```verilog
module ex03_gates(
  input  wire a,
  input  wire b,
  output wire y_and,
  output wire y_or,
  output wire y_xor,
  output wire y_nand
);

  assign y_and  = a & b;
  assign y_or   = a | b;
  assign y_xor  = a ^ b;
  assign y_nand = ~(a & b);

endmodule
```

`assign` 문들은 독립된 물리 회로를 모델링하므로 코드 상의 기술 순서와 무관하게 병렬로 상시 동작한다.

[`tb_ex03.v`](tb_ex03.v) 실행 결과:

```bash
iverilog -g2012 -Wall -s tb_ex03 -o build/ex03.vvp ex03_gates.v tb_ex03.v
vvp build/ex03.vvp
```

```text
 a b | and or xor nand
-----+-------------------
 0 0 |  0   0   0    1
 0 1 |  0   1   1    1
 1 0 |  0   1   1    1
 1 1 |  1   1   0    0
PASS ch01 ex03 gates, 4 vectors
```

---

## 6. 예제 1-4. `$display` 포맷 서식 체계

[`ex04_display.v`](ex04_display.v)로 하드웨어 디버깅용 출력 서식을 확인한다.

```bash
iverilog -g2012 -Wall -s ex04_display -o build/ex04.vvp ex04_display.v
vvp build/ex04.vvp
```

```text
binary       %b   = 10100011
hex          %h   = a3
decimal      %d   = 163
decimal trim %0d  = 163
octal        %o   = 243
signed       %0d  = -93
32bit hex    %h   = deadbeef
width 8      %8b  =     0011
string       %s   = opcode
time         %0t  = 0
```

주요 서식 지정자:

| 서식자 | 출력 형식 및 용도 |
|---|---|
| `%b` | 2진수 비트 패턴 출력 |
| `%h` | 16진수 출력 (32비트 명령어 및 주소 관측) |
| `%d` | 선언 비트 폭에 맞춘 공백 패딩 10진수 출력 |
| `%0d`, `%0h`, `%0b` | 선행 공백을 제거한 밀착 출력 |
| `%s` | 문자열 출력 |
| `%0t` | 현재 시뮬레이션 시간 출력 |

`8'b1010_0011` 비트 패턴에 `$signed` 적용 시 `-93`, 기본 Unsigned 적용 시 `163`이 출력된다. 동일 하드웨어 비트 패턴의 두 정수 해석 체계는 HW02의 핵심 원리다.

---

## 7. 컴파일 오류 및 경고 메시지 분석 훈련

`make errors`를 실행하여 사전에 구성된 2대 결함 유형의 진단 메시지를 확인한다.

```bash
make errors
```

### 결함 유형 1: 문법 오류 (`syntax error`)

[`bad01_missing_semicolon.v`](bad01_missing_semicolon.v)는 10행의 세미콜론이 누락된 예제다.

```text
bad01_missing_semicolon.v:12: syntax error
I give up.
```

컴파일러는 문장 종결자를 찾아 다음 행을 계속 파싱하므로 오류 위치가 실제 누락 지점(10행)보다 후행하는 12행으로 보고된다. `syntax error` 발생 시 지목된 행과 직전 행들의 세미콜론, 괄호, `begin`/`end` 쌍을 함께 확인한다.

### 결함 유형 2: 비트 폭 불일치 경고 (`width mismatch`)

[`bad02_port_width.v`](bad02_port_width.v)는 4비트 포트에 8비트 신호를 연결한 예제다.

```text
bad02_port_width.v:17: warning: Port 1 (a) of module narrow expects 4 bit(s), given 8.
bad02_port_width.v:17:        : Pruning 4 high bits of the expression.
bad02_port_width.v:17: warning: Port 2 (y) of module narrow expects 4 bit(s), given 8.
bad02_port_width.v:17:        : Padding 4 high bits of the expression.
wide_in=ab wide_out=04
```

컴파일과 시뮬레이션은 완료되나, 상위 4비트가 잘려 나가고(`Pruning`) 결과가 상위 0으로 패딩되어(`Padding`) 의도와 다른 연산이 수행된다. `-Wall` 옵션으로 경고를 상시 확인하여 비트 폭 불일치 문제를 해결한다.

### 오류 메시지 진단 대응표

| 컴파일러 진단 메시지 | 주요 점검 대상 |
|---|---|
| `syntax error` | 지목 행 및 직전 행의 세미콜론, 괄호, `begin`/`end` 쌍 |
| `Unknown module type` | 모듈명 오타, 해당 소스 파일의 컴파일 대상 포함 여부 |
| `port ... is not a port of ...` | 인스턴스 포트명과 모듈 선언 포트명의 일치 여부 |
| `expects N bit(s), given M` | 연결 신호와 포트 간의 비트 폭 정의 |
| `... is not a valid l-value` | 절차 블록 내 대입 대상의 `reg` 선언 여부 |
| `Cannot find the root module` | `-s` 옵션에 지정한 최상위 모듈명의 철자 |

---

## 8. 챕터 전체 검증 실행

```bash
make test
```

```text
=== ch01 ex01 hello ===
hello from verilog
simulation time = 0
=== ch01 ex02 inverter ===
PASS ch01 ex02 inverter, 16 vectors
=== ch01 ex03 gates ===
 a b | and or xor nand
-----+-------------------
 0 0 |  0   0   0    1
 0 1 |  0   1   1    1
 1 0 |  0   1   1    1
 1 1 |  1   1   0    0
PASS ch01 ex03 gates, 4 vectors
=== ch01 ex04 display ===
binary       %b   = 10100011
...
PASS ch01
```

---

## 9. 실습 과제 및 실기 연습

1. `ex02_inverter.v`의 포트 폭을 `[7:0]`으로 확장하고 `tb_ex02.v`의 반복 횟수를 256회로 정합하여 전수 검증을 완료한다.
2. `ex03_gates.v`에 `y_nor` 출력을 추가하고, 모듈 포트, 인스턴스 매핑, testbench 검증문을 모두 갱신하여 통과시킨다.
3. `tb_ex03.v`의 기대값을 의도적으로 변경하여 `$fatal` 발생 및 종료 코드 1 반환을 확인한다.
4. `ex02_inverter.v`에서 `y`를 `reg [3:0] y`로 변경한 후 `assign` 적용 시 발생하는 컴파일 오류를 확인한다.
5. `tb_ex02.v`의 `#1` 지연을 제거하고 실행하여 신호 레이스 조건에 따른 검증 실패를 관측한다.

---

## 10. 평가 과제와의 연계

| 본 챕터 학습 내용 | 실제 과제 적용 대상 |
|---|---|
| `-g2012 -Wall -s` 컴파일 옵션 | HW02–HW05 전체 과제 빌드 시스템 |
| 포트 선언 및 버스 폭 정의 | HW02 `rtl/rv32_alu.v`의 32비트 포트 인터페이스 |
| `assign` 연속 할당문 | HW03 `rtl/regfile.v`의 조합 읽기 포트 |
| 이름 기반 명시적 인스턴스화 | HW04 `rtl/rv32i_core.v`의 코어 데이터패스 통합 |
| `!==` 및 `$fatal` 자가검사 체계 | 전체 과제의 공개 및 학생 testbench |

---

## 11. 핵심 개념 확인 질문

1. `iverilog`의 `-s` 옵션이 지정하는 모듈의 역할은 무엇인가?
2. `assign` 문 여러 개를 임의의 순서로 기술해도 동일하게 동작하는 하드웨어적 이유는 무엇인가?
3. testbench에서 입력을 `reg`, 출력을 `wire`로 선언하는 구동 원칙은 무엇인가?
4. `$fatal` 호출 시 반환되는 프로세스 종료 코드가 Make 빌드 시스템에 주는 영향은 무엇인가?
5. 컴파일러 경고(Warning)를 무시하고 진행할 때 발생할 수 있는 잠재 결함은 무엇인가?

---

다음 챕터: [ch02. 문법과 자료형](../ch02/README.md)
