// 예제 10-2. SystemVerilog가 추가한 자료형.
// 제공 testbench와 기준 구현에서 볼 수 있는 표기다.
`timescale 1ns/1ps

module ex02_enum_struct;

  // typedef enum. 상태 이름에 자료형을 붙인다.
  // Verilog-2001의 localparam 인코딩에 대응한다.
  typedef enum logic [1:0] {
    IDLE     = 2'd0,
    SAW_ONE  = 2'd1,
    SAW_TWO  = 2'd2,
    SAW_MANY = 2'd3
  } detect_state_t;

  detect_state_t state;

  // packed struct. 필드 여러 개를 한 벡터로 묶는다.
  // Verilog-2001에서는 concatenation과 part select로 같은 일을 한다.
  typedef struct packed {
    logic [6:0] funct7;
    logic [4:0] rs2;
    logic [4:0] rs1;
    logic [2:0] funct3;
    logic [4:0] rd;
    logic [6:0] opcode;
  } rv32_r_type_t;

  rv32_r_type_t decoded;
  logic [31:0]  raw_word;

  initial begin
    $display("--- enum은 이름과 값을 함께 출력한다 ---");
    state = IDLE;     $display("state = %0s (%b)", state.name(), state);
    state = SAW_TWO;  $display("state = %0s (%b)", state.name(), state);
    state = SAW_MANY; $display("state = %0s (%b)", state.name(), state);

    $display("--- packed struct는 벡터와 서로 바꿔 쓸 수 있다 ---");
    // add x3, x1, x2 = 0x002081b3
    raw_word = 32'h002081b3;
    decoded  = raw_word;              // 벡터를 struct로 읽는다
    $display("raw_word = %h", raw_word);
    $display("opcode = %b", decoded.opcode);
    $display("rd     = %0d", decoded.rd);
    $display("funct3 = %b", decoded.funct3);
    $display("rs1    = %0d", decoded.rs1);
    $display("rs2    = %0d", decoded.rs2);
    $display("funct7 = %b", decoded.funct7);

    if (decoded.opcode !== 7'b0110011) $fatal(1, "FAIL opcode=%b", decoded.opcode);
    if (decoded.rd     !== 5'd3)       $fatal(1, "FAIL rd=%0d", decoded.rd);
    if (decoded.rs1    !== 5'd1)       $fatal(1, "FAIL rs1=%0d", decoded.rs1);
    if (decoded.rs2    !== 5'd2)       $fatal(1, "FAIL rs2=%0d", decoded.rs2);

    // struct를 다시 벡터로 읽으면 원래 값이 나온다.
    if (raw_word !== 32'(decoded)) $fatal(1, "FAIL struct 변환이 어긋났다");
    $display("struct를 벡터로 되읽으면 %h", 32'(decoded));

    $display("--- 상수 표기 ---");
    $display("'0 은 모든 비트 0  -> %b", 8'('0));
    $display("'1 은 모든 비트 1  -> %b", 8'('1));

    $display("PASS ch10 ex02 자료형");
    $finish(0);
  end

endmodule
