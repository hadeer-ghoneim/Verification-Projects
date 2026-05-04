package driver_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class SPI_Wrapper_driver extends uvm_driver #(SPI_Wrapper_seq_item);
    `uvm_component_utils(SPI_Wrapper_driver)
    
    virtual interface_wrapper if_wrapper;  // FIXED: Use correct interface name from Wrapper_if.sv
    SPI_Wrapper_seq_item item;
    
    // Constructor
    function new(string name = "driver_wrapper", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
       // if(!uvm_config_db#(virtual interface_wrapper)::get(this, "", "if_wrapper", if_wrapper))  // FIXED: Get from config_db
        //    `uvm_fatal(get_type_name(), "Virtual interface not found");
        
        item = SPI_Wrapper_seq_item::type_id::create("item");
        
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            // Get the next item from the sequencer
            seq_item_port.get_next_item(item);

            // Drive the item to the virtual interface
            if (item != null) begin
                // Drive reset first
                if_wrapper.rst_n <= item.rst_n;
                
                // Start SPI transaction: Assert SS_n low
                if_wrapper.SS_n <= 0;
                
                // Serialize and drive 11-bit spi_frame (MSB first, common for SPI)
                for (int i = 10; i >= 0; i--) begin
                    if_wrapper.MOSI_data <= item.spi_frame[i];  // FIXED: Serialize spi_frame to MOSI
                    @(posedge if_wrapper.clk);  // Drive on posedge clk
                end
                
                // End transaction: Deassert SS_n high
                if_wrapper.SS_n <= 1;
                
                // Wait one cycle for completion
                @(posedge if_wrapper.clk);
                
                seq_item_port.item_done();
            end
        end
    endtask
    
endclass

endpackage
/*
package driver_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class SPI_Wrapper_driver extends uvm_driver #(SPI_Wrapper_seq_item);
    `uvm_component_utils(SPI_Wrapper_driver)
    
    virtual SPI_Wrapper_if if_wrapper;
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
                if_wrapper.rst_n = item.rst_n;
                if_wrapper.MOSI = item.MOSI;
                if_wrapper.SS_n = item.SS_n;

                @(negedge if_wrapper.clk); // Wait for the clock edge
                seq_item_port.item_done();
            end
        end
    endtask
    
endclass

endpackage
*/