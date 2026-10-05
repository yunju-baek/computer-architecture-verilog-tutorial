# HW02: 프로세서 구성 모듈

ALU, PC, 레지스터 파일, 즉치수 생성기, 디코더를 구현하고 모듈별 파형으로 검증한다. 이 중 ALU·레지스터 파일·즉치수 생성기·디코더의 네 모듈은 HW03에서 포트를 유지하여 재사용한다.

## 1. 구현 범위

| 파일 | 학생 구현 | 주요 동작 조건 |
|---|---|---|
| `rtl/alu.v` | `result` 선택 논리 | 32비트 10개 연산, 기본 결과 0 |
| `rtl/pc_counter.v` | 클록에 따른 상태 갱신 | reset > load > enable > hold |
| `rtl/regfile.v` | 32개 레지스터, 읽기·쓰기 | 상승 에지 쓰기, 조합 읽기 2포트, x0=0 |
| `rtl/rv32i_immgen.v` | 즉치수 비트 조립 | I·S·B·U·J 형식 |
| `rtl/rv32i_decode.v` | 명령어별 제어 신호 | 포트·상수·지원 명령은 제공 소스와 공개 검사 기준 |

ALU 연산 코드는 `0:ADD, 1:SUB, 2:AND, 3:OR, 4:XOR, 5:SLL, 6:SRL, 7:SRA, 8:SLT, 9:SLTU`이다. 시프트 양은 `b[4:0]`을 사용한다. `SRA`, `SLT`에서는 피연산자를 signed 값으로 해석한다. ALU의 carry·overflow·zero는 제공 코드로 계산한다. carry와 overflow의 차이는 강의 확인 문제로 학습한다.

조합논리는 기본 출력을 먼저 지정하고, 순차논리의 상태는 nonblocking assignment(논블로킹 대입)로 갱신한다. 모듈명과 포트를 유지한다. 레지스터 파일의 읽기·쓰기 규칙과 지원 명령어는 제공 testbench에서 확인한다.

## 2. 실행과 학생 테스트

```bash
make setup-check
make test-alu
make test-pc
make test-regfile
make test-decode
make student-test
make evidence
```

`tests/tb_student_blocks.v`에 총 6개 이상의 검증 사례를 작성한다. PC 제어 우선순위, 레지스터 파일의 x0·쓰기 동작, 즉치수와 디코더를 포함한다. 입력마다 실행 전 기대값을 정하고 assertion으로 관측값을 비교한다. 같은 사례를 활용하여 보고서의 조건 변경 결과를 설명한다.

ALU 공개 검사는 10개 연산, 시프트 양의 하위 5비트, signed 경계와 기본 출력을 확인한다. 학생은 파형 중 SRA와 SLT/SLTU 사례를 골라 해석한다.

## 3. 보고서와 제출

[report.md](report.md)의 모듈 입출력·동작 조건, 대표 파형, 학생 테스트, HW03 재사용 점검 등 네 절을 작성한다. 대표 파형은 입력·출력·클록의 관계가 드러나는 사례를 선택한다.

제출물은 `rtl/`의 5개 파일, `tests/tb_student_blocks.v`, `report.md`, `integrity.txt`, `evidence/`이다. 증거 파일은 `alu.vcd`, `pc.vcd`, `regfile.vcd`, `decode.vcd`, `student_blocks.vcd`이다. 제공 도구와 공개 검사를 함께 유지한다.

## 4. 재사용과 선택 자료

`alu.v`, `regfile.v`, `rv32i_immgen.v`, `rv32i_decode.v`를 HW03으로 복사한다. PC 모듈은 상태 제어 학습용이며 HW03 코어는 자체 PC 갱신을 구현한다. HW03 공개 시 모듈 연결 절차를 안내한다.

[Verilog 자습서](../../tutorial/README.md)의 ch02–ch05, ch07–ch08을 참고한다. [산술 참조](../../tutorial/arithmetic_reference/README.md)는 완성된 Python 코드와 선택 실습이다. Python 구현·내적 분석은 선택 학습으로 수행하며, 해당 결과의 별도 제출도 선택 사항이다.

세부 포트·제어 코드·지원 명령어는 [인터페이스 명세](CONTRACT.md)를 따른다.

[LMS 안내문](lms_announcement.md)
