#!/usr/bin/env python3
"""Generate the normal instruction trace and final state for HW01."""
import json
from pathlib import Path
from tools.rv32i import assemble, run, state_dict, write_trace

ROOT = Path(__file__).resolve().parents[1]

def main():
    evidence = ROOT / 'evidence'
    evidence.mkdir(exist_ok=True)
    program = assemble(ROOT / 'programs/state_contract.s')
    result = run(program)
    write_trace(result.trace, evidence / 'architectural_trace.csv')
    (evidence / 'final_state.json').write_text(json.dumps(state_dict(result), indent=2) + '\n')
    print(f"PASS evidence instructions={len(program.instructions)} transitions={len(result.trace)} "
          f"result=0x{result.memory_words[program.labels['result']]:08x}")

if __name__ == '__main__':
    main()
