IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors waves clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch08 ex01 skeleton ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_dut.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch08 ex02 failure handling ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex01_dut.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch08 ex03 boundary vectors ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex01_dut.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch08 ex04 random vectors ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex01_dut.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo '=== ch08 ex05 evidence artifacts ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex05 -o $(BUILD)/ex05.vvp ex01_dut.v tb_ex05.v
	@$(VVP) $(BUILD)/ex05.vvp
	@echo 'PASS ch08'

waves: test
	@test -f $(BUILD)/ex05.vcd
	@if command -v gtkwave >/dev/null; then gtkwave $(BUILD)/ex05.vcd >/dev/null 2>&1 & else echo 'VCD $(BUILD)/ex05.vcd'; fi

clean:
	@rm -rf $(BUILD) *.vcd *.csv

# Below examples demonstrate testbench pitfalls.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: sampling without edge hold delay ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_no_delay -o $(BUILD)/bad01.vvp ex01_dut.v bad01_no_delay.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: display without assertion check ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_display_only -o $(BUILD)/bad02.vvp bad02_display_only.v
	@$(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: fixed seed reproducibility ==='
	@$(IVERILOG) $(IVFLAGS) -s bad03_random_seed -o $(BUILD)/bad03.vvp bad03_random_seed.v
	@$(VVP) $(BUILD)/bad03.vvp
