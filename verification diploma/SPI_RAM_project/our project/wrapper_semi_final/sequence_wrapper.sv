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
        
    // =============================================================
    // Write Only Sequence
    // =============================================================
    class write_only_sequence extends sequence_wrapper;
        `uvm_object_utils(write_only_sequence)

        function new(string name = "write_only_sequence");
            super.new(name);
        endfunction

        virtual task body();
            sequence_wrapper_item item;
            repeat (1000) begin
                item = sequence_wrapper_item::type_id::create("item");
                start_item(item);
                // Write means MOSI active and SS_n low (selecting slave)
                assert(item.randomize() with {
                    rst_n == 1;
                    MOSI dist {1 := 70, 0 := 30};
                    SS_n == 0;
                });
                finish_item(item);
            end
        endtask
    endclass


    // =============================================================
    // Read Only Sequence
    // =============================================================
    class read_only_sequence extends sequence_wrapper;
        `uvm_object_utils(read_only_sequence)

        function new(string name = "read_only_sequence");
            super.new(name);
        endfunction

        virtual task body();
            sequence_wrapper_item item;
            repeat (1000) begin
                item = sequence_wrapper_item::type_id::create("item");
                start_item(item);
                // Read means MOSI mostly idle (0), SS_n low (active)
                assert(item.randomize() with {
                    rst_n == 1;
                    MOSI dist {0 := 70, 1 := 30};
                    SS_n == 0;
                });
                finish_item(item);
            end
        endtask
    endclass



    // =============================================================
    // Write + Read (Mixed) Sequence
    // =============================================================
    class write_read_sequence extends sequence_wrapper;
        `uvm_object_utils(write_read_sequence)

        function new(string name = "write_read_sequence");
            super.new(name);
        endfunction

        virtual task body();
            sequence_wrapper_item item;
            bit is_write = 1;
            repeat (2000) begin
                item = sequence_wrapper_item::type_id::create("item");
                start_item(item);

                if (is_write)
                    assert(item.randomize() with {
                        rst_n == 1;
                        MOSI dist {1 := 70, 0 := 30};
                        SS_n == 0;
                    });
                else
                    assert(item.randomize() with {
                        rst_n == 1;
                        MOSI dist {0 := 70, 1 := 30};
                        SS_n == 0;
                    });

                finish_item(item);

                is_write = !is_write;
            end
        endtask
    endclass


endpackage