IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch01 ex01 hello ==='
	@$(IVERILOG) $(IVFLAGS) -s ex01_hello -o $(BUILD)/ex01.vvp ex01_hello.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch01 ex02 inverter ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex02_inverter.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch01 ex03 gates ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex03_gates.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch01 ex04 display ==='
	@$(IVERILOG) $(IVFLAGS) -s ex04_display -o $(BUILD)/ex04.vvp ex04_display.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo 'PASS ch01'

# Below examples demonstrate compilation failure and warning diagnostics.
errors:
	@echo '=== bad01: missing semicolon, compilation failure expected ==='
	-@$(IVERILOG) $(IVFLAGS) -s bad01_missing_semicolon -o $(BUILD)/bad01.vvp bad01_missing_semicolon.v
	@echo '=== bad02: port width mismatch, warning expected ==='
	@mkdir -p $(BUILD)
	-@$(IVERILOG) $(IVFLAGS) -s bad02_port_width -o $(BUILD)/bad02.vvp bad02_port_width.v && $(VVP) $(BUILD)/bad02.vvp

clean:
	@rm -rf $(BUILD)
