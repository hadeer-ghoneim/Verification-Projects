package ALSU_seq_item_pkg;

    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_seq_item extends uvm_sequence_item;
        `uvm_object_utils(ALSU_seq_item)

        // Randomizable Inputs - محدث حسب الصور
        rand logic clk, rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
        rand logic signed [2:0] A, B;
        rand opcode_e opcode;
        
        // New fields from pictures
        rand opcode_e opcode_valid[VALID_OP];
        rand reg_c enum_ext_A, enum_ext_B;
        rand logic [2:0] A_rem_values, B_rem_values;
        
        // Walking ones arrays
        bit [2:0] walking_ones[] = '{3'b001, 3'b010, 3'b100};
        rand bit [2:0] walking_ones_t, walking_ones_f;

        // Outputs
        logic signed [5:0] dataout;
        logic [15:0] leds;

        // Covergroup instance
        covergroup cvr_grp;
            option.per_instance = 1;

            // ALSU_2 ALSU_3 - A values for ADD/MULT
            A_cvp_values_ADD_MULT : coverpoint A {
                bins A_data_0 = {0};
                bins A_data_max = {3};  // MAXPOS
                bins A_data_min = {-4}; // MAXNEG
                bins A_data_default = default;
            }

            // ALSU_5 ALSU_7 - A values for reduction operations
            A_cvp_values_RED : coverpoint A iff (red_op_A) {
                bins A_walkingones[] = {3'b001, 3'b010, 3'b100};
            }

            // ALSU_2 ALSU_3 - B values for ADD/MULT
            B_cvp_values_ADD_MULT : coverpoint B {
                bins B_data_0 = {0};
                bins B_data_max = {3};  // MAXPOS
                bins B_data_min = {-4}; // MAXNEG
                bins B_data_default = default;
            }

            // ALSU_5 ALSU_7 - B values for reduction operations
            B_cvp_values_RED : coverpoint B iff (red_op_B && !red_op_A) {
                bins B_walkingones[] = {3'b001, 3'b010, 3'b100};
            }

            // ALSU_8 ALSU_9 ALSU_10 ALSU_12 - Opcode coverage
            opcode_cvp_values : coverpoint opcode {
                bins bins_shift[] = {SHIFT, ROTATE};
                bins bins_arith[] = {ADD, MULT};
                bins bins_bitwise[] = {OR, XOR};
                illegal_bins opcode_invalid = {INVALID_6, INVALID_7};
                bins opcode_valid_trans = (OR => XOR => ADD => MULT => SHIFT => ROTATE);
            }

            // Direction coverpoint
            direction_cp : coverpoint direction;

            // Reduction operation coverpoints
            red_cp_A : coverpoint red_op_A;
            red_cp_B : coverpoint red_op_B;

            // Bypass coverpoints
            bypass_A_cp : coverpoint bypass_A;
            bypass_B_cp : coverpoint bypass_B;

            // Opcode not bitwise coverpoint
            opcode_not_bitwise_cp : coverpoint opcode {
                option.weight = 0;
                bins bins_not_bitwise[] = {ADD, MULT, SHIFT, ROTATE};
            }

            // SHIFT opcode coverpoint
            opcode_SHIFT_cp : coverpoint opcode {
                bins bin_SHIFT = {SHIFT};
            }

            // ALSU_11 - Cross coverage for arithmetic operations
            cross_ARITH_PERM : cross A_cvp_values_ADD_MULT, B_cvp_values_ADD_MULT, opcode_cvp_values {
                ignore_bins non_arith = !(binsof(opcode_cvp_values) intersect {ADD, MULT});
            }

            // ALSU_2 - Cross coverage for direction and opcode
            cross_ARITH_DIR : cross direction_cp, opcode_cvp_values {
                ignore_bins non_shift_rot = !(binsof(opcode_cvp_values) intersect {SHIFT, ROTATE});
            }

            // ALSU_4 - Cross coverage for SHIFT operations
            cross_SHIFT_opcode : cross direction_cp, opcode_cvp_values {
                ignore_bins non_shift_rot = !(binsof(opcode_cvp_values) intersect {SHIFT, ROTATE});
            }

            // Cross coverage for SHIFT
            cross_SHIFT : cross opcode_SHIFT_cp, direction_cp;

            // Cross coverage for reduction A
            cross_reduction_A : cross A_cvp_values_RED, B_cvp_values_ADD_MULT, opcode_cvp_values iff (red_op_A) {
                ignore_bins non_bitwise = !(binsof(opcode_cvp_values) intersect {OR, XOR});
            }

            // Cross coverage for reduction B
            cross_reduction_B : cross B_cvp_values_RED, A_cvp_values_ADD_MULT, opcode_cvp_values iff (red_op_B) {
                ignore_bins non_bitwise = !(binsof(opcode_cvp_values) intersect {OR, XOR});
            }

            // Cross coverage for invalid A
            cross_invalid_A : cross red_cp_A, opcode_not_bitwise_cp {
                ignore_bins red_A_false = binsof(red_cp_A) intersect {0};
                ignore_bins valid_ops = binsof(opcode_cvp_values) intersect {OR, XOR};
            }

            // Cross coverage for invalid B
            cross_invalid_B : cross red_cp_B, opcode_not_bitwise_cp {
                ignore_bins red_B_false = binsof(red_cp_B) intersect {0};
                ignore_bins valid_ops = binsof(opcode_cvp_values) intersect {OR, XOR};
            }

            // Additional cross coverage from original implementation
            cross_opcode_bypass_A: cross opcode_cvp_values, bypass_A_cp;
            cross_opcode_bypass_B: cross opcode_cvp_values, bypass_B_cp;

            // Cin Coverpoint for ADD operation
            coverpoint cin iff (opcode == ADD);

        endgroup

        function new(string name = "ALSU_seq_item");
            super.new(name);
            cvr_grp = new();
        endfunction

        function string convert2string();
            return $sformatf("opcode=%s, A=%0d, B=%0d, cin=%0b, red_op_A=%0b, red_op_B=%0b, bypass_A=%0b, bypass_B=%0b, direction=%0b, serial_in=%0b, reset=%0b, dataout=%0d, leds=%0h", 
                            opcode.name(), A, B, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in, rst, dataout, leds);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("opcode=%s, A=%0d, B=%0d, cin=%0b, red_op_A=%0b, red_op_B=%0b, bypass_A=%0b, bypass_B=%0b, direction=%0b, serial_in=%0b, reset=%0b", 
                            opcode.name(), A, B, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in, rst);
        endfunction

        // CONSTRAINTS FROM PICTURES

        // ALSU_1: Reset constraint
        constraint rst_con {
            rst dist {1 := 2, 0 := 100};
        }

        // ALSU_2, ALSU_3: A,B values constraint
        constraint A_B_con {
            A_rem_values != 3 && A_rem_values != 0 && A_rem_values != -4;
            B_rem_values != 3 && B_rem_values != 0 && B_rem_values != -4;
            walking_ones_t inside {walking_ones};
            walking_ones_f inside {walking_ones};

            if (opcode inside {OR, XOR}) {
                // ALSU_5, ALSU_7: Reduction operations
                if (red_op_A == 1) {
                    B == 0;
                    A dist {walking_ones_t := 80, walking_ones_f := 20};
                } else if (red_op_B == 1) {
                    A == 0;
                    B dist {walking_ones_t := 80, walking_ones_f := 20};
                }
            } else {
                // ALSU_4, ALSU_6: Non-reduction operations
                red_op_A dist {1 := 20, 0 := 80};
                red_op_B dist {1 := 20, 0 := 80};
                
                // ALSU_2, ALSU_3: Arithmetic operations bias
                if (opcode inside {ADD, MULT}) {
                    A dist {enum_ext_A := 80, A_rem_values := 20};
                    B dist {enum_ext_B := 80, B_rem_values := 20};
                }
            }
        }

        // ALSU_10: Opcode distribution
        constraint opcode_con {
            opcode dist {[OR:ROTATE] := 80, [INVALID_6:INVALID_7] := 20};
        }

        // ALSU_11: Bypass distribution
        constraint bypass_con {
            bypass_A dist {1 := 2, 0 := 100};
            bypass_B dist {1 := 2, 0 := 100};
        }

        // ALSU_12: Unique opcode sequence
        constraint opcode_seq_con {
            foreach (opcode_valid[i]) {
                opcode_valid[i] inside {[OR:ROTATE]};
                foreach (opcode_valid[j]) {
                    if (i != j) {
                        opcode_valid[i] != opcode_valid[j];
                    }
                }
            }
        }

        // Additional constraints for valid values
        constraint valid_values {
            enum_ext_A inside {MAXPOS, ZERO, MAXNEG};
            enum_ext_B inside {MAXPOS, ZERO, MAXNEG};
            walking_ones_t inside {3'b001, 3'b010, 3'b100};
            walking_ones_f inside {[3'b000:3'b111]} with {!(item inside {3'b001, 3'b010, 3'b100});};
        }

        // Constraint for direction in SHIFT/ROTATE operations
        constraint direction_con {
            if (opcode inside {SHIFT, ROTATE}) {
                direction dist {0 := 1, 1 := 1};
            } else {
                direction == 0;
            }
        }

        // Constraint for cin in ADD operation
        constraint cin_con {
            if (opcode == ADD) {
                cin dist {0 := 1, 1 := 1};
            } else {
                cin == 0;
            }
        }

        // Constraint to prevent invalid reduction combinations
        constraint reduction_validity {
            if (red_op_A || red_op_B) {
                opcode inside {OR, XOR};
            }
        }

    endclass

endpackage