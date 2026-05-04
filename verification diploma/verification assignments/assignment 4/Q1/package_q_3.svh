//new
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

      // ------------------- Base Coverpoints -------------------
      A_cp: coverpoint A {
        bins A_data_0       = {ZERO};
        bins A_data_max     = {MAXPOS};
        bins A_data_min     = {MAXNEG};
        bins A_data_default = default;
      }

      B_cp: coverpoint B {
        bins B_data_0       = {ZERO};
        bins B_data_max     = {MAXPOS};
        bins B_data_min     = {MAXNEG};
        bins B_data_default = default;
      }

      opcode_cp: coverpoint opcode {
        bins bins_shift[]   = {SHIFT_OP, ROT_OP};
        bins bins_arith[]   = {ADD_OP, MUL_OP};
        bins bins_bitwise[] = {OR_OP, XOR_OP};
        illegal_bins bins_invalid = {INVALID_6, INVALID_7};
      }

      cin_cp: coverpoint cin {
        bins cin_0 = {0};
        bins cin_1 = {1};
      }

      direction_cp: coverpoint direction {
        bins dir_0 = {0};
        bins dir_1 = {1};
      }

      serial_in_cp: coverpoint serial_in {
        bins serial_0 = {0};
        bins serial_1 = {1};
      }

      red_op_A_cp: coverpoint red_op_A {
        bins red_A_0 = {0};
        bins red_A_1 = {1};
      }

      red_op_B_cp: coverpoint red_op_B {
        bins red_B_0 = {0};
        bins red_B_1 = {1};
      }

      // Walking-one patterns for A
      A_walking_cp: coverpoint A {
        bins walking_one[] = {3'b001, 3'b010, 3'b100};
      }

      // Walking-one patterns for B
      B_walking_cp: coverpoint B {
        bins walking_one[] = {3'b001, 3'b010, 3'b100};
      }

      // ------------------- Cross Coverage -------------------
      // 1) ADD/MUL: permutations of A and B with {MAXPOS, MAXNEG, ZERO}
      cross_arith_vals: cross A_cp, B_cp, opcode_cp {
        bins add_mul_permutations = binsof(opcode_cp.bins_arith) &&
                                   (binsof(A_cp.A_data_0) || binsof(A_cp.A_data_max) || binsof(A_cp.A_data_min)) &&
                                   (binsof(B_cp.B_data_0) || binsof(B_cp.B_data_max) || binsof(B_cp.B_data_min));
      }

      // 2) When ADD, cin should take 0 and 1
      cross_add_cin: cross opcode_cp, cin_cp {
        bins add_cin_0_1 = binsof(opcode_cp) intersect {ADD_OP};
      }

      // 3) When SHIFT/ROT, direction should take 0 and 1
      cross_shift_rot_direction: cross opcode_cp, direction_cp {
        bins shift_rot_dir = binsof(opcode_cp.bins_shift);
      }

      // 4) When SHIFT, serial_in should take 0 and 1
      cross_shift_serial: cross opcode_cp, serial_in_cp {
        bins shift_serial_in = binsof(opcode_cp) intersect {SHIFT_OP};
      }

      // 5) OR/XOR + red_op_A asserted: A walking-one patterns, B == 0
      cross_redA_walking: cross opcode_cp, A_walking_cp, red_op_A_cp {
        bins redA_walking = binsof(opcode_cp.bins_bitwise) && 
                           binsof(red_op_A_cp.red_A_1);
      }

      // 6) OR/XOR + red_op_B asserted: B walking-one patterns, A == 0
      cross_redB_walking: cross opcode_cp, B_walking_cp, red_op_B_cp {
        bins redB_walking = binsof(opcode_cp.bins_bitwise) && 
                           binsof(red_op_B_cp.red_B_1);
      }

      // 7) Invalid reduction case
      cross_invalid_reduction: cross opcode_cp, red_op_A_cp, red_op_B_cp {
        bins invalid_red = (binsof(opcode_cp) intersect {ADD_OP, MUL_OP, SHIFT_OP, ROT_OP}) &&
                          (binsof(red_op_A_cp.red_A_1) || binsof(red_op_B_cp.red_B_1));
      }

    endgroup

    // -------- Constraints --------
    constraint c1 { if (en_c1) A inside {[MAXNEG:MAXPOS]}; }
    constraint c2 { if (en_c2) B inside {[MAXNEG:MAXPOS]}; }
    constraint c3 { if (en_c3) opcode inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP}; }

    // Constraint #8: unique opcodes in array
    constraint unique_opcodes {
      if (en_c8) {
        unique {opcode_seq};
        foreach (opcode_seq[i]) {
          opcode_seq[i] inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP};
        }
      }
    }

    // Walking-one patterns constraint
    constraint walking_one_constraint {
      if ((opcode inside {OR_OP, XOR_OP}) && red_op_A && (B == 0)) {
        A inside {3'b001, 3'b010, 3'b100};
      }
      if ((opcode inside {OR_OP, XOR_OP}) && red_op_B && (A == 0)) {
        B inside {3'b001, 3'b010, 3'b100};
      }
    }

    // -------- Constructor --------
    function new();
      en_c1 = 1; en_c2 = 1; en_c3 = 1;
      en_c4 = 1; en_c5 = 1; en_c6 = 1;
      en_c7 = 1; en_c8 = 0;
      cvr_gp = new();
    endfunction

  endclass : alsu_txn

endpackage : alsu_pkg

//old
/*
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

      // ------------------- Base Coverpoints -------------------

      // A Coverpoint
      A_cp: coverpoint A {
        bins A_data_0       = {ZERO};
        bins A_data_max     = {MAXPOS};
        bins A_data_min     = {MAXNEG};
        bins A_data_default = default;
      }

      // B Coverpoint
      B_cp: coverpoint B {
        bins B_data_0       = {ZERO};
        bins B_data_max     = {MAXPOS};
        bins B_data_min     = {MAXNEG};
        bins B_data_default = default;
      }

      // Opcode Coverpoint
      opcode_cp: coverpoint opcode {
        bins bins_shift[]   = {SHIFT_OP, ROT_OP};
        bins bins_arith[]   = {ADD_OP, MUL_OP};
        bins bins_bitwise[] = {OR_OP, XOR_OP};
        illegal_bins bins_invalid = {INVALID_6, INVALID_7};
      }

      // ------------------- Functional Coverage -------------------

      // 1) ADD/MUL: permutations of A and B with {MAXPOS, MAXNEG, ZERO}
      A_arbins: coverpoint A iff (opcode inside {ADD_OP, MUL_OP}) {
        bins A_vals[] = {MAXPOS, MAXNEG, ZERO};
      }
      B_arbins: coverpoint B iff (opcode inside {ADD_OP, MUL_OP}) {
        bins B_vals[] = {MAXPOS, MAXNEG, ZERO};
      }

      A_B_cross: cross A_arbins, B_arbins iff (opcode inside {ADD_OP, MUL_OP});

      // 2) When ADD, cin should take 0 and 1
      cin_cp: coverpoint cin iff (opcode == ADD_OP) {
        bins cin_0 = {0};
        bins cin_1 = {1};
      }

      // 3) When SHIFT/ROT, direction should take 0 and 1
      direction_cp: coverpoint direction iff (opcode inside {SHIFT_OP, ROT_OP}) {
        bins dir_0 = {0};
        bins dir_1 = {1};
      }

      // 4) When SHIFT, serial_in should take 0 and 1
      serial_in_cp: coverpoint serial_in iff (opcode == SHIFT_OP) {
        bins shift_in_0 = {0};
        bins shift_in_1 = {1};
      }

      // 5) OR/XOR + red_op_A asserted: A walking-one patterns, B == 0
      A_walking_cp: coverpoint A iff ((opcode inside {OR_OP, XOR_OP}) && red_op_A && (B == ZERO)) {
        bins walking_one[] = {3'b001, 3'b010, 3'b100};
      }

      // 6) OR/XOR + red_op_B asserted: B walking-one patterns, A == 0
      B_walking_cp: coverpoint B iff ((opcode inside {OR_OP, XOR_OP}) && red_op_B && (A == ZERO)) {
        bins walking_one[] = {3'b001, 3'b010, 3'b100};
      }

      // 7) Invalid reduction case: reduction active but opcode not OR/XOR
      invalid_reduction_cp: coverpoint opcode iff ((red_op_A || red_op_B) && !(opcode inside {OR_OP, XOR_OP})) {
        bins invalid_cases[] = {ADD_OP, MUL_OP, SHIFT_OP, ROT_OP};
      }

      // Crosses for reduction walking patterns
      A_walking_cross: cross opcode_cp, A_walking_cp iff (red_op_A && (B == ZERO));
      B_walking_cross: cross opcode_cp, B_walking_cp iff (red_op_B && (A == ZERO));

    endgroup

    // -------- Constraints --------
    constraint c1 { if (en_c1) A inside {[MAXNEG:MAXPOS]}; }
    constraint c2 { if (en_c2) B inside {[MAXNEG:MAXPOS]}; }
    constraint c3 { if (en_c3) opcode inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP}; }

    // Constraint #8: unique opcodes in array
    constraint unique_opcodes {
      if (en_c8) {
        foreach (opcode_seq[i])
          opcode_seq[i] inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP};
        unique {opcode_seq};
      }
    }

    // -------- Constructor --------
    function new();
      en_c1 = 1; en_c2 = 1; en_c3 = 1;
      en_c4 = 1; en_c5 = 1; en_c6 = 1;
      en_c7 = 1; en_c8 = 0;
      cvr_gp = new();
    endfunction

  endclass : alsu_txn

endpackage : alsu_pkg
*/