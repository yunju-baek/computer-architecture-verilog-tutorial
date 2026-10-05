# HW01: 함수 호출과 아키텍처 상태

배열 합산 함수를 RV32I 어셈블리로 구현하고, 함수 호출 전후의 `PC`·레지스터·스택 변화를 설명한다. 구현, 상태 추적, 경계값 테스트, 반환 주소 실험의 네 가지 활동을 수행한다.

## 제공 자료와 학생 작성 범위

| 구분 | 파일 | 용도 |
|---|---|---|
| 제공 C 참조 구현 | `programs/state_contract.c` | 배열 합산과 modulo-2^32 덧셈의 기능 확인; 읽기 전용 |
| 학생 어셈블리 구현 | `programs/state_contract.s` | `add_word`와 `sum_array` 완성 |
| 학생 테스트 | `tests/test_student_cases.py` | 빈 배열·wraparound 두 테스트 완성 |
| 학생 보고서 | `report.md` | 네 가지 활동의 결과와 설명 기록 |
| 도구 사용 기록 | `integrity.txt` | 참고 자료·도구와 본인 검증 범위 기록 |
| 제공 실행 도구 | `tools/rv32i.py`, `scripts/` | 정상 trace 생성 및 반환 주소 실험 |

필수 실행 환경은 Python 3.11 이상과 Make이다. C 컴파일러는 참조 구현을 직접 실행하는 선택 활동에 사용한다. C와 어셈블리로 구현한 함수의 기능을 각각 확인한다. 본 과제의 실행 trace는 제공된 어셈블리 상태 시뮬레이터에서 생성한다.

## 1. 어셈블리 구현

- `add_word`: `a0`와 `a1`을 더한 32비트 결과를 `a0`에 반환한다.
- `sum_array`: `a0`로 받은 배열 주소와 `a1`로 받은 원소 개수를 사용해 합을 계산한다. 각 원소를 더할 때 `add_word`를 호출한다.
- 중첩 호출 동안 유지할 포인터·개수·누적값을 관리하고, 반환 시 `sp`와 사용한 `s0`–`s2`를 진입 시 값으로 복원한다.
- `sum_array`는 진입 시 `ra`를 스택에 저장하고, 복귀 전에 `lw ra, offset(sp)`로 복원한다. `ra`는 각 호출이 갱신하는 반환 주소 레지스터이며, 중첩 호출을 하는 함수가 자신의 복귀 주소를 보관한다.
- 제공된 `main`·`values`·`result`와 함수 레이블을 유지한다. 기본 입력은 `{5, -2, 9, -7}`, 기대 합은 `5`이다.

## 2. 상태 변화 네 사례

`make evidence`로 생성한 `evidence/architectural_trace.csv`에서 `call`, 배열 적재 `lw`, 스택 저장 `sw`, `ret`을 한 행씩 선택한다. 각 행의 `seq`, 현재 `PC`, 변경된 상태와 값, 다음 `PC`를 보고서에 적는다.

`call`은 `sum_array` 안에서 `add_word`를 호출하는 행을 선택한다. `ret`은 `sum_array`가 `main`으로 복귀하는 행을 선택한다. `call`이 기록하는 반환 주소와 `ret`이 선택하는 다음 `PC`의 관계를 설명한다. 이 trace의 `seq`는 명령어 실행 순서를 나타낸다. 하드웨어 클록 사이클은 별도 모델에서 관찰한다.

## 3. 경계값 테스트 두 개

`tests/test_student_cases.py`의 두 메서드를 완성한다. 제공된 `run_sum`이 결과 레지스터와 trace를 반환한다.

| 테스트 | 입력 | 확인 항목 |
|---|---|---|
| `test_empty_array` | `[]` | 예상 `a0`, 실행 후 `a0`, 진입 시 `sp=0x800`의 복원 |
| `test_word_wraparound` | `[0xffffffff, 1]` | modulo-2^32 예상 `a0`, 실행 후 `a0`, `sp` 복원 |

각 테스트에서 `a0`와 `sp`를 실제 assertion으로 검사한다. 실행 전 예상값을 보고서에 적고 실행값과 비교한다. 혼합 부호 배열 등 추가 입력은 공개·교수자 검사에서 함께 확인한다.

## 4. ra 복원 생략 실험

먼저 보고서 4절에 다음 내용을 예측한다.

- `sum_array`의 마지막 `ret` 직전 `ra`에 남을 값
- `ret` 직후의 다음 `PC`와 그 주소의 명령어
- 이후 프로그램 실행에 나타날 영향

그다음 `make ra-experiment`를 실행한다. 제공 도구는 학생이 완성한 정상 소스에서 `ra`를 복원하는 `lw` 하나를 같은 크기의 `nop`으로 대체한 별도 실행본을 생성한다. 명령어 주소와 레이블을 유지하고, 해당 `ret` 실행 직후까지 관찰한다. 제출할 정상 어셈블리 원본은 그대로 보존한다.

복원 명령이 여러 개이면 `make ra-experiment RESTORE_LINE=행번호`로 `sum_array`의 해당 소스 행을 지정한다. 교수자 재실행에도 적용할 수 있도록 Makefile에 `RESTORE_LINE = 행번호`를 기록한다. 복원 명령이 하나인 구현은 기본 명령으로 실행한다.

| 생성 파일 | 용도 |
|---|---|
| `evidence/ra_experiment/normal_trace.csv` | 정상 프로그램의 전체 실행 |
| `evidence/ra_experiment/ra_omitted.s` | 복원 명령 하나를 `nop`으로 대체한 실행본 |
| `evidence/ra_experiment/ra_omitted_trace.csv` | 변경한 프로그램의 해당 `ret`까지 실행 |
| `evidence/ra_experiment/comparison.json` | 정상·변경본의 복귀 `PC` 비교 |

trace에서 예측한 주소와 실제 주소를 비교한다. 해당 `ret` 이후의 영향은 목적지 주소의 명령어와 레지스터 상태를 근거로 설명한다. 생성된 변형 소스는 실험 증거로 보관한다.

## 실행 순서

```bash
make setup-check
make test
make evidence
# report.md 4절의 실행 전 예측을 먼저 작성
make ra-experiment
```

`make test`는 공개 어셈블리 검사와 학생 테스트 두 개를 실행한다. `make test-c`는 제공된 C 참조 구현을 확인하는 선택 명령이다.

## 제출

과제 폴더에 다음 작성물을 포함한다.

- 완성한 `programs/state_contract.s`
- 완성한 `tests/test_student_cases.py`
- 네 절을 작성한 `report.md`와 `integrity.txt`
- `make evidence`와 `make ra-experiment`의 `evidence/` 산출물

제공된 C 참조 구현·도구·공개 검사는 함께 유지한다. 평가는 어셈블리 동작과 상태 보존, 네 사례의 trace 해석, 두 경계값 테스트, `ra` 실험의 예측·관측·원인 설명을 기준으로 한다. 기계어 필드 분석과 추가 C 구현은 선택 학습으로 활용한다.
