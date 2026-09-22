# Computer Architecture Verilog Tutorial

부산대학교 컴퓨터구조 수업에서 사용하는 실행형 Verilog 자습서다. 학생은 Icarus Verilog로 RTL과 testbench를 컴파일하고, 시뮬레이션 결과와 VCD 파형을 확인하며 컴퓨터구조의 상태 전이와 데이터 이동을 학습한다.

웹에서 읽는 장별 자습서는 **[컴퓨터구조를 위한 Verilog 웹북](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/)**에서 제공한다.

## 학습 목표

- Verilog-2001의 조합논리와 순차논리 표현을 읽고 작성한다.
- `iverilog`와 `vvp`로 self-checking testbench를 실행한다.
- `PASS`·`FAIL`, VCD 파형, CSV trace를 회로 동작과 연결한다.
- 의도적 결함 예제의 컴파일 메시지와 신호 변화를 분석한다.

## 빠른 시작

필수 도구는 Git, GNU Make와 Icarus Verilog다. 웹북 생성에는 Python 3을 사용한다. GTKWave는 VCD 파형 관찰에 사용하는 선택 도구다. 아래 명령은 macOS, Linux, WSL의 POSIX 셸 형식을 따른다.

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
| `make errors` | 의도적 결함과 컴파일 진단을 학습 출력으로 확인 |
| `make waves` | `tutorial/ch10/build/overview.vcd` 생성과 GTKWave 연동 |
| `make webbook` | 12페이지 정적 웹북 생성과 링크 검증 |
| `make webbook-check` | Python 문법, 새 웹북 빌드와 페이지 수 검증 |
| `make clean` | Verilog와 웹북 생성물 정리 |
| `make package-check` | 공개 패키지, 전체 예제와 웹북 검증 |
| `make check-packet-verify` | 점검 과제 probe 10개의 컴파일 확인 |

세부 목차와 권장 학습 순서는 [tutorial/README.md](tutorial/README.md)에서 확인한다.

## 웹북 생성과 배포

웹북 12페이지는 시작 페이지, ch01~ch10과 빠른 참조 부록으로 구성된다. 본문을 수정할 때는 `tutorial/**/README.md`를 편집한다. `drafts/book/`은 안정적인 페이지 ID, 제목, 별칭과 학습 요약을 관리한다. `publish/webbook/`은 빌드할 때마다 생성되는 HTML 결과다.

릴리스 검증 명령인 `make webbook-check`는 웹북 생성 과정을 포함하며 HTML, 검색 색인과 사이트맵을 `publish/webbook/`에 만든다.

```bash
make webbook-check
```

`main` 브랜치의 GitHub Pages workflow는 Verilog 전체 예제와 웹북 검증을 통과한 결과를 자동 배포한다.

이 저장소의 검증 범위는 Icarus Verilog 시뮬레이션, `PASS` 판정, VCD와 CSV trace다. 합성과 FPGA 구현은 별도 도구와 검증 단계에서 다룬다.

## 과제 공개 방식

과제 자료는 수업 진도와 LMS 공지에 맞추어 [`assignments/`](assignments/README.md)에 순차적으로 추가한다. 공개된 과제는 저장소의 commit과 Git tag로 버전을 고정한다.

공개 전 과제의 starter code와 testbench는 교수자 관리 저장소에서 보관한다. 이 공개 저장소의 Git 이력에는 공개 시점부터 해당 과제 파일을 추가한다.

## 점검 과제

자습서 CH01–CH05, CH06–CH10의 설명 수업 뒤에 제출하는 점검 과제 2개가 [`check_packet/`](check_packet/README.md)에 있다. 각 점검은 `make setup-check`로 도구 설치를 확인하고, 해당 구간 5개 장의 `make test`를 실행한 뒤, 학번에서 파생된 입력에 대한 예상값을 `predictions.vh`에 적어 실행 결과와 대조한다. `make package`가 제출용 zip을 만든다.

```bash
cd check_packet/check1
make setup-check
make show-inputs
make test
make package
```

## 도구 활용과 결과 책임

학생은 공식 문서, 참고 코드, 생성형 AI 등 수업에서 허용한 도구를 활용할 수 있다. 허용 범위와 제출 규약은 해당 과제의 LMS 공지를 최종 기준으로 삼는다. 학생은 자신이 작성하거나 제출한 코드, testbench, 실행 결과와 설명의 정확성을 직접 확인하고 설명할 책임을 가진다.

## 공식 문서

- [Icarus Verilog Usage](https://steveicarus.github.io/iverilog/usage/index.html)
- [GTKWave Documentation](https://gtkwave.sourceforge.net/gtkwave.pdf)
- [RISC-V ISA Manual](https://github.com/riscv/riscv-isa-manual/releases)
