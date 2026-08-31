# Computer Architecture Verilog Tutorial

부산대학교 컴퓨터구조 수업에서 사용하는 실행형 Verilog 자습서다. 학생은 Icarus Verilog로 RTL과 testbench를 컴파일하고, 시뮬레이션 결과와 VCD 파형을 확인하며 컴퓨터구조의 상태 전이와 데이터 이동을 학습한다.

## 학습 목표

- Verilog-2001의 조합논리와 순차논리 표현을 읽고 작성한다.
- `iverilog`와 `vvp`로 self-checking testbench를 실행한다.
- `PASS`·`FAIL`, VCD 파형, CSV trace를 회로 동작과 연결한다.
- 의도적 결함 예제의 컴파일 메시지와 신호 변화를 분석한다.

## 빠른 시작

필수 도구는 GNU Make와 Icarus Verilog다. GTKWave는 VCD 파형 관찰에 활용한다.

```bash
git clone https://github.com/yunju-baek/computer-architecture-verilog-tutorial.git
cd computer-architecture-verilog-tutorial
make setup-check
make test
```

전체 예제가 통과하면 마지막 행에 `PASS tutorial 전체`가 출력된다.

## 주요 명령

| 명령 | 기능 |
|---|---|
| `make setup-check` | `iverilog`와 `vvp` 설치 상태 확인 |
| `make test` | 10개 챕터의 정상 예제 실행 |
| `make errors` | 의도적 결함 예제와 진단 메시지 확인 |
| `make waves` | ch10 통합 예제의 VCD 생성 |
| `make clean` | 생성된 실행 산출물 정리 |
| `make package-check` | 공개 패키지 구조와 전체 예제 검증 |

세부 목차와 권장 학습 순서는 [tutorial/README.md](tutorial/README.md)에서 확인한다.

## 과제 공개 방식

과제 자료는 수업 진도와 LMS 공지에 맞추어 [`assignments/`](assignments/README.md)에 순차적으로 추가한다. 공개된 과제는 저장소의 commit과 Git tag로 버전을 고정한다.

공개 전 과제의 starter code와 testbench는 교수자 관리 저장소에서 보관한다. 이 공개 저장소의 Git 이력에는 공개 시점부터 해당 과제 파일을 추가한다.

## 도구 활용과 결과 책임

학생은 공식 문서, 참고 코드, 생성형 AI 등 수업에서 허용한 도구를 활용할 수 있다. 학생은 자신이 작성하거나 제출한 코드, testbench, 실행 결과와 설명의 정확성을 직접 확인하고 설명할 책임을 가진다.

## 공식 문서

- [Icarus Verilog Usage](https://steveicarus.github.io/iverilog/usage/index.html)
- [GTKWave Documentation](https://gtkwave.sourceforge.net/gtkwave.pdf)
- [RISC-V ISA Manual](https://github.com/riscv/riscv-isa-manual/releases)
