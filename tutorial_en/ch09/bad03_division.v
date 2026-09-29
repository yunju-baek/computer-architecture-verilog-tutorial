// 의도적 함정 3. 설계 코드에 나눗셈과 나머지를 쓴다.
// 상수로 나누는 경우와 변수로 나누는 경우의 비용이 크게 다르다.
`timescale 1ns/1ps

module divide_variants(
  input  wire [15:0] value,
  input  wire [15:0] divisor,
  output wire [15:0] by_variable,     // 변수로 나눈다
  output wire [15:0] by_power_of_two, // 2의 거듭제곱으로 나눈다
  output wire [15:0] by_shift,        // 같은 계산을 시프트로 한다
  output wire [15:0] mod_power,       // 2의 거듭제곱으로 나눈 나머지
  output wire [15:0] mod_mask         // 같은 계산을 마스크로 한다
);
  assign by_variable     = (divisor == 16'd0) ? 16'hffff : value / divisor;
  assign by_power_of_two = value / 16'd16;
  assign by_shift        = value >> 4;
  assign mod_power       = value % 16'd16;
  assign mod_mask        = value & 16'h000f;
endmodule

module bad03_division;
  reg  [15:0] value, divisor;
  wire [15:0] by_variable, by_power_of_two, by_shift, mod_power, mod_mask;

  divide_variants dut(.value(value), .divisor(divisor),
                      .by_variable(by_variable), .by_power_of_two(by_power_of_two),
                      .by_shift(by_shift), .mod_power(mod_power), .mod_mask(mod_mask));

  initial begin
    value = 16'd1000; divisor = 16'd7;
    #1;
    $display("value=%0d divisor=%0d", value, divisor);
    $display("변수로 나눔    = %0d", by_variable);
    $display("16으로 나눔    = %0d", by_power_of_two);
    $display("4비트 시프트   = %0d  같은 값이다", by_shift);
    $display("16으로 나눈 나머지 = %0d", mod_power);
    $display("하위 4비트 마스크  = %0d  같은 값이다", mod_mask);

    if (by_power_of_two !== by_shift) $fatal(1, "FAIL 나눗셈과 시프트가 갈라졌다");
    if (mod_power !== mod_mask)       $fatal(1, "FAIL 나머지와 마스크가 갈라졌다");

    value = 16'd65535; #1;
    $display("value=%0d -> 16으로 나눔 %0d, 시프트 %0d",
             value, by_power_of_two, by_shift);
    if (by_power_of_two !== by_shift) $fatal(1, "FAIL 경계값에서 갈라졌다");

    $display("2의 거듭제곱 나눗셈은 시프트와 마스크로 바꿔 적는다");
    $display("변수로 나누는 연산은 큰 회로가 되므로 설계 판단이 필요하다");
    $finish(0);
  end
endmodule
