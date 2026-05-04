package ALSU_scoreboard_pkg;

    import ALSU_seq_item_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(ALSU_scoreboard)
            
        uvm_analysis_export #(ALSU_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(ALSU_seq_item) sb_fifo;
        ALSU_seq_item seq_item_sb;
        logic signed [5:0] alsu_out_ref;
        logic [15:0] leds_ref;

        int error_count = 0;
        int correct_count = 0;

        function new(string name = "ALSU_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                ref_model(seq_item_sb);
                if (seq_item_sb.dataout !== alsu_out_ref || seq_item_sb.leds !== leds_ref) begin
                    `uvm_error("run_phase", $sformatf("Comparison failed: DUT_OUT=%0h, REF_OUT=%0h, DUT_LEDS=%0h, REF_LEDS=%0h\n%s", 
                                                     seq_item_sb.dataout, alsu_out_ref, seq_item_sb.leds, leds_ref, 
                                                     seq_item_sb.convert2string()))
                    error_count++;
                end else begin
                    `uvm_info("run_phase", $sformatf("Correct: %s", seq_item_sb.convert2string()), UVM_HIGH)
                    correct_count++;
                end
            end
        endtask

        task ref_model(ALSU_seq_item seq_item_clk);
            logic invalid_red_op, invalid_opcode, invalid;
            
            // Calculate invalid signals (same as DUT)
            invalid_red_op = (seq_item_clk.red_op_A | seq_item_clk.red_op_B) & (seq_item_clk.opcode[1] | seq_item_clk.opcode[2]);
            invalid_opcode = seq_item_clk.opcode[1] & seq_item_clk.opcode[2];
            invalid = invalid_red_op | invalid_opcode;
            
            // LED reference model (blinking when invalid)
            if (invalid)
                leds_ref = ~leds_ref; // Toggle for blinking effect
            else
                leds_ref = 0;
            
            if (seq_item_clk.reset) begin
                alsu_out_ref = 0;
            end else if (invalid) begin
                alsu_out_ref = 0;
            end else if (seq_item_clk.bypass_A && seq_item_clk.bypass_B) begin
                alsu_out_ref = (INPUT_PRIORITY == "A") ? seq_item_clk.A : seq_item_clk.B;
            end else if (seq_item_clk.bypass_A) begin
                alsu_out_ref = seq_item_clk.A;
            end else if (seq_item_clk.bypass_B) begin
                alsu_out_ref = seq_item_clk.B;
            end else begin
                case (seq_item_clk.opcode)
                    OR_OP: begin 
                        if (seq_item_clk.red_op_A && seq_item_clk.red_op_B)
                            alsu_out_ref = (INPUT_PRIORITY == "A") ? |seq_item_clk.A : |seq_item_clk.B;
                        else if (seq_item_clk.red_op_A) 
                            alsu_out_ref = |seq_item_clk.A;
                        else if (seq_item_clk.red_op_B)
                            alsu_out_ref = |seq_item_clk.B;
                        else 
                            alsu_out_ref = seq_item_clk.A | seq_item_clk.B;
                    end
                    XOR_OP: begin
                        if (seq_item_clk.red_op_A && seq_item_clk.red_op_B)
                            alsu_out_ref = (INPUT_PRIORITY == "A") ? ^seq_item_clk.A : ^seq_item_clk.B;
                        else if (seq_item_clk.red_op_A) 
                            alsu_out_ref = ^seq_item_clk.A;
                        else if (seq_item_clk.red_op_B)
                            alsu_out_ref = ^seq_item_clk.B;
                        else 
                            alsu_out_ref = seq_item_clk.A ^ seq_item_clk.B;
                    end
                    ADD_OP: alsu_out_ref = (FULL_ADDER == "ON") ? (seq_item_clk.A + seq_item_clk.B + seq_item_clk.cin) : (seq_item_clk.A + seq_item_clk.B);
                    MUL_OP: alsu_out_ref = seq_item_clk.A * seq_item_clk.B;
                    SHIFT_OP: begin
                        if (seq_item_clk.direction == DIR_LEFT)
                            alsu_out_ref = {seq_item_clk.dataout[4:0], seq_item_clk.serial_in};
                        else
                            alsu_out_ref = {seq_item_clk.serial_in, seq_item_clk.dataout[5:1]};
                    end
                    ROT_OP: begin
                        if (seq_item_clk.direction == DIR_LEFT)
                            alsu_out_ref = {seq_item_clk.dataout[4:0], seq_item_clk.dataout[5]};
                        else
                            alsu_out_ref = {seq_item_clk.dataout[0], seq_item_clk.dataout[5:1]};
                    end
                    default: alsu_out_ref = 0;
                endcase
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM)
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM)
        endfunction

    endclass

endpackage