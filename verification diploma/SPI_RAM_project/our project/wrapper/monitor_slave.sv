// monitor_slave.sv
package monitor_slave;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_slave_item::*;

class monitor_slave extends uvm_monitor;
    `uvm_component_utils(monitor_slave)

    virtual interface_slave vif;
    sequence_slave_item item;
    uvm_analysis_port#(sequence_slave_item) mon_ap;

    function new(string name = "monitor_slave", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_ap = new("mon_ap", this);
        
        // Get virtual interface from config DB
        if(!uvm_config_db#(virtual interface_slave)::get(this, "", "vif_slave", vif)) begin
            `uvm_fatal("NOVIF", "virtual interface for slave monitor not found")
        end
        
        `uvm_info("MONITOR", "Virtual interface found successfully", UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        `uvm_info("MONITOR", "Starting monitor run_phase", UVM_LOW)
        
        // Wait a bit for reset and signals to stabilize
        #100;
        
        forever begin
            item = sequence_slave_item::type_id::create("item");
            
            // Wait for clock edge
            @(posedge vif.clk);
            
            // Sample all signals
            item.rst_n = vif.rst_n;
            item.SS_n = vif.SS_n;
            item.tx_valid = vif.tx_valid;
            item.tx_data = vif.tx_data;
            item.MISO = vif.MISO;
            item.rx_valid = vif.rx_valid;
            item.rx_data = vif.rx_data;
            item.MISO_ref = vif.MISO_ref;
            item.rx_valid_ref = vif.rx_valid_ref;
            item.rx_data_ref = vif.rx_data_ref;
            
            mon_ap.write(item);
            
            `uvm_info("MONITOR", $sformatf("Sampled: rst_n=%b, SS_n=%b, rx_valid=%b", 
                       vif.rst_n, vif.SS_n, vif.rx_valid), UVM_MEDIUM)
        end
    endtask

endclass

endpackage