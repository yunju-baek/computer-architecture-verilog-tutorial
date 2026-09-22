# Verilog 점검 2 — 모듈 연결·상태·검증, CH06–CH10

## 1. 학습 목표

2회차 설명 수업의 범위인 CH06–CH10을 자습한 뒤, 자습서 5개 장을 실행하고, 계층 연결·메모리 읽기 시점·FSM·누적기·SystemVerilog 표기의 출력을 자신의 학번에서 파생된 입력으로 예상하여 실행으로 확인한다. 또한 CH08의 경계값 testbench를 학번에서 파생된 값 2개로 확장한다.

| 확인 대상 | 방법 |
|---|---|
| 도구와 환경 | `make setup-check`가 `evidence/env.txt`를 기록한다 |
| 자습서 실행 | `make tutorial-check`가 ch06–ch10의 `make test`를 실행하고 장별 로그를 남긴다 |
| 코드 읽기 | `make test`가 `predictions.vh`의 예상값 17개를 실제 실행 결과와 대조한다 |
| testbench 확장 | `make boundary-test`가 수정한 `tb_boundary.v`를 12개 벡터로 실행하고 필수 값 2개를 확인한다 |

## 2. 선행 학습

| 장 | 점검에서 읽는 파일 | 슬라이드 |
|---|---|---|
| CH06 | `tutorial/ch06/ex03_generate.v` | 03–05 |
| CH07 | `tutorial/ch07/ex02_sync_read.v`, `ex04_fsm.v` | 06–11 |
| CH08 | `tutorial/ch08/ex01_dut.v`, `tb_ex03.v` | 12–15, 20 |
| CH09 | `tutorial/ch09/ex01_synthesizable.v` | 16–17 |
| CH10 | `tutorial/ch10/ex01_style.sv` | 18 |

점검 1을 마친 환경에서 진행한다. 학번은 점검 1과 같은 값을 쓴다.

## 3. 작성 파일

| 파일 | 내용 |
|---|---|
| `student.mk` | 학번 9자리 1줄 |
| `predictions.vh` | 예상값 17개. `x` 자리를 계산한 값으로 바꾼다 |
| `tb_boundary.v` | `tutorial/ch08/tb_ex03.v`의 사본. 벡터를 12개로 늘린다 |
| `report.md` | 예상과 다르게 나온 항목의 이유, 검사 범위 설명, 장별 한 문장 |
| `integrity.txt` | 검증 방법과 책임 확인 |

## 4. 진행 순서

1. `check_packet/check2/`로 이동해 `student.mk`에 학번을 적는다.
2. `make setup-check`, `make tutorial-check`를 실행한다. 장마다 `PASS chNN`을 확인한다.
3. `make show-inputs`로 입력값을 본다. `REQUIRED` 줄에 `tb_boundary.v`에 넣을 값 2개가 표시된다.
4. 장별 원본 파일을 읽고 출력을 계산해 `predictions.vh`에 적는다. CH07의 메모리 항목은 에지 순서, FSM 항목은 상태 전이표를 손으로 따라간다.
5. `make boundary`로 `tb_boundary.v`를 만든다. 다음 3곳을 고친다.
   - `VECTOR_COUNT = 10`을 `12`로 바꾼다.
   - `boundary_values[10]`, `boundary_values[11]`에 `REQUIRED` 값을 넣는다. 각 값이 무엇을 확인하는지 주석으로 적는다.
   - 마지막 `$display`의 PASS 문장에 벡터 개수 12가 들어가게 한다. `%0d`와 `VECTOR_COUNT`를 쓰면 개수와 표시가 연결된다.
   기존 값 10개, 검사식 3개, 모듈 이름 `tb_ex03`은 그대로 둔다.
6. `make test`를 실행한다. 5개 장의 `PASS chNN`과 `PASS boundary-test`가 나오면 마지막 줄에 `PASS check2 전체`가 표시된다.
7. `report.md`와 `integrity.txt`를 작성한다.
8. `make package`를 실행한다. `check_packet/verilog_check2_<학번>.zip`이 만들어진다.

## 5. 실행

```bash
cd check_packet/check2
make setup-check
make tutorial-check
make show-inputs        # 입력값과 REQUIRED 경계값 2개
make boundary           # tb_boundary.v 생성 (없을 때만)
make test               # 예상값 검사 5개 + boundary-test
make package            # ../verilog_check2_<학번>.zip
```

### 예상값 검사 항목

| 장 | 항목 | 계산 근거 |
|---|---:|---|
| CH06 | 3 | 8비트 합, 최종 자리올림, 하위 4비트에서 올라오는 자리올림 |
| CH07 | 5 | 조합 읽기·동기 읽기의 에지별 값 3개, FSM의 detected 횟수와 마지막 상태 |
| CH08 | 4 | 값 2개를 연속으로 더한 뒤의 total 2개, zero, carry |
| CH09 | 2 | 연산 3단계 뒤의 result와 is_zero |
| CH10 | 3 | always_comb mux의 출력, always_ff dff의 에지별 q 2개 |

모든 순차 항목은 입력을 하강 에지에서 바꾸고 상승 에지 뒤 `#1`에서 읽는다. CH07의 동기 읽기 항목은 같은 always 블록 안에서 같은 주소를 쓰고 읽을 때 우변이 이전 값을 읽는다는 점을 확인한다.

## 6. 보고서

`report.md`의 4개 절을 채운다.

1. 예상과 실행. 처음 예상이 실제와 달랐던 항목 2개와 코드에서 찾은 이유.
2. 검사 범위. `tb_boundary.v`의 `reset_dut`가 for 루프 안에 있는 이유, 각 벡터의 시작 상태, 그래서 이 testbench가 확인하는 동작과 확인하지 못하는 동작 각 1개.
3. 다음 실험. 누적 중 자리올림을 관찰할 연속 입력 2개와 단계별 기대값. 설계만 적고 구현은 선택이다.
4. 장별 한 문장. CH06–CH10 각 장에서 자신의 말로 정리한 규칙 1개.

## 7. 제출 확인

- `make clean` 뒤 `make package`가 `PASS ../verilog_check2_<학번>.zip`으로 끝난다.
- zip 안에 `student.mk`, `predictions.vh`, `tb_boundary.v`, `report.md`, `integrity.txt`, `evidence/`가 들어 있다.
- `evidence/`에 `env.txt`, `tutorial_ch06.log`–`tutorial_ch10.log`, `probe_ch06.log`–`probe_ch10.log`, `boundary.log`, `manifest.txt`가 있다.
- `boundary.log`의 10번과 11번 행에 `REQUIRED` 값이 있고 PASS 문장에 12가 들어 있다.
- 제출 위치와 마감은 LMS 공지를 따른다.
