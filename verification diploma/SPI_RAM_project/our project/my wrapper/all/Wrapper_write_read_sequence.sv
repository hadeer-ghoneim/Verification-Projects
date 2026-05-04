package write_read_sequence_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import RAM_seq_item_pkg::*;

class RAM_write_read_sequence extends uvm_sequence #(RAM_seq_item);
    `uvm_object_utils(RAM_write_read_sequence)
    RAM_seq_item seq_item;

    bit [1:0] prev_op;
    localparam bit [1:0] WRITE_ADDR = 2'b00;
    localparam bit [1:0] WRITE_DATA = 2'b01;
    localparam bit [1:0] READ_ADDR  = 2'b10;
    localparam bit [1:0] READ_DATA  = 2'b11;

    function new(string name = "RAM_write_read_sequence");
        super.new(name);
        prev_op = WRITE_ADDR;
    endfunction

    task body;
        seq_item = RAM_seq_item::type_id::create("seq_item");
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