package sequence_wrapper; //Stimulus
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;
import sequnce_ram_item::*;

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

    /*
    4- For a write-only sequence, every Write Address operation shall always be followed by either
    Write Address or Write Data operation.

    5- For a read-only sequence, every Read Address operation shall always be followed by Read
    Data. After a Read Data operation shall always be followed by Read Address.

    6- For a randomized read/write sequence, the following ordering rules shall be enforced:
    • Every Write Address operation shall always be followed by either Write Address or
    Write Data operation.
    
    • After a Write Data, the next operation shall be chosen with the following probability
    distribution: 60% → Read Address & 40% → Write Address.
    • Every Read Address operation shall always be followed by Read Data operation.
    • After a Read Data, the next operation shall be chosen with the following probability
    distribution: 60% → Write Address & 40% → Read Address.
    */
    
    // =============================================================
    // Write Only Sequence
    // =============================================================
    class write_only_sequence extends uvm_sequence #(sequnce_ram_item);
        `uvm_object_utils(write_only_sequence)
        sequnce_ram_item seq_item;

        function new(string name = "write_only_sequence");
            super.new(name);
            seq_item.prev_op = 2'b10;
        endfunction

        task body();
            seq_item = sequnce_ram_item::type_id::create("seq_item");
            repeat(3300) begin
                start_item(seq_item);
                assert(seq_item.randomize() with {
                    din[9:8] inside {2'b00, 2'b01};
                    if (seq_item.prev_op == 2'b00)      
                        din[9:8] inside {2'b01, 2'b00};  
                    else if (seq_item.prev_op == 2'b01) 
                        din[9:8] inside {2'b01, 2'b00};  
                    }
                );
                finish_item(seq_item);
                seq_item.prev_op = seq_item.din[9:8];
            end 
        endtask

    endclass



    // =============================================================
    // Read Only Sequence
    // =============================================================
    class read_only_sequence extends uvm_sequence #(sequnce_ram_item);
        `uvm_object_utils(read_only_sequence)
        sequnce_ram_item seq_item;

        function new(string name = "read_only_sequence");
            super.new(name);
            seq_item.prev_op = 2'b10;
        endfunction

        task body();
            seq_item = sequnce_ram_item::type_id::create("seq_item");
            repeat(3300) begin
                start_item(seq_item);
                assert(seq_item.randomize() with {
                    din[9:8] inside {2'b10, 2'b11};
                    if (seq_item.prev_op == 2'b10)      
                        din[9:8] inside {2'b10, 2'b11};  
                    else if (seq_item.prev_op == 2'b11) 
                        din[9:8] inside {2'b10, 2'b11};  
                    (seq_item.prev_op == seq_item.WRITE_ADDR) -> 
                    (din[9:8] inside {seq_item.WRITE_ADDR, seq_item.WRITE_DATA});
                    }
                );
                finish_item(seq_item);
                seq_item.prev_op = seq_item.din[9:8];
            end 
        endtask

    endclass



    // =============================================================
    // Write + Read (Mixed) Sequence
    // =============================================================
    class write_read_sequence extends uvm_sequence #(sequnce_ram_item);
    `uvm_object_utils(write_read_sequence)
    sequnce_ram_item seq_item;

    function new(string name = "write_read_sequence");
        super.new(name);
        seq_item.prev_op = seq_item.WRITE_ADDR;
    endfunction

    task body;
        seq_item = sequnce_ram_item::type_id::create("seq_item");
        repeat(3400) begin
            start_item(seq_item);
            assert(seq_item.randomize() with {
                (seq_item.prev_op == seq_item.WRITE_ADDR) -> (din[9:8] inside {seq_item.WRITE_ADDR, seq_item.WRITE_DATA});
                (seq_item.prev_op == seq_item.WRITE_DATA) -> din[9:8] dist {seq_item.READ_ADDR := 60, seq_item.WRITE_ADDR := 40};
                (seq_item.prev_op == seq_item.READ_ADDR)  -> (din[9:8] inside {seq_item.READ_ADDR, seq_item.READ_DATA});
                (seq_item.prev_op == seq_item.READ_DATA)  -> din[9:8] dist {seq_item.WRITE_ADDR := 60, seq_item.READ_ADDR := 40};
            });
            finish_item(seq_item);
            seq_item.prev_op = seq_item.din[9:8];
        end 
    endtask

    endclass

endpackage