import unittest
from arithmetic import to_unsigned, to_signed, add_fixed, sub_fixed, dot_i16
class ReferenceTests(unittest.TestCase):
    def test_representation(self):
        self.assertEqual(to_unsigned(-1, 8), 255)
        self.assertEqual(to_signed(255, 8), -1)
    def test_independent_flags(self):
        self.assertEqual(add_fixed(0x7fffffff, 1, 32), (0x80000000, False, True))
        self.assertEqual(add_fixed(0xffffffff, 1, 32), (0, True, False))
    def test_subtraction(self):
        self.assertEqual(sub_fixed(0, 1, 32), (0xffffffff, False, False))
    def test_accumulation(self):
        self.assertEqual(dot_i16([32767, -32768], [2, -1]), 98302)
if __name__ == '__main__': unittest.main(verbosity=2)
