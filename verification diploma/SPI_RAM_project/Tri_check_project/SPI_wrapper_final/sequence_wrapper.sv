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
        
    // =============================================================
    // Write Only Sequence
    // =============================================================
    class write_only_sequence extends uvm_sequence #(sequnce_ram_item);
        `uvm_object_utils(write_only_sequence)
        sequnce_ram_item seq_item;

        bit [1:0] prev_op;

        function new(string name = "write_only_sequence");
            super.new(name);
            prev_op = 2'b10;
        endfunction

        task body();
            seq_item = sequnce_ram_item::type_id::create("seq_item");
            repeat(100) begin
                start_item(seq_item);
                assert(seq_item.randomize() with {
                    din[9:8] inside {2'b00, 2'b01};
                    if (prev_op == 2'b00)      
                        din[9:8] inside {2'b01, 2'b00};  
                    else if (prev_op == 2'b01) 
                        din[9:8] inside {2'b01, 2'b00};  
                    }
                );
                finish_item(seq_item);
                prev_op = seq_item.din[9:8];
            end 
        endtask

    endclass



    // =============================================================
    // Read Only Sequence
    // =============================================================
    class read_only_sequence extends uvm_sequence #(sequnce_ram_item);
        `uvm_object_utils(read_only_sequence)
        sequnce_ram_item seq_item;

        bit [1:0] prev_op;

        function new(string name = "read_only_sequence");
            super.new(name);
            prev_op = 2'b10;
        endfunction

        task body();
            seq_item = sequnce_ram_item::type_id::create("seq_item");
            repeat(100) begin
                start_item(seq_item);
                assert(seq_item.randomize() with {
                    din[9:8] inside {2'b10, 2'b11};
                    if (prev_op == 2'b10)      
                        din[9:8] inside {2'b10, 2'b11};  
                    else if (prev_op == 2'b11) 
                        din[9:8] inside {2'b10, 2'b11};  
                    }
                );
                finish_item(seq_item);
                prev_op = seq_item.din[9:8];
            end 
        endtask

    endclass



    // =============================================================
    // Write + Read (Mixed) Sequence
    // =============================================================
    class write_read_sequence extends uvm_sequence #(sequnce_ram_item);
    `uvm_object_utils(write_read_sequence)
    sequnce_ram_item seq_item;

    bit [1:0] prev_op;
    localparam bit [1:0] WRITE_ADDR = 2'b00;
    localparam bit [1:0] WRITE_DATA = 2'b01;
    localparam bit [1:0] READ_ADDR  = 2'b10;
    localparam bit [1:0] READ_DATA  = 2'b11;

    function new(string name = "write_read_sequence");
        super.new(name);
        prev_op = WRITE_ADDR;
    endfunction

    task body;
        seq_item = sequnce_ram_item::type_id::create("seq_item");
        repeat(10000) begin
            start_item(seq_item);
            assert(seq_item.randomize() with {
                (prev_op == WRITE_ADDR) -> (din[9:8] inside {WRITE_ADDR, WRITE_DATA});
                (prev_op == WRITE_DATA) -> din[9:8] dist {READ_ADDR := 60, WRITE_ADDR := 40};
                (prev_op == READ_ADDR)  -> (din[9:8] inside {READ_ADDR, READ_DATA});
                (prev_op == READ_DATA)  -> din[9:8] dist {WRITE_ADDR := 60, READ_ADDR := 40};
            });
            finish_item(seq_item);
            prev_op = seq_item.din[9:8];
        end 
    endtask

    endclass

endpackage