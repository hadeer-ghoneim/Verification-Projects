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

        // Coverage collection statistics
        int total_transactions_covered = 0;
        opcode_e last_opcode_covered;

        covergroup cvr_grp;
            option.per_instance = 1;
            option.comment = "ALSU Functional Coverage";

            // Opcode coverage
            opcode_cp : coverpoint seq_item_cov.opcode {
                bins valid_opcodes[] = {OR_OP, XOR_OP, ADD_OP, MUL_OP, SHIFT_OP, ROT_OP};
                bins invalid_opcodes[] = {INVALID_6, INVALID_7};
            }

            // A values for all operations - FIXED: Use proper 3-bit values
            A_cp : coverpoint seq_item_cov.A {
                bins zero = {0};
                bins max_pos = {3};
                bins max_neg = {-4};
                bins other_vals = {[-3:-1], [1:2]};
            }

            // B values for all operations - FIXED: Use proper 3-bit values  
            B_cp : coverpoint seq_item_cov.B {
                bins zero = {0};
                bins max_pos = {3};
                bins max_neg = {-4};
                bins other_vals = {[-3:-1], [1:2]};
            }

            // A values for reduction operations - FIXED: Use binary values
            A_red_cp : coverpoint seq_item_cov.A {
                bins walking_ones[] = {3'b001, 3'b010, 3'b100};
                illegal_bins invalid_vals = default;
            }

            // B values for reduction operations - FIXED: Use binary values
            B_red_cp : coverpoint seq_item_cov.B {
                bins walking_ones[] = {3'b001, 3'b010, 3'b100};
                illegal_bins invalid_vals = default;
            }

            // Direction coverpoint
            direction_cp : coverpoint seq_item_cov.direction {
                bins left = {0};
                bins right = {1};
            }

            // Reduction operation coverpoints
            red_A_cp : coverpoint seq_item_cov.red_op_A;
            red_B_cp : coverpoint seq_item_cov.red_op_B;

            // Bypass coverpoints
            bypass_A_cp : coverpoint seq_item_cov.bypass_A;
            bypass_B_cp : coverpoint seq_item_cov.bypass_B;

            // Cin coverpoint
            cin_cp : coverpoint seq_item_cov.cin;

            // Simple cross coverage
            cross_opcode_bypass_A: cross opcode_cp, bypass_A_cp;
            cross_opcode_bypass_B: cross opcode_cp, bypass_B_cp;
            cross_opcode_direction: cross opcode_cp, direction_cp;
            cross_red_op_valid: cross red_A_cp, red_B_cp, opcode_cp;
            cross_arith_vals: cross A_cp, B_cp;
            cross_cin_add: cross cin_cp, opcode_cp;

        endgroup

        function new(string name = "ALSU_coverage", uvm_component parent = null);
            super.new(name, parent);
            cvr_grp = new();
            last_opcode_covered = OR_OP;
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
                total_transactions_covered++;
                last_opcode_covered = seq_item_cov.opcode;
                
                `uvm_info("COVERAGE", $sformatf("Sampled transaction %0d: opcode=%s", 
                    total_transactions_covered, seq_item_cov.opcode.name()), UVM_HIGH)
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("COVERAGE_REPORT", $sformatf("Total transactions covered: %0d", total_transactions_covered), UVM_MEDIUM)
            `uvm_info("COVERAGE_REPORT", $sformatf("Last opcode covered: %s", last_opcode_covered.name()), UVM_MEDIUM)
            `uvm_info("COVERAGE_REPORT", $sformatf("Coverage percentage: %0.2f%%", cvr_grp.get_inst_coverage()), UVM_MEDIUM)
        endfunction

    endclass

endpackage