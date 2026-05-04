package scoreboard_pkg;
import agent_pkg::*;
import shared_pkg::*;
import sequenceItem_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name, this);

class ALSU_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ALSU_scoreboard)
    uvm_analysis_export #(ALSU_sequenceItem) sb_export; // scoreboard export
    uvm_tlm_analysis_fifo #(ALSU_sequenceItem) sb_fifo; // scoreboard fifo
    ALSU_sequenceItem sb_seq_item;
    // refrence output
    logic [15:0] leds_ref;
    logic [5:0] out_ref;
    
    // error and correct counter
    int correct_counter = 0;
    int error_counter = 0;

    function new(string name = "ALSU_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction //new()

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
            sb_fifo.get(sb_seq_item);
            //// Checking //////
            Checking_task(sb_seq_item);
        end
    endtask

    task Checking_task(ALSU_sequenceItem chk_item);
        if (chk_item.out != chk_item.out_ref || chk_item.leds != chk_item.leds_ref) begin
            error_counter++;
            `uvm_error("scoreboard",$sformatf("%0s\nout_ref = %0d,",chk_item.convert2string(), chk_item.out_ref))
        end else begin
            correct_counter++;
        end
    endtask //Checking_task

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("report_phase", $sformatf("Total correct transaction: %0d", correct_counter), UVM_LOW)
        `uvm_info("report_phase", $sformatf("Total faild transaction: %0d", error_counter), UVM_LOW)
    endfunction
endclass //ALSU_scoreboard extends uvm_scoreboard
endpackage