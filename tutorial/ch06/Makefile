IVERILOG ?= iverilog
VVP      ?= vvp
IVFLAGS  ?= -g2012 -Wall
BUILD    := build

.PHONY: test errors clean

test:
	@mkdir -p $(BUILD)
	@echo '=== ch06 ex01 hierarchy ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex01 -o $(BUILD)/ex01.vvp ex01_hierarchy.v tb_ex01.v
	@$(VVP) $(BUILD)/ex01.vvp
	@echo '=== ch06 ex02 connection ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex02 -o $(BUILD)/ex02.vvp ex02_connection.v tb_ex02.v
	@$(VVP) $(BUILD)/ex02.vvp
	@echo '=== ch06 ex03 generate ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex03 -o $(BUILD)/ex03.vvp ex03_generate.v tb_ex03.v
	@$(VVP) $(BUILD)/ex03.vvp
	@echo '=== ch06 ex04 generate if ==='
	@$(IVERILOG) $(IVFLAGS) -s tb_ex04 -o $(BUILD)/ex04.vvp ex04_generate_if.v tb_ex04.v
	@$(VVP) $(BUILD)/ex04.vvp
	@echo 'PASS ch06'

clean:
	@rm -rf $(BUILD)

# 아래 예제는 계층 연결의 함정을 직접 보기 위한 것이다.
errors:
	@mkdir -p $(BUILD)
	@echo '=== bad01: 순서 기반 연결의 순서 실수 ==='
	@$(IVERILOG) $(IVFLAGS) -s bad01_positional -o $(BUILD)/bad01.vvp bad01_positional.v
	@$(VVP) $(BUILD)/bad01.vvp
	@echo '=== bad02: 포트 미연결 ==='
	-@$(IVERILOG) $(IVFLAGS) -s bad02_unconnected -o $(BUILD)/bad02.vvp bad02_unconnected.v && $(VVP) $(BUILD)/bad02.vvp
	@echo '=== bad03: parameter 전달 누락 ==='
	-@$(IVERILOG) $(IVFLAGS) -s bad03_param -o $(BUILD)/bad03.vvp bad03_param.v && $(VVP) $(BUILD)/bad03.vvp
