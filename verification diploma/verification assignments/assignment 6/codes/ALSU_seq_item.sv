package ALSU_seq_item_pkg;

    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_seq_item extends uvm_sequence_item;
        `uvm_object_utils(ALSU_seq_item)

        // Constants
        localparam signed [2:0] MAXPOS = 3;
        localparam signed [2:0] MAXNEG = -4;
        localparam signed [2:0] ZERO   = 0;

        // Randomizable Inputs
        rand opcode_e opcode;
        rand direction_e direction; 
        rand logic signed [2:0] A;
        rand logic signed [2:0] B;
        rand logic cin;
        rand logic serial_in;
        rand logic red_op_A;
        rand logic red_op_B;
        rand logic bypass_A;
        rand logic bypass_B;
        rand logic reset;
        
        // Fixed array for constraint #8
        rand opcode_e opcode_seq[6];
        
        // Outputs
        logic signed [5:0] dataout;
        logic [15:0] leds;

        // Constraint enable flags
        rand bit en_c1 = 1;
        rand bit en_c2 = 1;
        rand bit en_c3 = 1;
        rand bit en_c8 = 1;

        function new(string name = "ALSU_seq_item");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("%s opcode_e=%s, direction_e=%s, A=0x%0h, B=0x%0h, cin=0x%0h, serial_in=0x%0h, red_op_A=%0b, red_op_B=%0b, bypass_A=%0b, bypass_B=%0b, reset=%0b, dataout=0x%0h, leds=0x%0h", 
                            super.convert2string(), opcode.name(), direction.name(), A, B, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, reset, dataout, leds);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("opcode_e=%s, direction_e=%s, A=0x%0h, B=0x%0h, cin=0x%0h, serial_in=0x%0h, red_op_A=%0b, red_op_B=%0b, bypass_A=%0b, bypass_B=%0b, reset=%0b", 
                            opcode.name(), direction.name(), A, B, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, reset);
        endfunction
        
        // -------- Constraints from alsu_pkg --------
        
        // [C1: Reset low probability]
        constraint c_reset {
            if (en_c1) reset dist { 1 := 1, 0 := 9 }; 
        }

        // [C2: A,B biased to MAXPOS, ZERO, MAXNEG for ADD/MUL]
        constraint c_adder_bias {
            if (en_c2 && opcode inside {ADD_OP, MUL_OP}) {
                A dist { MAXPOS := 4, ZERO := 4, MAXNEG := 4, [-2:2] := 1 };
                B dist { MAXPOS := 4, ZERO := 4, MAXNEG := 4, [-2:2] := 1 };
            }
        }

        // [C3 & C4: OR/XOR + red_op constraints]
        constraint c_red {
            if (en_c3 && opcode inside {OR_OP, XOR_OP}) {
                // red_op_A 
                if (red_op_A && !red_op_B) {
                    A inside {3'b001, 3'b010, 3'b100};
                    B == 3'b000;
                }
                // red_op_B 
                else if (red_op_B && !red_op_A) {
                    B inside {3'b001, 3'b010, 3'b100};
                    A == 3'b000;
                }
                // red_op_A & red_op_B
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
            if (en_c8 && opcode == ADD_OP) {
                cin dist {0 := 1, 1 := 1}; // both 0 and 1 equally likely
            } else {
                cin == 0; // cin is not used in other operations
            }
        }

        // Additional constraint for unique opcode sequence
        constraint unique_opcodes {
            if (en_c8) {
                foreach (opcode_seq[i]) opcode_seq[i] inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP};
                unique {opcode_seq};
            }
        }

        // Additional constraint for direction in SHIFT/ROT operations
        constraint c_direction {
            if (opcode inside {SHIFT_OP, ROT_OP}) {
                direction dist {0 := 1, 1 := 1}; // both directions equally likely
            }
        }

        // Domain constraint for opcode
        constraint c_opcode_domain {
            opcode inside {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP, INVALID_6, INVALID_7};
        }

    endclass
    
endpackage

