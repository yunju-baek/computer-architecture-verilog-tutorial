# Verilog 점검 1 — 도구 설치와 CH01–CH05

## 1. 학습 목표

1회차 설명 수업의 범위인 CH01–CH05를 자습한 뒤, 도구가 설치된 자신의 컴퓨터에서 자습서 5개 장을 실행하고, 각 장의 원본 모듈이 자신의 학번에서 파생된 입력에 어떤 출력을 내는지 예상하여 실행으로 확인한다.

이 점검은 3가지를 확인한다.

| 확인 대상 | 방법 |
|---|---|
| 도구 설치 | `make setup-check`가 iverilog, vvp, make, git 버전을 `evidence/env.txt`에 기록한다 |
| 자습서 실행 | `make tutorial-check`가 ch01–ch05의 `make test`를 실행하고 장별 로그를 남긴다 |
| 코드 읽기 | `make test`가 `predictions.vh`에 적은 예상값을 실제 실행 결과와 대조한다 |

입력값은 학번마다 다르다. 다른 사람의 예상값이나 로그는 자신의 학번에서 통과하지 못한다.

## 2. 선행 학습

| 장 | 점검에서 읽는 파일 | 슬라이드 |
|---|---|---|
| CH01 | `tutorial/ch01/ex02_inverter.v` | 07–09 |
| CH02 | `tutorial/ch02/ex04_select.v` | 10–12 |
| CH03 | `tutorial/ch03/ex02_width_rules.v`, `ex03_signed.v` | 13 |
| CH04 | `tutorial/ch04/ex02_default.v`, `ex01_mux4.v` | 14–15 |
| CH05 | `tutorial/ch05/ex03_control.v`, `ex02_blocking.v` | 16–19 |

도구 설치는 [자습서 CH01 2절](../../tutorial/ch01/README.md)의 절차를 따른다. LMS에서 받은 `activity_packet/도구설치_첫실행.md`에는 운영체제별 설치 절차가 더 자세히 있다.

## 3. 작성 파일

| 파일 | 내용 |
|---|---|
| `student.mk` | 학번 9자리 1줄 |
| `predictions.vh` | 예상값 20개. `x` 자리를 계산한 값으로 바꾼다 |
| `report.md` | 예상과 다르게 나온 항목의 이유, 장별 한 문장 |
| `integrity.txt` | 검증 방법과 책임 확인 |

`probes/`, `Makefile`, `../common/`은 그대로 둔다.

## 4. 진행 순서

1. 배포 저장소 루트(`tutorial/` 폴더가 보이는 위치)에 `check_packet/`을 둔다.
2. `check_packet/check1/`로 이동해 `student.mk`에 학번을 적는다.
3. `make setup-check`를 실행한다. 마지막 줄 `READY check1`을 확인한다.
4. `make tutorial-check`를 실행한다. 장마다 `PASS chNN`이 나오면 다음으로 간다. 실패한 장은 `evidence/tutorial_chNN.log`의 첫 오류를 읽고 해결한다.
5. `make show-inputs`로 자신의 입력값을 본다. 장별 원본 파일을 읽고 출력을 손으로 계산해 `predictions.vh`에 적는다.
6. `make test`를 실행한다. `UNANSWERED`는 아직 `x`인 항목, `FAIL`은 계산이 다른 항목이다. 코드를 다시 읽고 고친 뒤 다시 실행한다. 5개 장 모두 `PASS chNN`이 나오면 마지막 줄에 `PASS check1 전체`가 표시된다.
7. `report.md`와 `integrity.txt`를 작성한다.
8. `make package`를 실행한다. `check_packet/verilog_check1_<학번>.zip`이 만들어진다.

## 5. 실행

```bash
cd check_packet/check1
make setup-check        # 도구 4개 확인, evidence/env.txt
make tutorial-check     # ch01–ch05 자습서 실행
make show-inputs        # 학번에서 파생된 입력값 표시
make test               # 예상값 검사. 모두 통과하면 PASS check1 전체
make evidence           # evidence/manifest.txt (SHA-256 목록)
make package            # ../verilog_check1_<학번>.zip
```

`tutorial/`이 다른 위치에 있으면 `make test TUTORIAL=경로`로 지정한다.

### 예상값 검사 항목

| 장 | 항목 | 계산 근거 |
|---|---:|---|
| CH01 | 1 | `y = ~a` |
| CH02 | 6 | 명령어 워드의 고정 비트 범위 6개 |
| CH03 | 4 | 4비트 결과, 5비트 결과, 자리올림, `$signed` 해석 |
| CH04 | 5 | `with_default`의 출력 4개, `ex01_mux4`의 출력 1개 |
| CH05 | 4 | reset > load > enable 우선순위에 따른 state 3개, 논블로킹 시프트 결과 1개 |

CH05의 순서는 `make show-inputs`가 표시한다. 입력은 하강 에지에서 바뀌고 상승 에지 뒤 `#1`에서 상태를 읽는다.

## 6. 보고서

`report.md`의 3개 절을 채운다.

1. 환경. `evidence/env.txt`의 OS와 iverilog 버전, 설치 중 해결한 문제 1개.
2. 예상과 실행. 처음 예상이 실제와 달랐던 항목 2개와 코드에서 찾은 이유. 모두 한 번에 맞았으면 가장 확신이 약했던 항목 2개와 근거.
3. 장별 한 문장. CH01–CH05 각 장에서 자신의 말로 정리한 규칙 1개.

본문은 1쪽 이내로 쓴다. 로그는 `evidence/`에 이미 있으므로 본문에 옮겨 적을 필요가 없다.

## 7. 제출 확인

- `make clean` 뒤 `make package`가 `PASS ../verilog_check1_<학번>.zip`으로 끝난다.
- zip 안에 `student.mk`, `predictions.vh`, `report.md`, `integrity.txt`, `evidence/`가 들어 있다.
- `evidence/`에 `env.txt`, `tutorial_ch01.log`–`tutorial_ch05.log`, `probe_ch01.log`–`probe_ch05.log`, `manifest.txt`가 있다.
- `predictions.vh`에 `x` 자리가 남아 있으면 `make test`가 `UNANSWERED`로 멈춘다.
- 제출 위치와 마감은 LMS 공지를 따른다.

교수자는 제출 zip을 새 폴더에 풀어 `make test`를 다시 실행하고, 그 결과와 `evidence/`의 로그·해시를 대조한다. 실행 문제가 남은 경우 `report.md` 1절에 재현 명령과 첫 오류를 적고, 만들어진 범위까지 `make evidence`로 묶어 제출한다.
