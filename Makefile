.PHONY: help setup-check tutorial test errors waves clean package-check

help:
	@echo 'make setup-check   # Icarus Verilog 도구 확인'
	@echo 'make test          # Verilog 자습서 전체 실행'
	@echo 'make errors        # 의도적 결함 예제 실행'
	@echo 'make waves         # ch10 통합 VCD 생성'
	@echo 'make clean         # 생성물 정리'
	@echo 'make package-check # 공개 패키지 검증'

setup-check:
	$(MAKE) --no-print-directory -C tutorial setup-check

tutorial test:
	$(MAKE) --no-print-directory -C tutorial test

errors:
	$(MAKE) --no-print-directory -C tutorial errors

waves:
	$(MAKE) --no-print-directory -C tutorial waves

clean:
	$(MAKE) --no-print-directory -C tutorial clean

package-check:
	@test -f README.md
	@test -f VERSION
	@test -f release_manifest.json
	@test -f assignments/README.md
	@test -d tutorial
	@test -z "$$(find assignments -mindepth 1 -maxdepth 1 -type d -print -quit)"
	@$(MAKE) --no-print-directory test
	@echo 'PASS tutorial-only public package'
