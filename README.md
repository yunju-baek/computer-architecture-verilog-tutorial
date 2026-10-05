# Computer Architecture Verilog Tutorial

[ 🇰🇷 한국어 ](README.md) | [ 🇺🇸 English ](README.en.md) | [ 🌐 웹북 (KO) ](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/) | [ 🌐 Webbook (EN) ](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/en/)

부산대학교 컴퓨터구조 수업에서 사용하는 실행형 Verilog 자습서다. 학생은 Icarus Verilog로 RTL과 testbench를 컴파일하고, 시뮬레이션 결과와 VCD 파형을 확인하며 컴퓨터구조의 상태 전이와 데이터 이동을 학습한다.

웹에서 읽는 장별 자습서는 **[컴퓨터구조를 위한 Verilog 웹북](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/)**(영문판: [Webbook in English](https://yunju-baek.github.io/computer-architecture-verilog-tutorial/en/))에서 제공한다. 웹북 상단 우측의 언어 선택기(`[KO | EN]`)를 누르면 해당 페이지의 한국어판과 영어판을 즉시 전환할 수 있다.

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
make test       # 한국어 자습서 트리 검증
make test-en    # 영어 자습서 트리 검증
```

전체 예제가 통과하면 마지막 행에 `PASS tutorial 전체` 또는 `PASS tutorial all`이 출력된다.

## 주요 명령

| 명령 | 기능 |
|---|---|
| `make setup-check` | `iverilog`와 `vvp` 설치 상태 확인 |
| `make test` | 10개 챕터의 정상 예제 실행 (한국어 트리) |
| `make test-en` | 10개 챕터의 정상 예제 실행 (영어 트리) |
| `make errors` | 의도적 결함과 컴파일 진단을 학습 출력으로 확인 |
| `make waves` | `tutorial/ch10/build/overview.vcd` 생성과 GTKWave 연동 |
| `make webbook` | 24페이지 다국어(한국어/영어) 정적 웹북 생성과 링크 검증 |
| `make webbook-check` | Python 문법, 새 웹북 빌드와 페이지 수(24개) 검증 |
| `make clean` | Verilog와 웹북 생성물 정리 |
| `make package-check` | 공개 패키지, 전체 예제와 웹북 검증 |
| `make check-packet-verify` | 점검 과제 probe 10개의 컴파일 확인 |

세부 목차와 권장 학습 순서는 한국어 [tutorial/README.md](tutorial/README.md) 및 영어 [tutorial_en/README.md](tutorial_en/README.md)에서 확인한다.

## 웹북 생성과 배포

웹북은 한국어 12페이지(시작 페이지, ch01~ch10, 빠른 참조 부록)와 영어 12페이지를 합쳐 총 24페이지로 구성된다. 본문을 수정할 때는 `tutorial/**/README.md`(한국어) 및 `tutorial_en/**/README.md`(영어)를 편집한다. `drafts/book/`은 안정적인 페이지 ID, 제목, 별칭과 학습 요약을 관리한다. `publish/webbook/`은 빌드할 때마다 생성되는 HTML 결과다.

릴리스 검증 명령인 `make webbook-check`는 웹북 생성 과정을 포함하며 HTML, 언어별 검색 색인과 사이트맵을 `publish/webbook/`에 만든다.

```bash
make webbook-check
```

`main` 브랜치의 GitHub Pages workflow는 Verilog 전체 예제와 웹북 검증을 통과한 결과를 자동 배포한다.

이 저장소의 검증 범위는 Icarus Verilog 시뮬레이션, `PASS` 판정, VCD와 CSV trace다. 합성과 FPGA 구현은 별도 도구와 검증 단계에서 다룬다.

## 학생 과제

현재 공개 범위는 **HW01·HW02**이다. 한국어 자료는 [assignments/](assignments/README.md), 영어 자료는 [assignments_en/](assignments_en/README.md)에 있다. 각 폴더에는 starter code, 공개 검사, 보고서 양식과 LMS 안내문을 제공한다.

- [한국어 HW01–HW02 ZIP](downloads/archlab-hw01-hw02-ko.zip)
- [English HW01–HW02 ZIP](downloads/archlab-hw01-hw02-en.zip)

두 과제는 각각 구현 50점·검증 30점·보고서 20점으로 평가한다. 제출 마감은 LMS를 따른다. 과제 실행에는 Python 3.11 이상을 사용한다.

HW03은 단일사이클 코어 통합, HW04는 파이프라인 의존성·성능을 학습한다. 두 과제는 주제 소개만 제공하며, 구현 자료와 상세 명세는 추후 공개한다.

## 점검 과제

자습서 CH01–CH05, CH06–CH10의 설명 수업 뒤에 제출하는 점검 과제 2개가 한국어 패키지 [`check_packet/`](check_packet/README.md)와 영어 패키지 [`check_packet_en/`](check_packet_en/README.md)로 제공된다. 각 점검은 `make setup-check`로 도구 설치를 확인하고, 해당 구간 5개 장의 `make test`를 실행한 뒤, 학번에서 파생된 입력에 대한 예상값을 `predictions.vh`에 적어 실행 결과와 대조한다. `make package`가 제출용 zip을 만든다.

```bash
# 한국어 점검 과제
cd check_packet/check1
make setup-check
make show-inputs
make test
make package

# English Edition
cd check_packet_en/check1
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
