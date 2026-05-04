package sequence_wrapper; //Stimulus
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class sequence_wrapper extends uvm_sequence#(SPI_Wrapper_seq_item);  // FIXED: Use SPI_Wrapper_seq_item

    `uvm_object_utils(sequence_wrapper)

    // Constructor
    function new(string name = "sequence_wrapper");
        super.new(name);
    endfunction

    // Body phase
    virtual task body();
        SPI_Wrapper_seq_item item;  // FIXED: Declare inside body; use SPI_Wrapper_seq_item
        
        // Create a new sequence item
        item = SPI_Wrapper_seq_item::type_id::create("item");  // FIXED: Use SPI_Wrapper_seq_item
        
        repeat(10000) begin
             // Start the item
            start_item(item);
            // Randomize the item
            assert(item.randomize() with {rst_n == 1;});  // FIXED: Add constraint for normal op; assert for safety
            // Finish the item
            finish_item(item);
            
            `uvm_info(get_type_name(), $sformatf("Generated transaction: %s", item.convert2string()), UVM_MEDIUM);
        end
       
    endtask

endclass
    
endpackage
/*
package sequence_wrapper; //Stimulus
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class sequence_wrapper extends uvm_sequence#(sequence_wrapper_item);

    `uvm_object_utils(sequence_wrapper)

    sequence_wrapper_item item;

    // Constructor
    function new(string name = "sequence_wrapper");
        super.new(name);
    endfunction


    // Body phase
    virtual task body();
        sequence_wrapper_item item;
        
        // Create a new sequence item
        item = sequence_wrapper_item::type_id::create("item");
        
        repeat(10000) begin
             // Start the item
            start_item(item);
            // Randomize the item
            assert(item.randomize());
            // Finish the item
            finish_item(item);
        end
       
    endtask

endclass
    
endpackage
*/