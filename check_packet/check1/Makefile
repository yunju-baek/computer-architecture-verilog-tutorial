# Verilog 점검 1 (CH01–CH05)
# 저장소 루트의 check_packet/check1/ 에서 실행한다. tutorial/ 은 ../../tutorial 이다.

IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
TUTORIAL ?= ../../tutorial
COMMON   := ../common
BUILD    := build
EVIDENCE := evidence
CHAPTERS := ch01 ch02 ch03 ch04 ch05
PROBES   := probe_ch01 probe_ch02 probe_ch03 probe_ch04 probe_ch05
ZIP       = ../verilog_check1_$(STUDENT_ID).zip

include student.mk
STUDENT_ID := $(strip $(STUDENT_ID))

# 예상값 검사에 필요한 원본 모듈
DUT_ch01 := $(TUTORIAL)/ch01/ex02_inverter.v
DUT_ch02 := $(TUTORIAL)/ch02/ex04_select.v
DUT_ch03 :=
DUT_ch04 := $(TUTORIAL)/ch04/ex02_default.v $(TUTORIAL)/ch04/ex01_mux4.v
DUT_ch05 := $(TUTORIAL)/ch05/ex03_control.v $(TUTORIAL)/ch05/ex02_blocking.v

.PHONY: help check-id setup-check tutorial-check $(CHAPTERS) probes $(PROBES) show-inputs test evidence package clean

help:
	@echo 'make setup-check    # 도구 4개와 tutorial 경로 확인, evidence/env.txt 기록'
	@echo 'make tutorial-check # ch01–ch05 자습서 검사 실행, 장별 로그 기록'
	@echo 'make show-inputs    # 학번에서 파생된 실험 입력값 표시'
	@echo 'make test           # setup-check + tutorial-check + 예상값 검사 5개'
	@echo 'make evidence       # test 뒤 evidence/manifest.txt 생성'
	@echo 'make package        # 제출용 zip 생성'
	@echo 'make clean          # build, evidence 삭제'

check-id:
	@test "$(STUDENT_ID)" != "000000000" || { echo 'FAIL student.mk 의 STUDENT_ID 에 학번 9자리를 적는다'; exit 1; }
	@printf '%s' '$(STUDENT_ID)' | grep -Eq '^[0-9]{9}$$' || { echo 'FAIL STUDENT_ID 는 숫자 9자리다: $(STUDENT_ID)'; exit 1; }

setup-check: check-id
	@command -v $(IVERILOG) >/dev/null || { echo 'FAIL iverilog 를 찾을 수 없다'; exit 1; }
	@command -v $(VVP)      >/dev/null || { echo 'FAIL vvp 를 찾을 수 없다'; exit 1; }
	@command -v git         >/dev/null || { echo 'FAIL git 을 찾을 수 없다'; exit 1; }
	@test -d $(TUTORIAL)/ch01 || { echo 'FAIL tutorial 경로를 찾을 수 없다: $(TUTORIAL)'; exit 1; }
	@mkdir -p $(EVIDENCE)
	@sh $(COMMON)/env_report.sh $(EVIDENCE)/env.txt $(STUDENT_ID) $(TUTORIAL)
	@cat $(EVIDENCE)/env.txt
	@echo 'READY check1'

tutorial-check: setup-check $(CHAPTERS)

$(CHAPTERS):
	@mkdir -p $(EVIDENCE)
	@$(MAKE) --no-print-directory -C $(TUTORIAL)/$@ test > $(EVIDENCE)/tutorial_$@.log 2>&1; \
	  rc=$$?; tail -1 $(EVIDENCE)/tutorial_$@.log; \
	  if [ $$rc -ne 0 ] || ! grep -q '^PASS $@' $(EVIDENCE)/tutorial_$@.log; then \
	    echo "FAIL $@ 자습서 검사. evidence/tutorial_$@.log 의 첫 오류를 확인한다"; exit 1; fi

show-inputs: check-id $(PROBES:%=show-%)

show-probe_%:
	@mkdir -p $(BUILD)
	@$(IVERILOG) $(IVFLAGS) -I $(COMMON) -I . -s probe_$* -o $(BUILD)/probe_$*.vvp $(DUT_$*) probes/probe_$*.v
	@$(VVP) $(BUILD)/probe_$*.vvp +STUDENT_ID=$(STUDENT_ID) 2>/dev/null | grep -E '^(===|INPUT|      )' | grep -v 'Time:' || true

probes: setup-check $(PROBES)

$(PROBES):
	@mkdir -p $(BUILD) $(EVIDENCE)
	@echo "=== $@ ==="
	@$(IVERILOG) $(IVFLAGS) -I $(COMMON) -I . -s $@ -o $(BUILD)/$@.vvp $(DUT_$(@:probe_%=%)) probes/$@.v
	@$(VVP) $(BUILD)/$@.vvp +STUDENT_ID=$(STUDENT_ID) > $(EVIDENCE)/$@.log 2>&1; \
	  rc=$$?; cat $(EVIDENCE)/$@.log; exit $$rc

test: check-id setup-check tutorial-check probes
	@echo 'PASS check1 전체'

evidence: test
	@sh $(COMMON)/manifest.sh $(STUDENT_ID) $(EVIDENCE)/manifest.txt \
	  student.mk predictions.vh report.md integrity.txt \
	  $(EVIDENCE)/env.txt $(EVIDENCE)/tutorial_*.log $(EVIDENCE)/probe_*.log
	@echo 'PASS evidence/manifest.txt'

package: evidence
	@rm -f $(ZIP)
	@cd .. && zip -qr verilog_check1_$(STUDENT_ID).zip check1 common -x 'check1/build/*' -x '*.DS_Store'
	@echo "PASS $(ZIP)"

clean:
	@rm -rf $(BUILD) $(EVIDENCE)
