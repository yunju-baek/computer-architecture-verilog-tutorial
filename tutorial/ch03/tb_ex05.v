// 예제 3-5의 testbench. 입력 256가지를 전수 검사한다.
`timescale 1ns/1ps

module tb_ex05;

  reg  [3:0] a, b;
  wire [3:0] sum;
  wire       zero, negative, carry, overflow;

  integer i, j;

  // 참조 계산용. 폭을 넉넉히 두어 온전한 값으로 계산한다.
  reg [5:0]        unsigned_reference;
  reg signed [5:0] signed_reference;

  ex05_flags dut(
    .a(a), .b(b), .sum(sum),
    .zero(zero), .negative(negative), .carry(carry), .overflow(overflow)
  );

  initial begin
    $display("--- 대표 사례 ---");
    $display("  a    b   | sum  zero neg carry ovf");
    $display("-----------+------------------------");

    a = 4'b0011; b = 4'b0010; #1; show;   //  3 +  2 =  5
    a = 4'b1111; b = 4'b0001; #1; show;   // 15 +  1 = 자리올림, 결과 0
    a = 4'b0111; b = 4'b0001; #1; show;   //  7 +  1 = 부호 있는 넘침
    a = 4'b1000; b = 4'b1000; #1; show;   // -8 + -8 = 부호 있는 넘침, 자리올림
    a = 4'b1111; b = 4'b1111; #1; show;   // -1 + -1 = -2, carry 1, overflow 0

    // 전수 검사
    for (i = 0; i < 16; i = i + 1) begin
      for (j = 0; j < 16; j = j + 1) begin
        a = i[3:0];
        b = j[3:0];
        #1;

        unsigned_reference = {2'b0, a} + {2'b0, b};
        signed_reference   = $signed({{2{a[3]}}, a}) + $signed({{2{b[3]}}, b});

        if (sum !== unsigned_reference[3:0])
          $fatal(1, "FAIL sum a=%b b=%b sum=%b expected=%b",
                 a, b, sum, unsigned_reference[3:0]);

        if (zero !== (unsigned_reference[3:0] == 4'b0))
          $fatal(1, "FAIL zero a=%b b=%b zero=%b", a, b, zero);

        if (negative !== unsigned_reference[3])
          $fatal(1, "FAIL negative a=%b b=%b negative=%b", a, b, negative);

        if (carry !== unsigned_reference[4])
          $fatal(1, "FAIL carry a=%b b=%b carry=%b expected=%b",
                 a, b, carry, unsigned_reference[4]);

        // 부호 있는 4비트의 표현 범위는 -8부터 7까지다.
        if (overflow !== ((signed_reference > 7) || (signed_reference < -8)))
          $fatal(1, "FAIL overflow a=%b b=%b overflow=%b signed_sum=%0d",
                 a, b, overflow, signed_reference);
      end
    end

    $display("PASS ch03 ex05 flags, 256 vectors");
    $finish(0);
  end

  task show;
    begin
      $display(" %b %b | %b   %b    %b    %b     %b",
               a, b, sum, zero, negative, carry, overflow);
    end
  endtask

endmodule
