package shift_reg_main_sequence_pkg;

    import shift_reg_seq_item_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class shift_reg_main_sequence extends uvm_sequence #(shift_reg_seq_item);
        `uvm_object_utils(shift_reg_main_sequence)
        
        shift_reg_seq_item seq_item;

        int num_transactions = 10000;
        
        function new(string name = "shift_reg_main_sequence");
            super.new(name);
        endfunction

        task body();
            
            seq_item = shift_reg_seq_item::type_id::create("seq_item");

            repeat(num_transactions) begin
                start_item(seq_item);
                assert (seq_item.randomize());
                finish_item(seq_item);
            end

        endtask

    endclass

endpackage