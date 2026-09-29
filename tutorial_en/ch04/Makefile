IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch04 ex01 mux4 ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_mux4.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch04 ex02 default ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex02_default.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch04 ex03 priority ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex03_priority.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch04 ex04 function ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex04_function.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo 'PASS ch04'

clean:
	@rm -rf $(BUILD)

# Below examples demonstrate combinational logic pitfalls.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: missing branch causes latch state ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_latch -o $(BUILD)/bad01.vvp bad01_latch.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: missing default ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_incomplete_case -o $(BUILD)/bad02.vvp bad02_incomplete_case.v
	@$(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: incomplete sensitivity list ==='
	@$(IVERILOG) $(IVFLAGS) -s bad03_sensitivity -o $(BUILD)/bad03.vvp bad03_sensitivity.v
	@$(VVP) $(BUILD)/bad03.vvp
