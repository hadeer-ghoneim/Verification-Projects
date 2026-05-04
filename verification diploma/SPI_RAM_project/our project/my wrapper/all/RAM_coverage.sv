package RAM_coverage_pkg;

import uvm_pkg::*;
import RAM_seq_item_pkg::*;
import RAM_sequencer_pkg::*;
import monitor_pkg::*;
`include "uvm_macros.svh"

class RAM_coverage extends uvm_component;

    `uvm_component_utils(RAM_coverage)
    uvm_analysis_export #(RAM_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(RAM_seq_item) cov_fifo;
    RAM_seq_item seq_item_cov;
    
    covergroup cvr_grp;
        cp_op : coverpoint seq_item_cov.din[9:8] {
            bins wr_addr = {2'b00};
            bins wr_data = {2'b01};
            bins rd_addr = {2'b10};
            bins rd_data = {2'b11};

            // transition bins
            bins wr_addr_to_wr_data = (2'b00 => 2'b01);
            bins rd_addr_to_rd_data = (2'b10 => 2'b11);
            bins wr_rd_sequence = (2'b00 => 2'b01 => 2'b10 => 2'b11);
        }

        cp_rx : coverpoint seq_item_cov.rx_valid {
            bins r_valid_low  = {1'b0};
            bins r_valid_high = {1'b1};
        }

        cp_tx : coverpoint seq_item_cov.tx_valid {
            bins t_valid_low  = {1'b0};
            bins t_valid_high = {1'b1};
        }

        // cross: din[9:8] x rx_valid (only need the rx_valid high in the cross)
        cross_op_rx : cross cp_op, cp_rx {
            bins cross_when_valid = binsof(cp_op) && binsof(cp_rx.r_valid_high);
        }

        // cross: when din == read_data (2'b11) cross tx_valid==1
        cross_rd_tx : cross cp_op, cp_tx {
            bins rddata_txvalid = binsof(cp_op) && binsof(cp_tx.t_valid_high);
        }
    endgroup

    function new(string name = "RAM_coverage", uvm_component parent = null);
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