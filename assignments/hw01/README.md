# HW01: 함수 호출과 아키텍처 상태

배열 합산 함수를 RV32I 어셈블리로 구현하고, 함수 호출 전후의 `PC`·레지스터·스택 변화를 설명한다. 활동은 어셈블리 구현, 상태 변화 추적, 경계값 테스트, `ra` 복원 생략 실험의 4가지이다. 실행 trace는 학번마다 다른 입력으로 생성하므로 보고서의 수치는 학생마다 다르다.

## 1. 준비와 학번 입력

필수 실행 환경은 Python 3.11 이상과 GNU Make이다. C 컴파일러는 선택 활동인 `make test-c`에 사용한다.

1. `student_id.txt`를 열고 `#`으로 시작하는 안내 줄 아래에 본인 학번을 숫자로만 적는다.
2. `make setup-check`로 Python 버전을 확인한다.
3. `make my-input`으로 본인 입력을 확인한다. 출력되는 값은 다음 3가지이다.

| 항목 | 의미 |
|---|---|
| `values_decimal`, `values_hex` | `make evidence`에서 `main`의 `values` 자리에 들어가는 원소 4개 |
| `initial_sp` | `main` 시작 시 `sp` |
| `initial_saved` | `main` 시작 시 `s0`–`s2`; `sum_array` 복귀 후에도 같은 값이어야 한다 |

같은 학번은 항상 같은 입력을 만든다. 공개 검사(`make test`)는 기본 입력 `{5, -2, 9, -7}`과 기대 합 `5`를 사용한다.

## 2. 작성 범위와 제공 자료

| 구분 | 파일 | 용도 |
|---|---|---|
| 학생 작성 | `programs/state_contract.s` | `add_word`와 `sum_array` 완성 |
| 학생 작성 | `tests/test_student_cases.py` | 빈 배열·wraparound 테스트 2개 완성 |
| 학생 작성 | `report.md` | 4절 보고서 |
| 학생 작성 | `integrity.txt` | 자료·도구 사용 범위와 본인 검증 기록 |
| 학생 작성 | `student_id.txt` | 본인 학번 |
| 제공, 읽기 전용 | `programs/state_contract.c` | 배열 합산과 modulo-2^32 덧셈의 동작 참조 |
| 제공, 읽기 전용 | `tools/rv32i.py` | 어셈블러와 상태 시뮬레이터 |
| 제공, 읽기 전용 | `scripts/`, `tests/test_public_state.py`, `Makefile` | 학번 입력, evidence 생성, `ra` 실험, 제출 ZIP 생성, 공개 검사 |

제공 파일은 수정 없이 사용한다. 교수자는 제공 파일을 정본으로 교체한 뒤 제출물을 다시 실행한다. `Makefile`에서는 `RESTORE_LINE` 한 줄만 학생이 지정할 수 있다.

## 3. 진행 순서

| 단계 | 할 일 | 명령 | 결과를 적는 곳 |
|---:|---|---|---|
| 1 | 학번 입력과 환경 확인 | `make setup-check`, `make my-input` | — |
| 2 | `add_word`, `sum_array` 구현 | `make test-assembly` | 보고서 1절 |
| 3 | 경계값 테스트 2개 작성 (예상값을 보고서에 먼저 기록) | `make test` | 보고서 3절 |
| 4 | 예상 합을 보고서에 먼저 기록하고 trace 생성 | `make evidence` | 보고서 2절 |
| 5 | `ra` 복원 생략의 영향을 먼저 예측하고 실험 | `make ra-experiment` | 보고서 4절 |
| 6 | `integrity.txt` 작성 후 제출 ZIP 생성 | `make package` | LMS 업로드 |

`make evidence`와 `make ra-experiment`는 구현이 미완성이어도 실행된다. 결과가 기대와 다르면 `WARN`을 출력하므로 trace를 디버깅 자료로 활용한다. 어셈블리를 수정하면 4–6단계를 다시 실행한다.

## 4. 활동별 기준

### 4.1 어셈블리 구현

- `add_word`: `a0`와 `a1`을 더한 32비트 결과를 `a0`에 반환한다.
- `sum_array`: `a0`로 받은 배열 주소와 `a1`로 받은 원소 개수로 합을 계산한다. 원소마다 `add_word`를 호출한다.
- 중첩 호출 동안 유지할 포인터·개수·누적값을 관리하고, 복귀 시 `sp`와 사용한 `s0`–`s2`를 진입 시 값으로 복원한다.
- `sum_array`는 진입 시 `ra`를 스택에 저장하고, 복귀 전에 `lw ra, offset(sp)`로 복원한다. `ra`는 각 호출이 갱신하는 반환 주소 레지스터이므로, 중첩 호출을 하는 함수가 자신의 복귀 주소를 보관한다.
- 제공된 `main`, `values`(원소 4개), `result`와 함수 레이블을 유지한다.

### 4.2 상태 변화 4사례

`evidence/architectural_trace.csv`에서 `call`, 배열 적재 `lw`, 스택 저장 `sw`, `ret`을 한 행씩 고른다. `call`은 `sum_array` 안에서 `add_word`를 호출하는 행, `ret`은 `sum_array`가 `main`으로 복귀하는 행을 고른다. 각 행의 `seq`, 현재 `PC`, 명령어, 변경된 상태와 값, 다음 `PC`를 보고서 2절에 적는다.

trace의 열은 `seq`, `pc`, `word`, `asm`, `rd`, `rd_value`, `mem_addr`, `mem_value`, `next_pc`, `sp`이다. 주소와 값은 `0x` 16진수 8자리로 기록된다. `seq`는 명령어 실행 순서이며, 하드웨어 클록 사이클은 별도 모델에서 관찰한다. 실행 입력과 최종 상태는 `evidence/run_info.json`, `evidence/final_state.json`에 기록된다.

### 4.3 경계값 테스트 2개

`tests/test_student_cases.py`의 두 메서드를 완성한다. 제공된 `run_sum`이 실행 결과(`result.registers`, `result.trace`)를 반환한다.

| 테스트 | 입력 | assertion으로 확인할 항목 |
|---|---|---|
| `test_empty_array` | `[]` | 실행 후 `a0`, 진입 시 `sp=0x800`의 복원 |
| `test_word_wraparound` | `[0xffffffff, 1]` | modulo-2^32 결과 `a0`, `sp` 복원 |

좋은 테스트는 올바른 구현에서 통과하고, `a0`가 틀린 구현과 `sp`를 복원하지 못한 구현에서 각각 실패한다. 실행 전 예상값을 보고서 3절에 적고 실행값과 비교한다.

### 4.4 ra 복원 생략 실험

보고서 4절에 다음 3가지를 먼저 예측한다.

- `sum_array`의 마지막 `ret` 직전 `ra`에 남을 값
- `ret` 직후의 다음 `PC`와 그 주소의 명령어
- 이후 프로그램 실행에 나타날 영향

그다음 `make ra-experiment`를 실행한다. 도구는 `ra`를 복원하는 `lw` 하나를 같은 크기의 `nop`으로 바꾼 별도 실행본을 만들고, 해당 `ret` 직후까지 관찰한다. 명령어 주소와 레이블은 그대로 유지되며, 제출할 정상 소스도 그대로 보존된다.

| 생성 파일 | 용도 |
|---|---|
| `evidence/ra_experiment/normal_trace.csv` | 정상 프로그램의 전체 실행 |
| `evidence/ra_experiment/ra_omitted.s` | 복원 명령 하나를 `nop`으로 바꾼 실행본 |
| `evidence/ra_experiment/ra_omitted_trace.csv` | 변경한 프로그램의 해당 `ret`까지 실행 |
| `evidence/ra_experiment/comparison.json` | 두 실행의 복귀 `PC`와 목적지 명령어 비교 |

`sum_array`에 `lw ra, offset(sp)`가 여러 개이면 도구가 해당 소스 행 번호들을 알려 준다. 그중 `sum_array`의 복원 행을 골라 `Makefile`의 `# RESTORE_LINE =` 줄을 `RESTORE_LINE = 행번호`로 바꾼다. 교수자 재실행에도 이 값이 적용된다.

## 5. 지원하는 어셈블리 문법

| 구분 | 명령 |
|---|---|
| R 형식 | `add sub sll slt sltu xor srl sra or and` |
| I 형식 | `addi slti sltiu xori ori andi slli srli srai lw jalr` |
| S·B·J 형식 | `sw beq bne blt bge bltu bgeu jal ebreak` |
| 의사 명령 | `nop mv li la neg not seqz snez j jr call ret beqz bnez bltz bgez blez bgtz bgt ble bgtu bleu` |
| 지시어 | `.data .text .globl .word` |

`li`의 즉치값은 -2048~2047 범위에서 사용한다. 주석은 `#`으로 시작한다. 모든 명령은 실제 32비트 RV32I 인코딩으로 조립된다.

## 6. 제출

1. `make evidence`와 `make ra-experiment`를 최종 소스로 다시 실행한다.
2. `make package`를 실행한다. `submit/hw01_<학번>.zip`이 만들어진다.
3. 출력된 `WARN` 항목을 확인하고, 가능한 항목을 고친 뒤 `make package`를 다시 실행한다. 미완성 상태로도 ZIP은 만들어지며 부분점수를 받을 수 있다.
4. `submit/hw01_<학번>.zip` 파일 하나를 LMS의 HW01 항목에 올린다.

ZIP에는 과제 폴더 전체가 들어가며, `build/`, `submit/`, 캐시 파일은 자동으로 제외된다. `make clean`은 build·캐시만 지운다. evidence를 지울 때는 `make clean-evidence`를 사용한다.

## 7. 평가

| 영역 | 배점 | 확인 방법 |
|---|---:|---|
| 구현: 명세 동작 | 30 | `add_word`, 기본 입력의 `result`, 여러 배열의 합, 원소마다 `add_word` 호출 |
| 구현: 경계·호출 규약 | 20 | 빈 배열, wraparound, `sp`·`s0`–`s2` 복원, `ra`의 스택 저장·복원 |
| 검증: 학생 테스트 | 20 | 테스트마다 올바른 구현 통과 4, `a0` 오류 검출 3, `sp` 오류 검출 3 |
| 검증: 실행 증거 | 10 | 본인 학번으로 다시 생성한 evidence와 제출 evidence의 일치 (정상 trace 5, `ra` 실험 5) |
| 보고서 | 20 | 4절 각 5점: 코드 위치, 본인 trace 수치, 예측과 관측, 원인 설명의 연결 |

교수자는 제공 파일을 정본으로 교체하고, 제출한 어셈블리와 학번으로 모든 evidence를 다시 생성해 비교한다. 다른 학번으로 생성한 evidence, 본인 trace와 맞지 않는 보고서 수치, 제출물 사이의 같은 보고서 문장은 확인 대상으로 표시되며 교수자가 개별 확인한다. 기계어 필드 분석과 추가 C 구현은 선택 학습으로 활용한다.
