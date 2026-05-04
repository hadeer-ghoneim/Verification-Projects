package driver_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class SPI_Wrapper_driver extends uvm_driver #(SPI_Wrapper_seq_item);
    `uvm_component_utils(SPI_Wrapper_driver)
    
    virtual SPI_Wrapper_if vif;
    SPI_Wrapper_seq_item item;
    
 // Constructor
    function new(string name = "driver_wrapper", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        item = SPI_Wrapper_seq_item::type_id::create("item");
        
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        

        forever begin
            // Get the next item from the sequencer
            seq_item_port.get_next_item(item);

            // Drive the item to the virtual interface
            if (item != null) begin
                // Add your driving logic here
                vif.rst_n = item.rst_n;
                vif.MOSI = item.MOSI;
                vif.SS_n = item.SS_n;

                @(negedge vif.clk); // Wait for the clock edge
                seq_item_port.item_done();
            end
        end
    endtask
    
endclass

endpackage