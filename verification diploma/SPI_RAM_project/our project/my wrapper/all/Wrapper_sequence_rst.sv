package sequence_rst_wrapper; 

`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class sequence_rst_wrapper extends uvm_sequence#(SPI_Wrapper_seq_item);  // FIXED: Use SPI_Wrapper_seq_item

    `uvm_object_utils(sequence_rst_wrapper)

    SPI_Wrapper_seq_item item;  // FIXED: Use SPI_Wrapper_seq_item

    // Constructor
    function new(string name = "sequence_rst_wrapper");
        super.new(name);
    endfunction

    // Body phase
    virtual task body();
  
        // Create a new sequence item
        item = SPI_Wrapper_seq_item::type_id::create("item");  // FIXED: Use SPI_Wrapper_seq_item
        
        start_item(item);
        // rst 
        assert(item.randomize() with {rst_n == 0;});  // FIXED: Use randomize with constraint for rst_n=0
        // Finish the item
        finish_item(item);
        
        `uvm_info(get_type_name(), "Reset sequence applied", UVM_MEDIUM);
        
    endtask


endclass
    
endpackage
/*
package sequence_rst_wrapper; 

`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class sequence_rst_wrapper extends uvm_sequence#(sequence_wrapper_item);

    `uvm_object_utils(sequence_rst_wrapper)

    sequence_wrapper_item item;

    // Constructor
    function new(string name = "sequence_rst_wrapper");
        super.new(name);
    endfunction

    // Body phase
    virtual task body();
  
        // Create a new sequence item
        item = sequence_wrapper_item::type_id::create("item");
       
            start_item(item);
            // rst 

            item.rst_n = 0; // Set reset to low

            // Finish the item
            finish_item(item);
        
    endtask


endclass
    
endpackage
*/