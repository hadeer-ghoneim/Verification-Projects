package monitor_pkg;
import shared_pkg::*;
import sequenceItem_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name);
// monitor
class ALSU_monitor extends uvm_monitor;
    `uvm_component_utils(ALSU_monitor)
    virtual ALSU_interface v_if;
    ALSU_sequenceItem mon_seq_item;
    uvm_analysis_port #(ALSU_sequenceItem) mon_port; // monitor is a port

    function new(string name = "ALSU_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_port = new("mon_port", this);
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      forever begin
        mon_seq_item = `create_obj(ALSU_sequenceItem, "mon_seq_item")
        //@(posedge v_if.clk);
        @(negedge v_if.clk);
        // assigned inputs to monitor
            mon_seq_item.A = v_if.A;
            mon_seq_item.B = v_if.B;
            mon_seq_item.cin = v_if.cin;
            mon_seq_item.serial_in = v_if.serial_in;
            mon_seq_item.red_op_A = v_if.red_op_A;
            mon_seq_item.red_op_B = v_if.red_op_B;
            mon_seq_item.bypass_A = v_if.bypass_A;
            mon_seq_item.bypass_B = v_if.bypass_B;
            mon_seq_item.clk = v_if.clk;
            mon_seq_item.rst = v_if.rst;
            mon_seq_item.direction = v_if.direction;
        // assigned outputs to monitor
            mon_seq_item.leds = v_if.leds;
            mon_seq_item.out = v_if.out;
        // assigned outputs to monitor
            mon_seq_item.leds_ref = v_if.leds_ref;
            mon_seq_item.out_ref = v_if.out_ref;
        // assigned opcode tp monitor
            mon_seq_item.opcode = opcode_e'(v_if.opcode);
    
        mon_port.write(mon_seq_item); // that's mean that monitor will send the data
        `uvm_info("run_phase_monitor", mon_seq_item.convert2string_stim(), UVM_FULL)
      end
    endtask //run_pha
endclass //ALSU_monitor extends uvm_monitor
endpackage