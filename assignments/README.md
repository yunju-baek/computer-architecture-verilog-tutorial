# 학생 과제: HW01–HW02

공개 과제는 HW01과 HW02이다. 아래 안내에서 구현 범위·검증 명령·제출 파일을 확인한다. 보고서는 과제별 네 절이며, 각 과제의 배점은 구현 50점·검증 30점·보고서 20점으로 총 100점이다. 마감과 제출 형식은 LMS의 해당 과제 항목을 따른다.

| 과제 | 주제 | 안내 | LMS 게시문 |
|---|---|---|---|
| HW01 | 함수 호출과 아키텍처 상태 | [README](hw01/README.md) | [LMS 안내](hw01/lms_announcement.md) |
| HW02 | 프로세서 구성 모듈 | [README](hw02/README.md) | [LMS 안내](hw02/lms_announcement.md) |

## 실행

Python 3.11 이상과 GNU Make를 사용하며, HW02에는 Icarus Verilog가 필요하다. 각 과제 폴더에서 `make setup-check`를 실행한다. 미완성 starter는 구현 후 `make test`를 통과하도록 구성한다. 실행 증거를 생성하고 보고서와 `integrity.txt`에 수행 내용을 기록한다.

제공 도구와 공개 검사를 유지한다. 활용한 자료·도구를 기록하고 제출 코드와 결과를 직접 검증하고 설명한다. `make clean` 실행 전 제출용 증거를 별도로 보관한다.

## 이후 과제 미리보기

- HW03: 구성 모듈을 연결하여 단일사이클 프로세서의 데이터 이동과 상태 갱신을 학습한다.
- HW04: 파이프라인의 데이터 의존성과 실행 성능을 학습한다.

HW03·HW04는 주제와 학습 목표를 소개하는 단계이다. 구현 자료·테스트·상세 명세·보고서 양식은 각 과제의 공개 시점에 제공한다.

[한국어 ZIP](../downloads/archlab-hw01-hw02-ko.zip) · [English assignments](../assignments_en/README.md) · [저장소 안내](../README.md)
