package alsu_pkg;

  // -------- ENUM for opcodes --------
  typedef enum logic [2:0] {
    OR_OP     = 3'h0,
    XOR_OP    = 3'h1,
    ADD_OP    = 3'h2,
    MUL_OP    = 3'h3,
    SHIFT_OP  = 3'h4,
    ROT_OP    = 3'h5,
    INVALID_6 = 3'h6,
    INVALID_7 = 3'h7
  } opcode_e;

  // -------- Transaction Class --------
  class alsu_txn;

    // Constants
    localparam signed [2:0] MAXPOS = 3;
    localparam signed [2:0] MAXNEG = -4;
    localparam signed [2:0] ZERO   = 0;

    // Randomizable Inputs
    rand logic clk, rst, cin, serial_in;
    rand logic red_op_A, red_op_B;
    rand logic bypass_A, bypass_B, direction;
    rand opcode_e opcode;
    rand logic signed [2:0] A, B;

    // Fixed array for constraint #8
    rand opcode_e opcode_seq[6];

    // Constraint enable flags
    bit en_c1, en_c2, en_c3, en_c4, en_c5, en_c6, en_c7, en_c8;

    // -------- Covergroup --------
    covergroup cvr_gp @(posedge clk);
      option.per_instance = 1;

      // A Coverpoint
      coverpoint A {
        bins A_data_0       = {0};
        bins A_data_max     = {MAXPOS};
        bins A_data_min     = {MAXNEG};
        bins A_data_default = default;
      }

      // B Coverpoint
      coverpoint B {
        bins B_data_0       = {0};
        bins B_data_max     = {MAXPOS};
        bins B_data_min     = {MAXNEG};
        bins B_data_default = default;
      }

      // Opcode Coverpoint
      coverpoint opcode {
        bins bins_shift[]   = {SHIFT_OP, ROT_OP};
        bins bins_arith[]   = {ADD_OP, MUL_OP};
        bins bins_bitwise[] = {OR_OP, XOR_OP};
        illegal_bins bins_invalid = {INVALID_6, INVALID_7};
      }
    endgroup

    // -------- Constraints --------
    constraint c1 { if (en_c1) A inside {[MAXNEG:MAXPOS]}; }
    constraint c2 { if (en_c2) B inside {[MAXNEG:MAXPOS]}; }
    constraint c3 { if (en_c3) opcode inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP}; }

    // Constraint #8: unique opcodes in array
    constraint unique_opcodes {
      if (en_c8) {
        foreach (opcode_seq[i]) opcode_seq[i] inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP};
        unique {opcode_seq};
      }
    }

    // -------- Constructor --------
    function new();
      en_c1 = 1; en_c2 = 1; en_c3 = 1; en_c4 = 1;
      en_c5 = 1; en_c6 = 1; en_c7 = 1; en_c8 = 0;
      cvr_gp = new();
    endfunction

  endclass : alsu_txn

endpackage : alsu_pkg




/* package alsu_pkg;

  typedef enum logic [2:0] {
    OR_OP     = 3'h0,
    XOR_OP    = 3'h1,
    ADD_OP    = 3'h2,
    MUL_OP    = 3'h3,
    SHIFT_OP  = 3'h4,
    ROT_OP    = 3'h5,
    INVALID_6 = 3'h6,
    INVALID_7 = 3'h7
  } opcode_e;

  class alsu_txn;

    // ✅ Move localparams inside the class
    localparam signed [2:0] MAXPOS = 3;
    localparam signed [2:0] MAXNEG = -4;
    localparam signed [2:0] ZERO   = 0;

    // Randomizable inputs
    rand logic clk, rst, cin, serial_in, red_op_A, red_op_B;
    rand logic bypass_A, bypass_B, direction;
    rand opcode_e opcode;
    rand opcode_e opcode_seq[6];
    rand logic signed [2:0] A, B;

    // Constraint enable flags
    bit en_c1, en_c2, en_c3, en_c4, en_c5, en_c6, en_c7, en_c8;

    // Covergroup
    covergroup cvr_gp @(posedge clk);
      option.per_instance = 1;

      coverpoint A {
        bins A_data_0       = {0};
        bins A_data_max     = {MAXPOS};   // ✅ No unresolved reference now
        bins A_data_min     = {MAXNEG};   // ✅ Fixed
        bins A_data_default = default;
      }

      coverpoint B {
        bins B_data_0       = {0};
        bins B_data_max     = {MAXPOS};
        bins B_data_min     = {MAXNEG};
        bins B_data_default = default;
      }

      coverpoint opcode {
        bins bins_shift[]   = {SHIFT_OP, ROT_OP};
        bins bins_arith[]   = {ADD_OP, MUL_OP};
        bins bins_bitwise[] = {OR_OP, XOR_OP};
        bins bins_invalid   = {INVALID_6, INVALID_7};
      }
    endgroup

    function new();
      en_c1 = 1; en_c2 = 1; en_c3 = 1; en_c4 = 1;
      en_c5 = 1; en_c6 = 1; en_c7 = 1; en_c8 = 0;
      cvr_gp = new();
    endfunction

  endclass : alsu_txn

endpackage : alsu_pkg */



/* package alsu_pkg;

  // Enum for opcodes
  typedef enum logic [2:0] {
    OR_OP     = 3'h0,
    XOR_OP    = 3'h1,
    ADD_OP    = 3'h2,
    MUL_OP    = 3'h3,
    SHIFT_OP  = 3'h4,
    ROT_OP    = 3'h5,
    INVALID_6 = 3'h6,
    INVALID_7 = 3'h7
  } opcode_e;

  // Local parameters for edge cases for adder
  localparam signed [2:0] MAXPOS =  3;
  localparam signed [2:0] MAXNEG = -4;
  localparam signed [2:0] ZERO   =  0;

  // Transaction / generator class
  class alsu_txn;

    // Randomizable inputs
    rand logic clk, rst, cin, serial_in, red_op_A, red_op_B;
    rand logic bypass_A, bypass_B, direction;
    rand opcode_e opcode;
    rand opcode_e opcode_seq[6];
    rand logic signed [2:0] A, B;

    // Constraint enable flags
    bit en_c1, en_c2, en_c3, en_c4, en_c5, en_c6, en_c7, en_c8;

    // Covergroup handle
    covergroup cvr_gp @(posedge clk);
      option.per_instance = 1;

      coverpoint A {
        bins A_data_0      = {0};
        bins A_data_max    = {MAXPOS};
        bins A_data_min    = {MAXNEG};
        bins A_data_default = default;
      }

      coverpoint B {
        bins B_data_0      = {0};
        bins B_data_max    = {MAXPOS};
        bins B_data_min    = {MAXNEG};
        bins B_data_default = default;

      }

      // Walking ones only when red_op_A or red_op_B
      coverpoint bypass_A iff (red_op_A && !red_op_B) {
        bins data[] = {3'b001, 3'b010, 3'b100};
      }
      coverpoint bypass_B iff (red_op_B && !red_op_A) {
        bins data[] = {3'b001, 3'b010, 3'b100};
      }

      coverpoint opcode {
        bins bins_shift[]   = {SHIFT_OP, ROT_OP};
        bins bins_arith[]   = {ADD_OP, MUL_OP};
        bins bins_bitwise[] = {OR_OP, XOR_OP};
        bins bins_invalid   = {INVALID_6, INVALID_7};
      }
    endgroup

    // Constructor
    function new();
      en_c1 = 1; en_c2 = 1; en_c3 = 1; en_c4 = 1;
      en_c5 = 1; en_c6 = 1; en_c7 = 1; en_c8 = 0;
      cvr_gp = new();
    endfunction

    // Constraints
    constraint c_reset {
      if (en_c1) rst dist {1:=1, 0:=9};
    }

    constraint c_adder_bias {
      if (en_c2 && (opcode inside {ADD_OP, MUL_OP})) 
        A dist { MAXPOS:=4, ZERO:=4, MAXNEG:=4, [-2:2]:=1 };
        B dist { MAXPOS:=4, ZERO:=4, MAXNEG:=4, [-2:2]:=1 };
    }

    constraint c_red {
      // en_c3 must be true and opcode is OR or XOR
      (en_c3 && (opcode inside {OR_OP, XOR_OP})) -> (
          (red_op_A && !red_op_B) -> (A inside {3'b001,3'b010,3'b100} && B == 3'b000) &&
          (red_op_B && !red_op_A) -> (B inside {3'b001,3'b010,3'b100} && A == 3'b000) &&
          (red_op_A && red_op_B)  -> (A inside {3'b001,3'b010,3'b100} && B inside {3'b001,3'b010,3'b100})
      );
    }


    constraint c_invalid {
      if (en_c5) opcode dist { INVALID_6:=1, INVALID_7:=1, [OR_OP:ROT_OP]:=10 };
    }

    constraint c_bypass {
      if (en_c6) 
        bypass_A dist {0:=8, 1:=2};
        bypass_B dist {0:=8, 1:=2};
    }

    constraint c_unique_opcode_seq {
      if (en_c8) 
        foreach(opcode_seq[i]) opcode_seq[i] inside {OR_OP,XOR_OP,ADD_OP,MUL_OP,SHIFT_OP,ROT_OP};
        foreach(opcode_seq[i]) foreach(opcode_seq[j]) if (i<j) opcode_seq[i] != opcode_seq[j];
    }

    constraint c_opcode_domain {
      opcode inside {OR_OP,XOR_OP,ADD_OP,MUL_OP,SHIFT_OP,ROT_OP,INVALID_6,INVALID_7};
    }

    constraint c_cin_valid {
      if (en_c7) 
        if (opcode==ADD_OP) cin dist {0:=1,1:=1};
        else cin==0;
    }

    // Sample covergroup
    function void sample();
      cvr_gp.sample();
    endfunction

  endclass // alsu_txn

endpackage : alsu_pkg */
