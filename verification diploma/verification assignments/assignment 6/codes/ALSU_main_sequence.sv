package ALSU_main_sequence_pkg;

    import ALSU_seq_item_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_main_sequence extends uvm_sequence #(ALSU_seq_item);
        `uvm_object_utils(ALSU_main_sequence)

        ALSU_seq_item seq_item;
        
        int num_transactions = 10000;
        
        function new(string name = "ALSU_main_sequence");
            super.new(name);
        endfunction

        task body();
           
        seq_item = ALSU_seq_item::type_id::create("seq_item");
        
            repeat(num_transactions) begin

                start_item(seq_item);
                assert (seq_item.randomize());
                finish_item(seq_item);
            end
        endtask

    endclass

endpackage