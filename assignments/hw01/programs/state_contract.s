.data
values: .word 5, -2, 9, -7
result: .word 0

.text
.globl main
main:
  la a0, values
  li a1, 4
  call sum_array
  la t0, result
  sw a0, 0(t0)
  ebreak

add_word:
  # TODO: return a0 + a1 in a0.
  li a0, 0
  ret

sum_array:
  # TODO: sum a1 words beginning at address a0.
  # Preserve sp and every saved register used by this function.
  li a0, 0
  ret
