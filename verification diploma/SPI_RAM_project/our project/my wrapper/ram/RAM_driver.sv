package RAM_driver_pkg;
import uvm_pkg::*;
import RAM_seq_item_pkg::*;
`include "uvm_macros.svh"

class RAM_driver extends uvm_driver #(RAM_seq_item);
    `uvm_component_utils(RAM_driver)

    virtual RAM_vif vif;
    
    function new(string name = "RAM_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual RAM_vif)::get(this, "", "RAM_VIF", vif))
            `uvm_fatal("NOCFG", "RAM virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        // Initialize signals
        vif.driver_cb.rst_n <= 1;
        vif.driver_cb.rx_valid <= 0;
        vif.driver_cb.din <= 0;
        @(posedge vif.clk);
        
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(RAM_seq_item item);
        `uvm_info("RAM_DRIVER", $sformatf("Driving: %s", item.convert2string_stimulus()), UVM_MEDIUM)
        
        // Handle reset
        if (!item.rst_n) begin
            vif.driver_cb.rst_n <= 0;
            vif.driver_cb.rx_valid <= 0;
            repeat(3) @(vif.driver_cb);
            vif.driver_cb.rst_n <= 1;
            @(vif.driver_cb);
            return;
        end
        
        // Drive transaction based on rx_valid
        if (item.rx_valid) begin
            vif.driver_cb.rx_valid <= 1;
            vif.driver_cb.din <= item.din;
            @(vif.driver_cb);
            vif.driver_cb.rx_valid <= 0;
            
            // For read operations, capture the response
            if (item.operation inside {RAM_seq_item::READ_DATA}) begin
                // Wait for tx_valid response from RAM
                wait(vif.tx_valid == 1);
                item.read_data = vif.dout;
                @(vif.driver_cb);
            end
        end else begin
            // No valid transaction this cycle
            @(vif.driver_cb);
        end
    endtask

endclass
endpackage