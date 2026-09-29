# Verilog Check 2 (CH06–CH10)
# Run from check_packet_en/check2/ relative to repository root. tutorial is ../../tutorial_en.

IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
TUTORIAL ?= $(if $(wildcard ../../tutorial_en/ch06),../../tutorial_en,../../tutorial)
COMMON   := ../common
BUILD    := build
EVIDENCE := evidence
CHAPTERS := ch06 ch07 ch08 ch09 ch10
PROBES   := probe_ch06 probe_ch07 probe_ch08 probe_ch09 probe_ch10
ZIP       = ../verilog_check2_$(STUDENT_ID).zip

include student.mk
STUDENT_ID := $(strip $(STUDENT_ID))

# Original modules required for output prediction checks
DUT_ch06 := $(TUTORIAL)/ch06/ex03_generate.v
DUT_ch07 := $(TUTORIAL)/ch07/ex02_sync_read.v $(TUTORIAL)/ch07/ex04_fsm.v
DUT_ch08 := $(TUTORIAL)/ch08/ex01_dut.v
DUT_ch09 := $(TUTORIAL)/ch09/ex01_synthesizable.v
DUT_ch10 := $(TUTORIAL)/ch10/ex01_style.sv

.PHONY: help check-id setup-check tutorial-check $(CHAPTERS) probes $(PROBES) show-inputs boundary boundary-test test evidence package clean

help:
	@echo 'make setup-check    # Verify 4 tools and tutorial path, record evidence/env.txt'
	@echo 'make tutorial-check # Run ch06–ch10 tutorial tests, record per-chapter logs'
	@echo 'make show-inputs    # Display test inputs derived from student ID and 2 boundary values'
	@echo 'make boundary       # Copy tutorial/ch08/tb_ex03.v to tb_boundary.v (if absent)'
	@echo 'make boundary-test  # Run modified tb_boundary.v with 12 vectors and verify 2 required values'
	@echo 'make test           # setup-check + tutorial-check + 5 prediction checks + boundary-test'
	@echo 'make evidence       # Generate evidence/manifest.txt after test'
	@echo 'make package        # Create submission zip'
	@echo 'make clean          # Remove build and evidence directories'

check-id:
	@test "$(STUDENT_ID)" != "000000000" || { echo 'FAIL Specify 9-digit student ID in STUDENT_ID inside student.mk'; exit 1; }
	@printf '%s' '$(STUDENT_ID)' | grep -Eq '^[0-9]{9}$$' || { echo 'FAIL STUDENT_ID must be 9 digits: $(STUDENT_ID)'; exit 1; }

setup-check: check-id
	@command -v $(IVERILOG) >/dev/null || { echo 'FAIL iverilog not found'; exit 1; }
	@command -v $(VVP)      >/dev/null || { echo 'FAIL vvp not found'; exit 1; }
	@command -v git         >/dev/null || { echo 'FAIL git not found'; exit 1; }
	@test -d $(TUTORIAL)/ch06 || { echo 'FAIL tutorial path not found: $(TUTORIAL)'; exit 1; }
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
	    echo "FAIL $@ tutorial check. Inspect first error in evidence/tutorial_$@.log"; exit 1; fi

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
	@test -f tb_boundary.v || { cp $(TUTORIAL)/ch08/tb_ex03.v tb_boundary.v && echo 'Created tb_boundary.v. Update VECTOR_COUNT, 2 array elements, and PASS banner'; }
	@test -f tb_boundary.v && echo 'tb_boundary.v ready'

# probe_ch08 writes 2 required values to build/required_values.txt
boundary-test: probe_ch08
	@test -f tb_boundary.v || { echo 'FAIL tb_boundary.v not found. Generate via make boundary, then edit'; exit 1; }
	@mkdir -p $(BUILD) $(EVIDENCE)
	@echo '=== boundary-test ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/boundary.vvp $(TUTORIAL)/ch08/ex01_dut.v tb_boundary.v
	@$(VVP) $(BUILD)/boundary.vvp > $(EVIDENCE)/boundary.log 2>&1; rc=$$?; cat $(EVIDENCE)/boundary.log; \
	  test $$rc -eq 0 || { echo 'FAIL tb_boundary.v execution must complete with exit code 0'; exit 1; }
	@b10=$$(sed -n 1p $(BUILD)/required_values.txt); b11=$$(sed -n 2p $(BUILD)/required_values.txt); \
	  rows=$$(grep -cE '^ +[0-9]+ +[0-9a-f]{4} \|' $(EVIDENCE)/boundary.log); \
	  test "$$rows" = "12" || { echo "FAIL Vector rows must count 12 (currently $$rows)"; exit 1; }; \
	  grep -Eq "^ +10 +$$b10 \|" $(EVIDENCE)/boundary.log || { echo "FAIL Row 10 value must be $$b10"; exit 1; }; \
	  grep -Eq "^ +11 +$$b11 \|" $(EVIDENCE)/boundary.log || { echo "FAIL Row 11 value must be $$b11"; exit 1; }; \
	  grep -Eq '^PASS.*12' $(EVIDENCE)/boundary.log || { echo 'FAIL PASS banner must indicate vector count 12'; exit 1; }; \
	  echo "PASS boundary-test 12 vectors, [10]=$$b10 [11]=$$b11"

test: check-id setup-check tutorial-check probes boundary-test
	@echo 'PASS check2 all'

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
