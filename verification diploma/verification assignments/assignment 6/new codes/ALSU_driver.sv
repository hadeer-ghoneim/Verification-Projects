package ALSU_driver_pkg;

  import ALSU_config_pkg::*;
  import ALSU_seq_item_pkg::*;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class ALSU_driver extends uvm_driver #(ALSU_seq_item);
    `uvm_component_utils(ALSU_driver)  
    
    virtual ALSU_if.DRV ALSU_vif;
    ALSU_seq_item stim_seq_item;

    function new(string name = "ALSU_driver", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual ALSU_if.DRV)::get(this, "", "ALSU_if", ALSU_vif)) begin
        `uvm_fatal("DRIVER", "Virtual interface not found!")
      end
    endfunction

    task run_phase(uvm_phase phase);
      super.run_phase(phase);

      forever begin
        seq_item_port.get_next_item(stim_seq_item);
        
        // Drive signals using clocking block
        @(ALSU_vif.drv_cb);
        ALSU_vif.drv_cb.A <= stim_seq_item.A;
        ALSU_vif.drv_cb.B <= stim_seq_item.B;
        ALSU_vif.drv_cb.cin <= stim_seq_item.cin;
        ALSU_vif.drv_cb.serial_in <= stim_seq_item.serial_in;
        ALSU_vif.drv_cb.red_op_A <= stim_seq_item.red_op_A;
        ALSU_vif.drv_cb.red_op_B <= stim_seq_item.red_op_B;
        ALSU_vif.drv_cb.opcode <= stim_seq_item.opcode;
        ALSU_vif.drv_cb.bypass_A <= stim_seq_item.bypass_A;
        ALSU_vif.drv_cb.bypass_B <= stim_seq_item.bypass_B;
        ALSU_vif.drv_cb.direction <= stim_seq_item.direction;
        ALSU_vif.drv_cb.rst <= stim_seq_item.rst;

        seq_item_port.item_done();
        `uvm_info("DRIVER", $sformatf("Driven: %s", stim_seq_item.convert2string_stimulus()), UVM_HIGH)
      end
    endtask

  endpackage
  


