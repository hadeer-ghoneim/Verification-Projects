package read_only_sequence_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import RAM_seq_item_pkg::*;

class RAM_read_only_sequence extends uvm_sequence #(RAM_seq_item);
    `uvm_object_utils(RAM_read_only_sequence)
    RAM_seq_item seq_item;

    bit [1:0] prev_op;

    function new(string name = "RAM_read_only_sequence");
        super.new(name);
        prev_op = 2'b10;
    endfunction

    task body;
        seq_item = RAM_seq_item::type_id::create("seq_item");
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

endpackage