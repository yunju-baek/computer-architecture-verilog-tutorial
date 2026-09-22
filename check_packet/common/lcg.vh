// 학번에서 실험 입력값을 파생하는 함수.
// 교수자 검사기(Python)도 같은 식을 쓰므로 학번만 알면 입력값을 재현할 수 있다.
//
//   next = (x * 1103515245 + 12345) mod 2^32
//
// 장별 salt를 학번에 XOR한 값을 시작점으로 두고, 필요한 값마다 한 단계씩 진행하며
// 상위 비트를 잘라 쓴다. 상위 비트가 하위 비트보다 고르게 퍼진다.

function [31:0] lcg_next;
  input [31:0] x;
  begin
    lcg_next = x * 32'd1103515245 + 32'd12345;
  end
endfunction

// STUDENT_ID를 plusarg에서 읽는다. 값이 없으면 실행을 중단한다.
task read_student_id;
  output [31:0] sid;
  begin
    if (!$value$plusargs("STUDENT_ID=%d", sid)) begin
      $display("FAIL +STUDENT_ID=<학번> 인수가 필요하다. make 타깃으로 실행한다.");
      $fatal(1);
    end
    if (sid == 32'd0) begin
      $display("FAIL STUDENT_ID가 0이다. student.mk를 확인한다.");
      $fatal(1);
    end
  end
endtask
