// 의도적 함정 3. seed 고정을 생략한 무작위 입력.
// 실패를 재현하기 어려워진다.
`timescale 1ns/1ps

module bad03_random_seed;
  integer fixed_seed = 32'd20260825;
  integer trial;
  reg [15:0] with_seed_first, with_seed_second;
  reg [15:0] without_seed_first, without_seed_second;

  initial begin
    $display("--- seed를 넘긴 $random 은 나열이 재현된다 ---");
    fixed_seed = 32'd20260825;
    with_seed_first = $random(fixed_seed);
    $display("첫 호출  = %h", with_seed_first);

    // seed를 원래 값으로 되돌리고 같은 호출을 반복한다.
    fixed_seed = 32'd20260825;
    with_seed_second = $random(fixed_seed);
    $display("재설정 후 = %h  같은 값이 나온다", with_seed_second);

    if (with_seed_first !== with_seed_second)
      $display("주의: 두 값이 갈라졌다");

    $display("--- seed 없이 호출하면 나열이 이어진다 ---");
    without_seed_first  = $random;
    without_seed_second = $random;
    $display("연속 호출 = %h, %h  값이 계속 진행한다",
             without_seed_first, without_seed_second);
    $display("실패한 입력을 다시 만들려면 그 시점까지의 호출 횟수를 알아야 한다");

    $display("--- seed를 고정하면 실패 재현이 한 줄로 끝난다 ---");
    fixed_seed = 32'd20260825;
    for (trial = 0; trial < 5; trial = trial + 1)
      $display("trial %0d -> %h", trial, $random(fixed_seed));

    $finish(0);
  end
endmodule
