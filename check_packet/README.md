# Verilog 점검 과제

Verilog 자습서 CH01–CH10을 두 구간으로 나누어 자습하고, 설명 수업 뒤에 점검 과제를 제출한다. 점검은 자신의 컴퓨터에서 도구를 설치해 자습서를 실행했는지, 각 장의 원본 코드를 읽고 출력을 예상할 수 있는지를 실행 결과로 확인한다.

| 점검 | 자습 범위 | 실행 확인 | 예상값 | 추가 작업 |
|---|---|---|---:|---|
| [점검 1](check1/README.md) | CH01–CH05 | 도구 4개 버전, 자습서 ch01–ch05 | 20 | 없음 |
| [점검 2](check2/README.md) | CH06–CH10 | 자습서 ch06–ch10 | 17 | 경계값 testbench 12개로 확장 |

## 학번으로 달라지는 입력

`student.mk`에 적은 학번에서 모든 실험 입력값이 파생된다. 같은 원본 코드를 읽어도 학번마다 계산할 값이 다르므로, 자신의 학번으로 실행해 통과한 결과만 인정된다. 교수자는 제출물을 새 폴더에 풀어 `make test`를 다시 실행하고, 제출된 로그와 해시 목록을 재실행 결과와 대조한다.

## 파일 배치

이 폴더는 튜토리얼 저장소 루트의 `check_packet/`이다. 저장소를 이미 받은 학생은 저장소 루트에서 `git pull`로 받는다. LMS의 zip으로 받은 경우 같은 위치에 `check_packet` 이름으로 둔다. 명령은 Bash 계열 터미널(macOS, Linux, WSL)에서 실행한다.

```bash
cd computer-architecture-verilog-tutorial
git pull
ls check_packet
```

`student.mk`나 `predictions.vh`를 고친 뒤에 `git pull`이 충돌을 알리면 `git stash`, `git pull`, `git stash pop` 순으로 실행한다. `build/`, `evidence/`, zip, `tb_boundary.v`는 저장소가 무시하므로 `git status`에 나타나지 않는다.

```text
저장소 루트/
  tutorial/
    ch01/ ... ch10/
  activity_packet/            ← LMS에서 받은 이전 배포 (설치 안내, 설명자료 PDF). 선택
  check_packet/
    README.md
    common/                   ← 공통 함수·스크립트. 그대로 둔다
    check1/
      Makefile  student.mk  predictions.vh  report.md  integrity.txt  probes/
    check2/
      Makefile  student.mk  predictions.vh  report.md  integrity.txt  probes/
```

## 공통 명령

각 점검 폴더에서 실행한다.

```bash
make setup-check      # 도구 확인, evidence/env.txt
make tutorial-check   # 해당 구간 자습서 5개 장 실행
make show-inputs      # 학번에서 파생된 입력값
make test             # 예상값 검사 (점검 2는 boundary-test 포함)
make evidence         # evidence/manifest.txt
make package          # ../verilog_checkN_<학번>.zip
make clean
```

`make test`가 실패하면 마지막 `FAIL` 또는 `UNANSWERED` 줄이 고칠 곳을 가리킨다. `evidence/` 아래 로그에 전체 출력이 남는다.

## 제출

`make package`가 만든 `verilog_check1_<학번>.zip`, `verilog_check2_<학번>.zip`을 LMS에 올린다. 마감과 성적 반영은 LMS 공지를 따른다.

실행 문제가 끝까지 남은 경우에도 `make evidence`가 만들어진 범위까지 묶고, `report.md` 첫 절에 재현 명령·첫 오류·시도한 해결을 적어 제출한다. 재현 조건과 원인 추정이 근거가 된다.

튜토리얼 대조 버전: `da729b3`. 점검 과제 공개 버전은 저장소 tag `tutorial-v1.2.0`이다.
