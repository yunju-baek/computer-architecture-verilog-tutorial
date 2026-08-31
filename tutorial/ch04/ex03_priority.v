// 예제 4-3. if-else 연쇄는 우선순위를, case는 병렬 선택을 표현한다.
`timescale 1ns/1ps

// 요청 4개 중 하나를 고른다. 앞에 적은 요청이 우선한다.
module priority_arbiter(
  input  wire [3:0] request,
  output reg  [1:0] granted_index,
  output reg        any_granted
);
  always @* begin
    granted_index = 2'd0;
    any_granted   = 1'b1;

    if (request[0])
      granted_index = 2'd0;
    else if (request[1])
      granted_index = 2'd1;
    else if (request[2])
      granted_index = 2'd2;
    else if (request[3])
      granted_index = 2'd3;
    else
      any_granted = 1'b0;
  end
endmodule

// 같은 우선순위를 casez로 표현한다. ? 는 해당 비트를 무시한다.
module casez_arbiter(
  input  wire [3:0] request,
  output reg  [1:0] granted_index,
  output reg        any_granted
);
  always @* begin
    granted_index = 2'd0;
    any_granted   = 1'b1;

    casez (request)
      4'b???1: granted_index = 2'd0;
      4'b??10: granted_index = 2'd1;
      4'b?100: granted_index = 2'd2;
      4'b1000: granted_index = 2'd3;
      default: any_granted   = 1'b0;
    endcase
  end
endmodule
