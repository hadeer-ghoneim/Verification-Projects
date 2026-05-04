package alsu_pkg;

  // Enum for opcodes
  typedef enum logic [2:0]
    {OR_OP     = 3'h0, XOR_OP     = 3'h1,
    ADD_OP     = 3'h2, MUL_OP     = 3'h3,
    SHIFT_OP   = 3'h4, ROT_OP     = 3'h5,
    INVALID_6  = 3'h6, INVALID_7  = 3'h7} opcode_e;
  
  // Local parameters for edge cases for adder
  localparam MAXPOS =  3;  
  localparam MAXNEG = -4;  
  localparam ZERO   =  0;

  class alsu_txn;

    // Inputs to be randomized
    rand logic clk,rst,cin,serial_in,red_op_A,red_op_B;     
    rand logic bypass_A,bypass_B,direction;
    rand opcode_e  opcode;
    rand logic signed [2:0] A, B;

    // Constraints

    // [C1: Reset low probability]
    constraint c_reset {
      rst dist { 1 := 1, 0 := 9 }; 
    }

    // [C2: A,B biased to MAXPOS, ZERO, MAXNEG for ADD/MUL]
    constraint c_adder_bias {
      if (opcode inside {ADD_OP, MUL_OP}) {
        A dist { MAXPOS := 4, ZERO := 4, MAXNEG := 4, [-2:2] := 1 };
        B dist { MAXPOS := 4, ZERO := 4, MAXNEG := 4, [-2:2] := 1 };
      }
    }

    // [C3: OR/XOR + red_op_A high to A one-hot, B=0]
    // [C4: OR/XOR + red_op_B high to B one-hot, A=0]
    constraint c_red {
      if (opcode inside {OR_OP, XOR_OP}) {
        // red_op_A 
        if (red_op_A && !red_op_B) {
          A inside {3'b001, 3'b010, 3'b100};
          B == 3'b000;
        }
        //red_op_B 
        else if (red_op_B && !red_op_A) {
          B inside {3'b001, 3'b010, 3'b100};
          A == 3'b000;
        }
        //red_op_A & red_op_B
        else if (red_op_A && red_op_B) {
          A inside {3'b001, 3'b010, 3'b100};
          B inside {3'b001, 3'b010, 3'b100};
        }
      }
    }

    // [C5: Invalid cases less frequent]
    constraint c_invalid {
      opcode dist {INVALID_6 := 1, INVALID_7 := 1, [OR_OP:ROT_OP] := 10};
    }

    // [C6: bypass disabled most of the time]
    constraint c_bypass {
      bypass_A dist {0 := 8, 1 := 2};
      bypass_B dist {0 := 8, 1 := 2};
    }

    // [C7: No constraints on A,B if SHIFT/ROT]
    // Handled implicitly by not applying extra restrictions

    // [C8: cin relevant only for ADD_OP]
    constraint c_cin_valid {
      if (opcode == ADD_OP) {
        cin dist {0 := 1, 1 := 1}; // both 0 and 1 equally likely
      } else {
        cin == 0; // cin is not used in other operations
      }
    }


  endclass

endpackage
