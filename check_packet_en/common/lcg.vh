// Function deriving pseudo-random test inputs from student ID.
// The instructor grading harness (Python) utilizes identical arithmetic,
// guaranteeing exact input reproducibility given the student ID.
//
//   next = (x * 1103515245 + 12345) mod 2^32
//
// Initializes state by XORing student ID with a per-chapter salt.
// Advances LCG state for each generated value and extracts high-order bits.
// High-order bits exhibit superior uniform distribution compared to low-order bits.

function [31:0] lcg_next;
  input [31:0] x;
  begin
    lcg_next = x * 32'd1103515245 + 32'd12345;
  end
endfunction

// Read STUDENT_ID from simulation plusargs. Halts execution if missing.
task read_student_id;
  output [31:0] sid;
  begin
    if (!$value$plusargs("STUDENT_ID=%d", sid)) begin
      $display("FAIL +STUDENT_ID=<id> argument required. Execute via Make target.");
      $fatal(1);
    end
    if (sid == 32'd0) begin
      $display("FAIL STUDENT_ID is 0. Check student.mk configuration.");
      $fatal(1);
    end
  end
endtask
