IVERILOG ?= iverilog
VVP      ?= vvp

# 자습서 장 목록. 새 장을 추가하면 여기에 이름을 넣는다.
CHAPTERS := ch01 ch02 ch03 ch04 ch05 ch06 ch07 ch08 ch09 ch10

.PHONY: setup-check test chapters errors waves clean help

help:
	@echo 'make setup-check   # 도구 확인'
	@echo 'make test          # 모든 장의 예제 실행'
	@echo 'make chapters      # test와 같다'
	@echo 'make errors        # 각 장의 오류·함정 예제 실행'
	@echo 'make waves         # ch10 통합 예제의 VCD 생성'
	@echo 'make clean         # 생성물 삭제'

setup-check:
	@command -v $(IVERILOG) >/dev/null
	@command -v $(VVP) >/dev/null
	@echo READY

test: setup-check chapters
	@echo 'PASS tutorial 전체'

chapters:
	@for chapter in $(CHAPTERS); do \
	  $(MAKE) --no-print-directory -C $$chapter test || exit 1; \
	done

errors:
	@for chapter in $(CHAPTERS); do \
	  $(MAKE) --no-print-directory -C $$chapter errors 2>/dev/null || true; \
	done

waves:
	@$(MAKE) --no-print-directory -C ch10 waves

clean:
	@for chapter in $(CHAPTERS); do $(MAKE) --no-print-directory -C $$chapter clean; done
