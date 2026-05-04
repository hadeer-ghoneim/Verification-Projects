package reset_seq_pkg ;
    import shared_pkg::*;
    import shift_reg_seqitem_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class shift_reg_reset_seq extends uvm_sequence#(shift_reg_seqitem);
        `uvm_object_utils(shift_reg_reset_seq)
        shift_reg_seqitem item;

        function new (string name = "shift_reg_reset_seq" );
            super.new(name);
        endfunction

        task body();
            item = shift_reg_seqitem::type_id::create("item") ;
            start_item(item) ;
            item.reset = 1;
           item.mode =mode_e'(0)  ;
           item.direction = direction_e '(0) ;
           item.serial_in = 0 ;
           item.datain = 0 ;
            finish_item(item);
        endtask  
    endclass
    
endpackage