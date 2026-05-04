package fsm_pkg;

  // FSM states typedef
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    ZERO  = 2'b01,
    ONE   = 2'b10,
    STORE = 2'b11
  } state_e;

  // Transaction class
  class fsm_transaction;
    rand bit x;
    rand bit rst;
    bit y_exp;
    bit [9:0] user_count_exp;

    // Constraints
    constraint rst_c { rst dist {1 := 1, 0 := 9}; }   // reset mostly inactive
    constraint x_c   { x dist {0 := 67, 1 := 33}; }  // x=0 ~67%

  endclass

endpackage
