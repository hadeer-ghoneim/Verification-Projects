package shift_reg_seq_item_pkg;
    
import uvm_pkg::*;
`include "uvm_macros.svh"
import shared_pkg::*;

    class shift_reg_seq_item extends uvm_sequence_item;
        `uvm_object_utils(shift_reg_seq_item)

        rand logic reset;
        rand logic serial_in;
        rand logic [5:0] datain, dataout;
        rand mode_e mode;
        rand direction_e direction;
        
        function new(string name = "shift_reg_seq_item");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("reset = %b, serial_in = %b, data_in = %b, mode =%b, direction = %b, data_out = %b", 
            super.convert2string(),reset, serial_in, datain, mode, direction, dataout);
        endfunction

        function string convert2string_stimulus();
            return $sformatf("reset = %b, serial_in = %b, data_in = %b, mode =%b, direction = %b", 
            reset, serial_in, datain, mode, direction);
        endfunction

        constraint rst_c{
            reset dist{0 := 90, 1:= 1};
        }

    endclass

endpackage