# 과제 1 안내: 함수 호출과 아키텍처 상태

RV32I 어셈블리로 배열 합산 함수를 구현하고, 함수 호출 전후의 PC·레지스터·스택 변화를 설명한다. 과제 자료는 학생 배포본의 `assignments/hw01/`에 있다. 제출 위치와 마감일은 LMS의 해당 과제 항목을 따른다.

## 수행 내용

1. `programs/state_contract.s`의 `add_word`와 `sum_array`를 완성한다. 중첩 호출에서 필요한 값을 보존하고 복귀 시 `ra`, `sp`, 사용한 `s0`–`s2`를 복원한다. C 코드는 제공된 참조 구현을 사용한다.
2. 실행 trace에서 `call`, 배열 적재 `lw`, 스택 저장 `sw`, `ret`을 각각 한 행씩 선택한다. `call`은 `sum_array` 내부의 `add_word` 호출, `ret`은 `sum_array`에서 `main`으로 복귀하는 행을 선택한다. 네 사례의 현재 PC·변경 상태·다음 PC를 설명한다.
3. `tests/test_student_cases.py`에서 빈 배열 `[]`과 wraparound 입력 `[0xffffffff, 1]`을 검사한다. 실행 전 예상값을 기록하고, 두 테스트에서 `a0`와 `sp`를 assertion으로 확인한다.
4. 보고서에 `ra` 복원 생략의 영향을 먼저 예측한 뒤 실험을 실행한다. 도구가 생성한 별도 소스의 결과와 정상 실행을 비교한다. 제출할 정상 소스는 보존한다.

## 실행

`assignments/hw01/`에서 실행한다. Python 3.11 이상과 GNU Make가 필요하다.

```bash
make setup-check
make test
make evidence
# report.md 4절에 실행 전 예측을 기록한 뒤 실행
make ra-experiment
```

복원 명령이 여러 개이면 README의 `RESTORE_LINE` 지정 절차를 따른다. `make test-c`와 추가 C 구현·기계어 필드 분석은 선택 학습이다.

## 제출과 평가

완성한 `hw01` 폴더에 다음 파일을 포함한다.

- `programs/state_contract.s`, `tests/test_student_cases.py`
- 네 절을 작성한 `report.md`, 검증·책임 기록인 `integrity.txt`
- 정상 trace와 `ra` 실험 결과를 포함한 `evidence/`

제공된 C 참조·실행 도구·공개 검사는 함께 유지한다. 배점은 구현 50점, 검증 30점, 보고서 20점으로 총 100점이다. 자동 검사 결과와 함께 코드, 예상값, trace 해석, 실험의 원인 설명을 평가한다. 활용한 자료·도구를 기록하고 제출 결과를 직접 검증한다.
