package ALSU_scoreboard_pkg;

    import ALSU_seq_item_pkg::*;
    import ALSU_golden_model_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(ALSU_scoreboard)
            
        uvm_analysis_export #(ALSU_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(ALSU_seq_item) sb_fifo;
        ALSU_seq_item seq_item_sb;
        
        // Golden model instance
        ALSU_golden_model gold_model;
        
        // Expected outputs from golden model
        logic signed [5:0] expected_out;
        logic [15:0] expected_leds;

        int error_count = 0;
        int correct_count = 0;
        int total_transactions = 0;

        function new(string name = "ALSU_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
            
            // Create golden model with same parameters as DUT
            gold_model = new("A", "ON");
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                total_transactions++;
                
                // Sample coverage
                seq_item_sb.cvr_grp.sample();
                
                // Get prediction from golden model
                gold_model.predict_output(
                    seq_item_sb.A,
                    seq_item_sb.B,
                    seq_item_sb.cin,
                    seq_item_sb.serial_in,
                    seq_item_sb.red_op_A,
                    seq_item_sb.red_op_B,
                    seq_item_sb.opcode,
                    seq_item_sb.bypass_A,
                    seq_item_sb.bypass_B,
                    seq_item_sb.direction,
                    seq_item_sb.rst,
                    expected_out,
                    expected_leds
                );
                
                // Check reset behavior first
                if (seq_item_sb.rst) begin
                    if (!gold_model.check_reset(seq_item_sb.dataout, seq_item_sb.leds)) begin
                        `uvm_error("SCOREBOARD", "Reset behavior failed!")
                        error_count++;
                    end else begin
                        correct_count++;
                    end
                end else begin
                    // Compare DUT outputs with golden model
                    if (seq_item_sb.dataout !== expected_out || seq_item_sb.leds !== expected_leds) begin
                        `uvm_error("SCOREBOARD", $sformatf("MISMATCH!\nDUT: out=%0d, leds=%0h\nGOLD: out=%0d, leds=%0h\nInputs: %s", 
                                                         seq_item_sb.dataout, seq_item_sb.leds,
                                                         expected_out, expected_leds,
                                                         seq_item_sb.convert2string_stimulus()))
                        error_count++;
                    end else begin
                        `uvm_info("SCOREBOARD", $sformatf("MATCH: out=%0d, leds=%0h, opcode=%s", 
                                                              seq_item_sb.dataout, seq_item_sb.leds, 
                                                              seq_item_sb.opcode.name()), UVM_HIGH)
                        correct_count++;
                    end
                end
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("SCOREBOARD_REPORT", $sformatf("=== GOLDEN MODEL VERIFICATION ==="), UVM_MEDIUM)
            `uvm_info("SCOREBOARD_REPORT", $sformatf("Total transactions: %0d", total_transactions), UVM_MEDIUM)
            `uvm_info("SCOREBOARD_REPORT", $sformatf("Correct: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("SCOREBOARD_REPORT", $sformatf("Errors: %0d", error_count), UVM_MEDIUM)
            
            if (error_count > 0) begin
                `uvm_error("SCOREBOARD_REPORT", "❌ TEST FAILED: Golden model mismatches detected!")
            end else begin
                `uvm_info("SCOREBOARD_REPORT", "✅ TEST PASSED: All transactions match golden model!", UVM_NONE)
            end
        endfunction

    endclass

endpackage