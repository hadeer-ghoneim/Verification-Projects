package monitor_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class SPI_Wrapper_monitor extends uvm_monitor;
    `uvm_component_utils(SPI_Wrapper_monitor)
    
    virtual interface_wrapper vif;
    uvm_analysis_port #(SPI_Wrapper_seq_item) mon_ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual interface_wrapper)::get(this, "", "SPI_Wrapper_vif", vif))
            `uvm_fatal("NOCFG", "SPI_Wrapper interface not found")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        SPI_Wrapper_seq_item item;
        
        forever begin
            @(vif.monitor_cb);
            
            item = SPI_Wrapper_seq_item::type_id::create("item");
            
            // Capture all signals
            item.rst_n = vif.rst_n;
            item.read_data = vif.tx_data; // Data read from RAM
            
            // Capture when rx_valid is high (complete transaction)
            if (vif.rx_valid) begin
                item.operation = SPI_Wrapper_seq_item::op_type_e'(vif.rx_data[9:8]);
                case(item.operation)
                    SPI_Wrapper_seq_item::SET_ADDR:  item.address = vif.rx_data[7:0];
                    SPI_Wrapper_seq_item::WRITE:     item.data = vif.rx_data[7:0];
                    SPI_Wrapper_seq_item::READ_ADDR: item.address = vif.rx_data[7:0];
                    SPI_Wrapper_seq_item::READ_DATA: item.data = 8'h00;
                endcase
                
                `uvm_info("MONITOR", $sformatf("Captured: %s", item.convert2string()), UVM_HIGH)
                mon_ap.write(item);
            end
            
            // Also capture when tx_valid is high (read data response)
            if (vif.tx_valid) begin
                item.read_data = vif.tx_data;
                `uvm_info("MONITOR", $sformatf("Read data: 0x%02h", item.read_data), UVM_HIGH)
                mon_ap.write(item);
            end
        end
    endtask
endclass

endpackage