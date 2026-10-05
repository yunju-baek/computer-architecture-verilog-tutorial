import unittest
from pathlib import Path

from tools.rv32i import assemble, register_index, run


SOURCE = Path(__file__).resolve().parents[1] / "programs" / "state_contract.s"
DATA = 0x500
STOP = 0xFFC


class StudentDesignedCases(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.program = assemble(SOURCE)

    def run_sum(self, values):
        """Run sum_array with a chosen list and return the architectural state."""
        memory = {DATA + index * 4: value for index, value in enumerate(values)}
        return run(
            self.program,
            entry="sum_array",
            initial_registers={"a0": DATA, "a1": len(values), "ra": STOP, "sp": 0x800},
            memory_words=memory,
            stop_pc=STOP,
        )

    def test_empty_array(self):
        result = self.run_sum([])
        self.fail("TODO: predict and check a0 and restored sp for the empty array")

    def test_word_wraparound(self):
        result = self.run_sum([0xffffffff, 1])
        self.fail("TODO: predict and check a0 and restored sp after word wraparound")


if __name__ == "__main__":
    unittest.main()
