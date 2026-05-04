package ALSU_coverage_pkg;

    import ALSU_seq_item_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_coverage extends uvm_component;
        `uvm_component_utils(ALSU_coverage)

        uvm_analysis_export #(ALSU_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(ALSU_seq_item) cov_fifo;
        ALSU_seq_item seq_item_cov;

        // Constants for edge cases
        localparam signed [2:0] MAXPOS = 3;
        localparam signed [2:0] MAXNEG = -4;

        covergroup cvr_grp;
            option.per_instance = 1;

            // ALSU_2 ALSU_3 - A values for ADD/MULT
            A_cvp_values_ADD_MULT : coverpoint seq_item_cov.A {
                bins A_data_0 = {0};
                bins A_data_max = {MAXPOS};
                bins A_data_min = {MAXNEG};
                bins A_data_default = default;
            }

            // ALSU_5 ALSU_7 - A values for reduction operations
            A_cvp_values_RED : coverpoint seq_item_cov.A iff (seq_item_cov.red_op_A) {
                bins A_walkingones[] = {3'b001, 3'b010, 3'b100};
            }

            // ALSU_2 ALSU_3 - B values for ADD/MULT
            B_cvp_values_ADD_MULT : coverpoint seq_item_cov.B {
                bins B_data_0 = {0};
                bins B_data_max = {MAXPOS};
                bins B_data_min = {MAXNEG};
                bins B_data_default = default;
            }

            // ALSU_5 ALSU_7 - B values for reduction operations
            B_cvp_values_RED : coverpoint seq_item_cov.B iff (seq_item_cov.red_op_B && !seq_item_cov.red_op_A) {
                bins B_walkingones[] = {3'b001, 3'b010, 3'b100};
            }

            // ALSU_8 ALSU_9 ALSU_10 ALSU_12 - Opcode coverage
            opcode_cvp_values : coverpoint seq_item_cov.opcode {
                bins bins_shift_rot[] = {SHIFT_OP, ROT_OP};
                bins bins_arith[] = {ADD_OP, MUL_OP};
                illegal_bins opcode_invalid = {INVALID_6, INVALID_7};
                bins opcode_valid_trans = (OR_OP => XOR_OP => ADD_OP => MUL_OP => SHIFT_OP => ROT_OP);
            }

            // Direction coverpoint
            direction_cp : coverpoint seq_item_cov.direction;

            // Reduction operation coverpoints
            red_cp_A : coverpoint seq_item_cov.red_op_A;
            red_cp_B : coverpoint seq_item_cov.red_op_B;

            // Opcode not bitwise coverpoint
            opcode_not_bitwise_cp : coverpoint seq_item_cov.opcode {
                option.weight = 0;
                bins bins_not_bitwise[] = {ADD_OP, MUL_OP, SHIFT_OP, ROT_OP};
            }

            // SHIFT opcode coverpoint
            opcode_SHIFT_cp : coverpoint seq_item_cov.opcode {
                bins bin_SHIFT = {SHIFT_OP};
            }

            // ALSU_11 - Cross coverage for arithmetic operations
            cross_ARITH_PERM : cross A_cvp_values_ADD_MULT, B_cvp_values_ADD_MULT, opcode_cvp_values {
                ignore_bins is_bins_shift = binsof(opcode_cvp_values.bins_shift_rot);
                ignore_bins is_bins_trans = binsof(opcode_cvp_values.opcode_valid_trans);
            }

            // ALSU_2 - Cross coverage for direction and opcode
            cross_ARITH_DIR : cross direction_cp, opcode_cvp_values {
                option.cross_auto_bin_max = 0;
                bins is_bins_arith = binsof(opcode_cvp_values.bins_arith);
            }

            // ALSU_4 - Cross coverage for SHIFT operations
            cross_SHIFT_opcode : cross direction_cp, opcode_cvp_values {
                option.cross_auto_bin_max = 0;
                bins is_bins_shift = binsof(opcode_cvp_values.bins_shift_rot);
            }

            // ALSU_C - Cross coverage for SHIFT
            cross_SHIFT : cross opcode_SHIFT_cp, direction_cp;

            // ALSU_C - Cross coverage for reduction A
            cross_reduction_A : cross A_cvp_values_RED, B_cvp_values_ADD_MULT, opcode_cvp_values iff (seq_item_cov.red_op_A) {
                ignore_bins B_data_max_ = binsof(B_cvp_values_ADD_MULT.B_data_max);
                ignore_bins B_data_min_ = binsof(B_cvp_values_ADD_MULT.B_data_min);
            }

            // ALSU_C - Cross coverage for reduction B
            cross_reduction_B : cross B_cvp_values_RED, A_cvp_values_ADD_MULT, opcode_cvp_values iff (seq_item_cov.red_op_B) {
                ignore_bins A_data_max_ = binsof(A_cvp_values_ADD_MULT.A_data_max);
                ignore_bins A_data_min_ = binsof(A_cvp_values_ADD_MULT.A_data_min);
            }

            // ALSU_C - Cross coverage for invalid A
            cross_invalid_A : cross red_cp_A, opcode_not_bitwise_cp {
                ignore_bins red_A_0 = binsof(red_cp_A) intersect {0};
                illegal_bins red_A_1_111 = binsof(red_cp_A) intersect {1};
            }

            // ALSU_C - Cross coverage for invalid B
            cross_invalid_B : cross red_cp_B, opcode_not_bitwise_cp {
                ignore_bins red_B_0 = binsof(red_cp_B) intersect {0};
                illegal_bins red_B_1_111 = binsof(red_cp_B) intersect {1};
            }

            // Additional cross coverage from original implementation
            cross_opcode_bypass_A: cross seq_item_cov.opcode, seq_item_cov.bypass_A;
            cross_opcode_bypass_B: cross seq_item_cov.opcode, seq_item_cov.bypass_B;


            // Cin Coverpoint for ADD operation
            coverpoint seq_item_cov.cin iff (seq_item_cov.opcode == ADD_OP);

        endgroup

        function new(string name = "ALSU_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvr_grp = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                cvr_grp.sample();
            end
        endtask
    endclass

endpackage


/*
package ALSU_coverage_pkg;

    import ALSU_seq_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_coverage extends uvm_component;
        `uvm_component_utils(ALSU_coverage)

        uvm_analysis_export #(ALSU_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(ALSU_seq_item) cov_fifo;
        ALSU_seq_item seq_item_cov;

        // Constants for edge cases
        localparam signed [2:0] MAXPOS = 3;
        localparam signed [2:0] MAXNEG = -4;

        covergroup cvr_grp;
            option.per_instance = 1;

            // A Coverpoint
            coverpoint seq_item_cov.A {
                bins A_data_0       = {0};
                bins A_data_max     = {MAXPOS};
                bins A_data_min     = {MAXNEG};
                bins A_data_default = default;
            }

            // B Coverpoint
            coverpoint seq_item_cov.B {
                bins B_data_0       = {0};
                bins B_data_max     = {MAXPOS};
                bins B_data_min     = {MAXNEG};
                bins B_data_default = default;
            }

            // Opcode Coverpoint
            coverpoint seq_item_cov.opcode {
                bins bins_shift[]   = {SHIFT_OP, ROT_OP};
                bins bins_arith[]   = {ADD_OP, MUL_OP};
                bins bins_bitwise[] = {OR_OP, XOR_OP};
                illegal_bins bins_invalid = {INVALID_6, INVALID_7};
            }

            // Reduction Operations Coverpoints
            coverpoint seq_item_cov.A iff (seq_item_cov.red_op_A && !seq_item_cov.red_op_B && seq_item_cov.opcode inside {OR_OP, XOR_OP}) {
                bins walking_ones[] = {3'b001, 3'b010, 3'b100};
            }

            coverpoint seq_item_cov.B iff (seq_item_cov.red_op_B && !seq_item_cov.red_op_A && seq_item_cov.opcode inside {OR_OP, XOR_OP}) {
                bins walking_ones[] = {3'b001, 3'b010, 3'b100};
            }

            // Bypass Coverpoints
            coverpoint seq_item_cov.bypass_A;
            coverpoint seq_item_cov.bypass_B;

            // Direction Coverpoint
            coverpoint seq_item_cov.direction;

            // Cin Coverpoint for ADD operation
            coverpoint seq_item_cov.cin iff (seq_item_cov.opcode == ADD_OP);

            // Cross Coverage
            cross_opcode_bypass_A: cross seq_item_cov.opcode, seq_item_cov.bypass_A;
            cross_opcode_bypass_B: cross seq_item_cov.opcode, seq_item_cov.bypass_B;
            cross_opcode_direction: cross seq_item_cov.opcode, seq_item_cov.direction 
                iff (seq_item_cov.opcode inside {SHIFT_OP, ROT_OP});

        endgroup

        function new(string name = "ALSU_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvr_grp = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                cvr_grp.sample();
            end
        endtask
    endclass

endpackage

*/