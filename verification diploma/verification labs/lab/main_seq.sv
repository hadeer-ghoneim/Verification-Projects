package main_seq_pkg ;
    import shift_reg_seqitem_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class shift_reg_main_seq extends uvm_sequence#(shift_reg_seqitem);
        `uvm_object_utils(shift_reg_main_seq)
        shift_reg_seqitem item;

        function new (string name = "shift_reg_main_seq" );
            super.new(name);
        endfunction

        task body();
            item = shift_reg_seqitem::type_id::create("item") ;
            repeat(10000) begin
            start_item(item) ;
            assert(item.randomize()) ;
            finish_item(item);
            end
        endtask  
    endclass
    
endpackage