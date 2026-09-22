# Verilog 점검 2 (CH06–CH10)
# 저장소 루트의 check_packet/check2/ 에서 실행한다. tutorial/ 은 ../../tutorial 이다.

IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
TUTORIAL ?= ../../tutorial
COMMON   := ../common
BUILD    := build
EVIDENCE := evidence
CHAPTERS := ch06 ch07 ch08 ch09 ch10
PROBES   := probe_ch06 probe_ch07 probe_ch08 probe_ch09 probe_ch10
ZIP       = ../verilog_check2_$(STUDENT_ID).zip

include student.mk
STUDENT_ID := $(strip $(STUDENT_ID))

# 예상값 검사에 필요한 원본 모듈
DUT_ch06 := $(TUTORIAL)/ch06/ex03_generate.v
DUT_ch07 := $(TUTORIAL)/ch07/ex02_sync_read.v $(TUTORIAL)/ch07/ex04_fsm.v
DUT_ch08 := $(TUTORIAL)/ch08/ex01_dut.v
DUT_ch09 := $(TUTORIAL)/ch09/ex01_synthesizable.v
DUT_ch10 := $(TUTORIAL)/ch10/ex01_style.sv

.PHONY: help check-id setup-check tutorial-check $(CHAPTERS) probes $(PROBES) show-inputs boundary boundary-test test evidence package clean

help:
	@echo 'make setup-check    # 도구 4개와 tutorial 경로 확인, evidence/env.txt 기록'
	@echo 'make tutorial-check # ch06–ch10 자습서 검사 실행, 장별 로그 기록'
	@echo 'make show-inputs    # 학번에서 파생된 실험 입력값과 경계값 2개 표시'
	@echo 'make boundary       # tutorial/ch08/tb_ex03.v 를 tb_boundary.v 로 복사 (없을 때만)'
	@echo 'make boundary-test  # 수정한 tb_boundary.v 를 12개 벡터로 실행하고 필수 값 2개 확인'
	@echo 'make test           # setup-check + tutorial-check + 예상값 검사 5개 + boundary-test'
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
	@test -d $(TUTORIAL)/ch06 || { echo 'FAIL tutorial 경로를 찾을 수 없다: $(TUTORIAL)'; exit 1; }
	@mkdir -p $(EVIDENCE)
	@sh $(COMMON)/env_report.sh $(EVIDENCE)/env.txt $(STUDENT_ID) $(TUTORIAL)
	@cat $(EVIDENCE)/env.txt
	@echo 'READY check2'

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
	@$(VVP) $(BUILD)/probe_$*.vvp +STUDENT_ID=$(STUDENT_ID) 2>/dev/null | grep -E '^(===|INPUT|REQUIRED|      )' | grep -v 'Time:' || true

probes: setup-check $(PROBES)

$(PROBES):
	@mkdir -p $(BUILD) $(EVIDENCE)
	@echo "=== $@ ==="
	@$(IVERILOG) $(IVFLAGS) -I $(COMMON) -I . -s $@ -o $(BUILD)/$@.vvp $(DUT_$(@:probe_%=%)) probes/$@.v
	@$(VVP) $(BUILD)/$@.vvp +STUDENT_ID=$(STUDENT_ID) > $(EVIDENCE)/$@.log 2>&1; \
	  rc=$$?; cat $(EVIDENCE)/$@.log; exit $$rc

boundary:
	@test -f tb_boundary.v || { cp $(TUTORIAL)/ch08/tb_ex03.v tb_boundary.v && echo 'tb_boundary.v 를 만들었다. VECTOR_COUNT, 배열 원소 2개, PASS 표시를 고친다'; }
	@test -f tb_boundary.v && echo 'tb_boundary.v 준비됨'

# probe_ch08 이 build/required_values.txt 에 필수 값 2개를 남긴다.
boundary-test: probe_ch08
	@test -f tb_boundary.v || { echo 'FAIL tb_boundary.v 가 없다. make boundary 로 만든 뒤 수정한다'; exit 1; }
	@mkdir -p $(BUILD) $(EVIDENCE)
	@echo '=== boundary-test ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/boundary.vvp $(TUTORIAL)/ch08/ex01_dut.v tb_boundary.v
	@$(VVP) $(BUILD)/boundary.vvp > $(EVIDENCE)/boundary.log 2>&1; rc=$$?; cat $(EVIDENCE)/boundary.log; \
	  test $$rc -eq 0 || { echo 'FAIL tb_boundary.v 실행이 종료 코드 0으로 끝나야 한다'; exit 1; }
	@b10=$$(sed -n 1p $(BUILD)/required_values.txt); b11=$$(sed -n 2p $(BUILD)/required_values.txt); \
	  rows=$$(grep -cE '^ +[0-9]+ +[0-9a-f]{4} \|' $(EVIDENCE)/boundary.log); \
	  test "$$rows" = "12" || { echo "FAIL 벡터 행이 12개여야 한다 (현재 $$rows)"; exit 1; }; \
	  grep -Eq "^ +10 +$$b10 \|" $(EVIDENCE)/boundary.log || { echo "FAIL 10번 행의 값은 $$b10 이어야 한다"; exit 1; }; \
	  grep -Eq "^ +11 +$$b11 \|" $(EVIDENCE)/boundary.log || { echo "FAIL 11번 행의 값은 $$b11 이어야 한다"; exit 1; }; \
	  grep -Eq '^PASS.*12' $(EVIDENCE)/boundary.log || { echo 'FAIL PASS 표시에 벡터 개수 12 가 들어가야 한다'; exit 1; }; \
	  echo "PASS boundary-test 12 vectors, [10]=$$b10 [11]=$$b11"

test: check-id setup-check tutorial-check probes boundary-test
	@echo 'PASS check2 전체'

evidence: test
	@sh $(COMMON)/manifest.sh $(STUDENT_ID) $(EVIDENCE)/manifest.txt \
	  student.mk predictions.vh tb_boundary.v report.md integrity.txt \
	  $(EVIDENCE)/env.txt $(EVIDENCE)/tutorial_*.log $(EVIDENCE)/probe_*.log $(EVIDENCE)/boundary.log
	@echo 'PASS evidence/manifest.txt'

package: evidence
	@rm -f $(ZIP)
	@cd .. && zip -qr verilog_check2_$(STUDENT_ID).zip check2 common -x 'check2/build/*' -x '*.DS_Store'
	@echo "PASS $(ZIP)"

clean:
	@rm -rf $(BUILD) $(EVIDENCE)
