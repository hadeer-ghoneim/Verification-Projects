`timescale 1ps/1ps
package driver_pkg;
import shared_pkg::*;
import sequenceItem_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name);

// driver class
class ALSU_driver extends uvm_driver #(ALSU_sequenceItem);
    `uvm_component_utils(ALSU_driver)
    virtual ALSU_interface v_if;
    ALSU_sequenceItem stim_seq_item;

    function new(string name = "ALSU_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction //new()

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            //v_if.inputs_are_driven = 0;
            stim_seq_item = `create_obj(ALSU_sequenceItem, "stim_seq_item")
            seq_item_port.get_next_item(stim_seq_item);
        // assigned inputs to interface
            v_if.A = stim_seq_item.A;
            v_if.B = stim_seq_item.B;
            v_if.cin = stim_seq_item.cin;
            v_if.serial_in = stim_seq_item.serial_in;
            v_if.red_op_A = stim_seq_item.red_op_A;
            v_if.red_op_B = stim_seq_item.red_op_B;
            v_if.bypass_A = stim_seq_item.bypass_A;
            v_if.bypass_B = stim_seq_item.bypass_B;
            v_if.clk = stim_seq_item.clk;
            v_if.rst = stim_seq_item.rst;
            v_if.direction = stim_seq_item.direction;
        // assigned opcode tp interface
            v_if.opcode = stim_seq_item.opcode;
            @(negedge v_if.clk);
        // assigned outputs to driver
            stim_seq_item.leds = v_if.leds;
            stim_seq_item.out = v_if.out;
        // assigned refrence to driver
            stim_seq_item.leds_ref = v_if.leds_ref;
            stim_seq_item.out_ref = v_if.out_ref;
            seq_item_port.item_done();
            `uvm_info("run_phase_driver", stim_seq_item.convert2string_stim(), UVM_HIGH)
        end
    endtask //run_phase
endclass //ALSU_driver extends uvm_driver
    
endpackage