# 과제 2 안내: 프로세서 구성 모듈

ALU, PC, 레지스터 파일, 즉치수 생성기, 디코더를 구현하고 모듈별 동작을 검증한다. 과제 자료는 학생 배포본의 `assignments/hw02/`에 있다. 제출 위치와 마감일은 LMS의 해당 과제 항목을 따른다.

## 수행 내용

1. `rtl/`의 5개 모듈을 완성한다. ALU에서는 10개 연산의 결과 선택 논리를 구현하고, carry·overflow·zero는 제공 코드로 계산한다.
2. PC의 `reset > load > enable > hold`, 레지스터 파일의 상승 에지 쓰기·조합 읽기·x0 규칙을 구현한다. 즉치수 형식과 디코더의 지원 명령어는 `CONTRACT.md`를 따른다.
3. `tests/tb_student_blocks.v`에 총 6개 이상의 검증을 작성한다. PC 우선순위, 레지스터 쓰기와 x0, 즉치수와 디코더를 포함하고 예상값을 assertion으로 검사한다.
4. 보고서 네 절에 모듈 입출력·동작 조건, 대표 파형, 학생 테스트, 재사용 점검을 기록한다. SRA와 SLT/SLTU의 결과를 설명하고, 학생 테스트 중 한 사례의 조건 변경 결과도 설명한다.

## 실행

Python 3.11 이상, GNU Make, Icarus Verilog를 사용한다. `assignments/hw02/`에서 실행한다.

```bash
make setup-check
make test-alu
make test-pc
make test-regfile
make test-decode
make student-test
make evidence
```

## 제출과 평가

완성한 `hw02` 폴더에 `rtl/`의 5개 파일, `tests/tb_student_blocks.v`, `report.md`, `integrity.txt`, `evidence/`를 포함한다. 실행 증거는 `alu.vcd`, `pc.vcd`, `regfile.vcd`, `decode.vcd`, `student_blocks.vcd`이다. 제공 도구와 공개 검사를 함께 유지한다.

배점은 구현 50점, 검증 30점, 보고서 20점으로 총 100점이다. 입력별 예상값과 파형의 관측값을 연결하여 설명한다. 활용한 자료·도구와 직접 검증한 범위를 `integrity.txt`에 기록한다.

완성한 ALU·레지스터 파일·즉치수 생성기·디코더는 포트를 유지하여 과제 3에서 재사용한다. PC 모듈은 이번 과제의 상태 제어 학습용이다. Python 산술·내적·누산기 분석은 선택 학습으로 활용한다.
