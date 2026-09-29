// 예제 3-2. 표현식의 폭은 어떻게 정해지는가.
// 이 장에서 가장 중요한 예제다. HW02의 carry 구현이 여기에 달려 있다.
`timescale 1ns/1ps

module ex02_width_rules;

  reg  [3:0] a, b;
  reg  [3:0] sub_a, sub_b;
  reg  [3:0] narrow_result;   // 4비트로 받는다
  reg  [4:0] wide_result;     // 5비트로 받는다
  reg        carry_bit;

  initial begin
    a = 4'hf;   // 15
    b = 4'h1;   // 1

    $display("a = %h (%0d), b = %h (%0d)", a, a, b, b);

    $display("--- 규칙 1. 좌변 폭이 연산 폭을 정한다 ---");
    narrow_result = a + b;
    $display("4비트에 담으면  a + b = %b (%0d)  자리올림이 사라진다",
             narrow_result, narrow_result);
    wide_result = a + b;
    $display("5비트에 담으면  a + b = %b (%0d)  자리올림이 남는다",
             wide_result, wide_result);

    $display("--- 규칙 2. 자리올림은 결과 폭을 넓혀 얻는다 ---");
    carry_bit = wide_result[4];
    $display("wide_result[4] = %b  이것이 carry다", carry_bit);

    $display("--- 규칙 3. 중간 표현식의 폭도 문맥이 정한다 ---");
    // (a + b)가 4비트 문맥에서 계산되면 시프트할 값이 이미 잘려 있다.
    carry_bit = (a + b) >> 4;
    $display("(a + b) >> 4 를 1비트에 담으면 = %b", carry_bit);
    // concatenation으로 폭을 명시하면 결과가 달라진다.
    carry_bit = ({1'b0, a} + {1'b0, b}) >> 4;
    $display("({1'b0,a} + {1'b0,b}) >> 4  = %b  이 방식이 확실하다", carry_bit);

    $display("--- 규칙 4. 폭 없는 상수는 32비트로 확장된다 ---");
    $display("a + 1 == 16   -> %b  상수 1이 32비트이므로 폭을 유지한다", (a + 1) == 16);
    $display("a + 4'b1 == 0 -> %b  4'b1은 4비트이므로 4비트로 계산된다", (a + 4'b1) == 4'b0);

    $display("--- 규칙 5. 부호 없는 뺄셈은 폭 안에서 순환한다 ---");
    sub_a = 4'd7;
    sub_b = 4'd2;
    narrow_result = sub_b - sub_a;
    $display("4비트에서 2 - 7 = %b (%0d)  기대한 -5 대신 순환한 값이 남는다",
             narrow_result, narrow_result);
    wide_result = sub_b - sub_a;
    $display("5비트에서 2 - 7 = %b (%0d)  폭을 넓혀도 부호 없이 순환한다",
             wide_result, wide_result);
    wide_result = $signed(sub_b) - $signed(sub_a);
    $display("$signed를 붙이면  2 - 7 = %b (%0d)  부호가 유지된다",
             wide_result, $signed(wide_result));

    $finish(0);
  end

endmodule
