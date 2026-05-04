package scoreboard_ram;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequnce_ram_item::*;
import sequencer_ram::*;

class scoreboard_ram extends uvm_scoreboard;
    `uvm_component_utils(scoreboard_ram)

    uvm_analysis_export #(sequnce_ram_item) sb_export;
    uvm_tlm_analysis_fifo #(sequnce_ram_item) sb_fifo;
    sequnce_ram_item seq_item_sb;

    logic signed [5:0] out_ref;

    int error_count = 0;
    int correct_count = 0;

    // Constructor
    function new(string name = "RAM_scoreboard", uvm_component parent = null);
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

            if (seq_item_sb.dout != seq_item_sb.dout_ref || seq_item_sb.tx_valid != seq_item_sb.tx_valid_ref) begin
                `uvm_info("run_phase", $sformatf("Comparison unsuccessful, transaction: %s",
                    seq_item_sb.convert2string()), UVM_HIGH)
                error_count++;
            end else begin
                correct_count++;
            end
        end
    endtask

    // Golden model task - replicates RTL behavior
    task ref_model(sequnce_ram_item seq_item_chk);
        
    endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("report_phase", $sformatf("Total correct: %0d", correct_count), UVM_MEDIUM);
        `uvm_info("report_phase", $sformatf("Total errors: %0d", error_count), UVM_MEDIUM);
    endfunction

endclass
endpackage