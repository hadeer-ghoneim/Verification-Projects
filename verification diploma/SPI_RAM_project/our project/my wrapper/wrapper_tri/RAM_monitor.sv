package monitor_pkg;

import uvm_pkg::*;
import RAM_seq_item_pkg::*;
`include "uvm_macros.svh"

class monitor extends uvm_monitor;

    `uvm_component_utils(monitor)
    virtual RAM_if if_ram;
    RAM_seq_item rsp_seq_item;
    uvm_analysis_port #(RAM_seq_item) mon_ap;
    
    // NEW: Additional port for SPI wrapper integration
    uvm_analysis_port #(RAM_seq_item) wrapper_ap;

    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);    
        // NEW: Create wrapper analysis port
        wrapper_ap = new("wrapper_ap", this);
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            rsp_seq_item = RAM_seq_item::type_id::create("rsp_seq_item");
            @(negedge if_ram.clk);
            rsp_seq_item.rst_n = if_ram.rst_n;
            rsp_seq_item.din = if_ram.din;
            rsp_seq_item.rx_valid = if_ram.rx_valid;
            @(negedge if_ram.clk);
            rsp_seq_item.dout = if_ram.dout;
            rsp_seq_item.tx_valid = if_ram.tx_valid;
            rsp_seq_item.dout_ref = if_ram.dout_ref;
            rsp_seq_item.tx_valid_ref = if_ram.tx_valid_ref;
            
            // NEW: Send to both ports
            mon_ap.write(rsp_seq_item);
            wrapper_ap.write(rsp_seq_item); // Send to wrapper
            
            `uvm_info("run_phase", rsp_seq_item.convert2string_stimulus(), UVM_HIGH);
        end
    endtask

endclass

endpackage