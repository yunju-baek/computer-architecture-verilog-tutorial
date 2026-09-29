// Common macros for comparing predicted and actual simulation values.
// The instantiating module must declare `integer fails;` and initialize it to 0.
//
//   UNANSWERED  Value in predictions.vh contains unassigned 'x'.
//   FAIL        Predicted value does not match actual simulation output.
//   OK          Predicted value matches actual simulation output.

`define CHECK(NAME, PRED, ACT) \
  begin \
    if ((^(PRED)) === 1'bx) begin \
      $display("UNANSWERED %-20s Record expected value in predictions.vh", NAME); \
      fails = fails + 1; \
    end else if ((PRED) !== (ACT)) begin \
      $display("FAIL       %-20s predicted=%h actual=%h", NAME, PRED, ACT); \
      fails = fails + 1; \
    end else begin \
      $display("OK         %-20s %h", NAME, ACT); \
    end \
  end

// For decimal predictions (counts, signed integers).
`define CHECKD(NAME, PRED, ACT) \
  begin \
    if ((^(PRED)) === 1'bx) begin \
      $display("UNANSWERED %-20s Record expected value in predictions.vh", NAME); \
      fails = fails + 1; \
    end else if ((PRED) !== (ACT)) begin \
      $display("FAIL       %-20s predicted=%0d actual=%0d", NAME, PRED, ACT); \
      fails = fails + 1; \
    end else begin \
      $display("OK         %-20s %0d", NAME, ACT); \
    end \
  end

// Finalize verification. Exit with status 1 on failure.
`define FINISH_CHECK(TAG, SID) \
  begin \
    if (fails != 0) begin \
      $display("FAIL %s mismatched=%0d", TAG, fails); \
      $fatal(1, "mismatched=%0d", fails); \
    end \
    $display("PASS %s STUDENT_ID=%0d", TAG, SID); \
    $finish(0); \
  end
