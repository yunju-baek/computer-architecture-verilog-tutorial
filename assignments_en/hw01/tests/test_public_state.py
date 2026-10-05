import ast
import unittest
from pathlib import Path

from tools.rv32i import ABI_NAMES, assemble, register_index, run


SOURCE = Path(__file__).resolve().parents[1] / "programs" / "state_contract.s"


class ArchitecturalStateTests(unittest.TestCase):
    def setUp(self):
        self.program = assemble(SOURCE)

    def test_required_contract_labels_exist(self):
        required = {"main", "values", "result", "add_word", "sum_array"}
        self.assertTrue(required.issubset(self.program.labels))

    def test_machine_code_is_real_rv32i_words(self):
        words = self.program.text_words
        self.assertGreaterEqual(len(words), 10)
        self.assertTrue(all(0 <= word <= 0xffffffff for word in words))
        self.assertEqual(words[0], 0x40000513)  # addi a0, zero, 0x400

    def test_main_commits_expected_memory_result(self):
        result = run(self.program)
        result_address = self.program.labels["result"]
        self.assertEqual(result.memory_words[result_address], 5)
        self.assertEqual(result.registers[register_index("sp")], 0x800)
        self.assertEqual(result.registers[0], 0)

    def test_trace_exposes_control_register_and_memory_state(self):
        result = run(self.program)
        operations = [row["asm"].split()[0] for row in result.trace]
        self.assertIn("call", operations)
        self.assertIn("sw", operations)
        self.assertTrue(any(row["rd"] == "ra" for row in result.trace))
        self.assertTrue(any(row["mem_addr"] != "-" for row in result.trace))
        self.assertEqual(ABI_NAMES[register_index("a0")], "a0")

    def test_student_suite_declares_boundary_cases(self):
        student_suite = SOURCE.parents[1] / "tests" / "test_student_cases.py"
        tree = ast.parse(student_suite.read_text(encoding="utf-8"))
        methods = [
            node.name
            for node in ast.walk(tree)
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
            and node.name.startswith("test_")
        ]
        self.assertTrue({"test_empty_array", "test_word_wraparound"}.issubset(methods))


if __name__ == "__main__":
    unittest.main()
