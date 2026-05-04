`timescale 1ps/1ps
package main_sequence_pkg;
import shared_pkg::*;
import uvm_pkg::*;
import sequenceItem_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name);

class ALSU_main_sequence extends uvm_sequence #(ALSU_sequenceItem);
    `uvm_object_utils(ALSU_main_sequence) 
    function new(string name = "ALSU_main_sequence");
        super.new(name);
    endfunction //new()

    ALSU_sequenceItem item;
    // Main task
    task body();
        repeat(GIANT_LOOP) begin
            item = `create_obj(ALSU_sequenceItem, "item")  // Creat seq_item
            // edit constraint mode
            item.constraint_mode(0);
            item.rules1_7.constraint_mode(1);

            start_item(item);
            assert (item.randomize());
            finish_item(item);
        end

        repeat(HOBBIT_LOOP) begin
            item = `create_obj(ALSU_sequenceItem, "item")  // Creat seq_item
            // edit constraint mode
            item.constraint_mode(0);
            item.INPUT_PRIORITY_CONS.constraint_mode(1);

            start_item(item);
            assert (item.randomize());
            finish_item(item);  
        end
        
        // make opcode onley valid
        alwaysValid = 1;
        repeat(DWARF_LOOP) begin
            item = `create_obj(ALSU_sequenceItem, "item")  // Creat seq_item
        // edit constraint mode
            item.constraint_mode(0);
            item.rules_8.constraint_mode(1);
            item.MAKE_bypass_red_rst_ZERO.constraint_mode(1); 
        // randomization
            assert (item.randomize());
        // loop for opcode
            foreach(item.arr[i]) begin
                start_item(item);
                item.opcode = item.arr[i];
                finish_item(item);
            end
        end
    endtask
endclass //ALSU_main_sequence extends uvm_sequence #(ALSU_sequenceItem)
endpackage