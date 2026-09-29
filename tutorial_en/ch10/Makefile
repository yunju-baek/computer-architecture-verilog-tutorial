IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors waves clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch10 ex01 syntax comparison ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_style.sv tb_ex01.sv
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch10 ex02 data types ==='
	@$(IVERILOG) $(IVFLAGS) -s ex02_enum_struct -o $(BUILD)/ex02.vvp ex02_enum_struct.sv
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch10 ex03 always_comb ==='
	@$(IVERILOG) $(IVFLAGS) -s ex03_always_comb -o $(BUILD)/ex03.vvp ex03_always_comb.sv
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch10 overview example ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_overview -o $(BUILD)/overview.vvp overview.sv tb_overview.sv
	@$(VVP) $(BUILD)/overview.vvp
	@echo 'PASS ch10'

waves: test
	@test -f $(BUILD)/overview.vcd
	@if command -v gtkwave >/dev/null; then gtkwave $(BUILD)/overview.vcd >/dev/null 2>&1 & else echo 'VCD $(BUILD)/overview.vcd'; fi

clean:
	@rm -rf $(BUILD)
