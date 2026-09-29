IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch07 ex01 memory ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_memory.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch07 ex02 sync read ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex02_sync_read.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch07 ex03 readmem ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex03_readmem.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch07 ex04 fsm ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex04_fsm.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo 'PASS ch07'

clean:
	@rm -rf $(BUILD)

# Below examples demonstrate memory and FSM pitfalls.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: concurrent read/write to same address ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_same_addr -o $(BUILD)/bad01.vvp bad01_same_addr.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: missing FSM default assignment ==='
	@$(IVERILOG) $(IVFLAGS) -s bad02_fsm_state -o $(BUILD)/bad02.vvp bad02_fsm_state.v
	@$(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: array index out of bounds ==='
	@$(IVERILOG) $(IVFLAGS) -s bad03_array_range -o $(BUILD)/bad03.vvp bad03_array_range.v
	@$(VVP) $(BUILD)/bad03.vvp
