`timescale 1ps/1ps
package rst_sequence_pkg;
import shared_pkg::*;
import sequenceItem_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name);

class ALSU_reset_sequence extends uvm_sequence #(ALSU_sequenceItem);
    `uvm_object_utils(ALSU_reset_sequence) 
    function new(string name = "ALSU_reset_sequence");
        super.new(name);
    endfunction //new()


    ALSU_sequenceItem item;
    // Main task
    task body;
        // Creat seq_item
        item = `create_obj(ALSU_sequenceItem, "item")
        item.A = 0; item.B = 0; item.opcode = OR;
        item.cin = 0; item.serial_in = 0; item.direction = 0;
        item.bypass_A = 0; item.bypass_B = 0;
        item.red_op_A = 0; item.red_op_B = 0;
        start_item(item);
        item.rst = 1;
        finish_item(item);
    endtask
endclass //ALSU_reset_sequence extends uvm_sequence #(ALSU_sequenceItem)
endpackage