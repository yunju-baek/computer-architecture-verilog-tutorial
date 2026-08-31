// 예제 4-3의 testbench. 두 표현이 같은 우선순위를 만드는지 확인한다.
`timescale 1ns/1ps

module tb_ex03;

  reg  [3:0] request;
  wire [1:0] index_if, index_casez;
  wire       any_if, any_casez;
  integer    i;

  priority_arbiter u_if   (.request(request), .granted_index(index_if),
                          .any_granted(any_if));
  casez_arbiter    u_casez(.request(request), .granted_index(index_casez),
                          .any_granted(any_casez));

  initial begin
    $display("request | index any");
    $display("--------+----------");
    for (i = 0; i < 16; i = i + 1) begin
      request = i[3:0];
      #1;
      if (i < 9)
        $display("  %b   |   %0d    %b", request, index_if, any_if);

      if (index_if !== index_casez || any_if !== any_casez)
        $fatal(1, "FAIL 두 표현의 결과가 다르다 request=%b if=%0d casez=%0d",
               request, index_if, index_casez);
    end

    // 우선순위 확인. 하위 비트가 상위 비트를 이긴다.
    request = 4'b1111; #1;
    if (index_if !== 2'd0) $fatal(1, "FAIL 우선순위 index=%0d", index_if);
    request = 4'b1110; #1;
    if (index_if !== 2'd1) $fatal(1, "FAIL 우선순위 index=%0d", index_if);
    request = 4'b0000; #1;
    if (any_if !== 1'b0) $fatal(1, "FAIL any_granted=%b", any_if);

    $display("PASS ch04 ex03 priority, 16 patterns");
    $finish(0);
  end

endmodule
