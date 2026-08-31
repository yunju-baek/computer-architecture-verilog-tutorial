IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors waves clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch08 ex01 골격 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_dut.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch08 ex02 실패 처리 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex01_dut.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch08 ex03 경계값 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex01_dut.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch08 ex04 무작위 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex01_dut.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo '=== ch08 ex05 증거 파일 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex05 -o $(BUILD)/ex05.vvp ex01_dut.v tb_ex05.v
	@$(VVP) $(BUILD)/ex05.vvp
	@echo 'PASS ch08'

waves: test
	@test -f $(BUILD)/ex05.vcd
	@if command -v gtkwave >/dev/null; then gtkwave $(BUILD)/ex05.vcd >/dev/null 2>&1 & else echo 'VCD $(BUILD)/ex05.vcd'; fi

clean:
	@rm -rf $(BUILD) *.vcd *.csv

# 아래 예제는 testbench 작성의 함정을 직접 보기 위한 것이다.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: 대기 없이 읽기 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_no_delay -o $(BUILD)/bad01.vvp ex01_dut.v bad01_no_delay.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: 기대값 없는 출력 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_display_only -o $(BUILD)/bad02.vvp bad02_display_only.v
	@$(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: seed 고정 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad03_random_seed -o $(BUILD)/bad03.vvp bad03_random_seed.v
	@$(VVP) $(BUILD)/bad03.vvp
