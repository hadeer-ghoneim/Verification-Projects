package shift_reg_seq_item_pkg;

    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class shift_reg_seq_item extends uvm_sequence_item;
        `uvm_object_utils(shift_reg_seq_item)

        rand mode_e mode;
        rand direction_e direction; 
        rand logic serial_in;
        rand logic [5:0] datain;
        rand logic reset;
        logic [5:0] dataout;

        function new(string name = "shift_reg_seq_item");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("%s mode_e=%s, direction_e=%s, serial_in=0x%0h, datain=0x%0h, reset=%0b, dataout=0x%0h", super.convert2string(),
                            mode.name(),direction.name(),serial_in, datain, reset, dataout);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("mode_e=%s, direction_e=%s, serial_in=0x%0h, datain=0x%0h, reset=%0b", 
                            mode.name(),direction.name(),serial_in, datain, reset);
        endfunction
        
        //constraint blocks
        constraint rst_con { reset dist {1:=2, 0:=98}; }

    endclass
    
endpackage