// 예상값과 실제값을 비교하는 공통 매크로.
// 사용하는 모듈에 `integer fails;` 선언이 있어야 하며 initial 블록 시작에서 0으로 둔다.
//
//   UNANSWERED  predictions.vh의 값이 아직 x 자리다.
//   FAIL        예상값과 실제값이 다르다. 코드를 다시 읽고 예상값을 고친다.
//   OK          예상값이 실제값과 같다.

`define CHECK(NAME, PRED, ACT) \
  begin \
    if ((^(PRED)) === 1'bx) begin \
      $display("UNANSWERED %-20s predictions.vh에 예상값을 적는다", NAME); \
      fails = fails + 1; \
    end else if ((PRED) !== (ACT)) begin \
      $display("FAIL       %-20s predicted=%h actual=%h", NAME, PRED, ACT); \
      fails = fails + 1; \
    end else begin \
      $display("OK         %-20s %h", NAME, ACT); \
    end \
  end

// 10진수로 적는 예상값(개수, 부호 있는 값)에 쓴다.
`define CHECKD(NAME, PRED, ACT) \
  begin \
    if ((^(PRED)) === 1'bx) begin \
      $display("UNANSWERED %-20s predictions.vh에 예상값을 적는다", NAME); \
      fails = fails + 1; \
    end else if ((PRED) !== (ACT)) begin \
      $display("FAIL       %-20s predicted=%0d actual=%0d", NAME, PRED, ACT); \
      fails = fails + 1; \
    end else begin \
      $display("OK         %-20s %0d", NAME, ACT); \
    end \
  end

// 검사를 마무리한다. 실패가 있으면 종료 코드 1로 끝난다.
`define FINISH_CHECK(TAG, SID) \
  begin \
    if (fails != 0) begin \
      $display("FAIL %s mismatched=%0d", TAG, fails); \
      $fatal(1, "mismatched=%0d", fails); \
    end \
    $display("PASS %s STUDENT_ID=%0d", TAG, SID); \
    $finish(0); \
  end
