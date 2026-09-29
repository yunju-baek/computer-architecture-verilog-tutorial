IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch09 ex01 synthesizable constructs ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_synthesizable.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch09 ex02 RTL vs simulation-only comparison ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex02_compare.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo 'PASS ch09'

clean:
	@rm -rf $(BUILD)

# Below examples demonstrate non-synthesizable constructs to avoid.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: delay statements in design code ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_delay -o $(BUILD)/bad01.vvp bad01_delay.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: variable-iteration while loop ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_while -o $(BUILD)/bad02.vvp bad02_while.v
	@$(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: non-constant division and modulus ==='
	@$(IVERILOG) $(IVFLAGS) -s bad03_division -o $(BUILD)/bad03.vvp bad03_division.v
	@$(VVP) $(BUILD)/bad03.vvp
