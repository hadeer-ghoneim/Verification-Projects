package coverage_ram;
import uvm_pkg::*;
`include "uvm_macros.svh"
import sequnce_ram_item::*;

class coverage_ram extends uvm_component;
    `uvm_component_utils(coverage_ram)

    uvm_analysis_export #(sequnce_ram_item) cov_export;
    uvm_tlm_analysis_fifo #(sequnce_ram_item) cov_fifo;
    sequnce_ram_item item;

    covergroup cvr_grp;
        cp_op : coverpoint item.din[9:8] {
            bins wr_addr = {2'b00};
            bins wr_data = {2'b01};
            bins rd_addr = {2'b10};
            bins rd_data = {2'b11};

            // transition bins
            bins wr_addr_to_wr_data = (2'b00 => 2'b01);
            bins rd_addr_to_rd_data = (2'b10 => 2'b11);
            bins wr_rd_sequence = (2'b00 => 2'b01 => 2'b10 => 2'b11);
        }

        cp_rx : coverpoint item.rx_valid {
            bins r_valid_low  = {1'b0};
            bins r_valid_high = {1'b1};
        }

        cp_tx : coverpoint item.tx_valid {
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


function new(string name = "coverage_ram ", uvm_component parent = null);
        super.new(name, parent);
        cvr_grp=new();
    endfunction //new()
    
function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       cov_export = new("cov_export", this);
        cov_fifo = new("cov_fifo");
        // Register the analysis export with the FIFO
    
    endfunction //build_phase()

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
    endfunction //connect_phase()

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            // Wait for an item to be written to the FIFO
            cov_fifo.get(item);
           cvr_grp.sample();
           
            
        end
    endtask
    

    
endclass    
    
endpackage