IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch03 ex01 operators ==='
	@$(IVERILOG) $(IVFLAGS) -s ex01_operators -o $(BUILD)/ex01.vvp ex01_operators.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch03 ex02 width rules ==='
	@$(IVERILOG) $(IVFLAGS) -s ex02_width_rules -o $(BUILD)/ex02.vvp ex02_width_rules.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch03 ex03 signed ==='
	@$(IVERILOG) $(IVFLAGS) -s ex03_signed -o $(BUILD)/ex03.vvp ex03_signed.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch03 ex04 shift ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex04_shift.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo '=== ch03 ex05 flags ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex05 -o $(BUILD)/ex05.vvp ex05_flags.v tb_ex05.v
	@$(VVP) $(BUILD)/ex05.vvp
	@echo 'PASS ch03'

clean:
	@rm -rf $(BUILD)

# Below examples demonstrate operational pitfalls.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: operator precedence ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_precedence -o $(BUILD)/bad01.vvp bad01_precedence.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: unsigned comparison ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_unsigned_compare -o $(BUILD)/bad02.vvp bad02_unsigned_compare.v
	@$(VVP) $(BUILD)/bad02.vvp
