package ALSU_monitor_pkg;

    import ALSU_seq_item_pkg::*;
    import shared_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ALSU_monitor extends uvm_monitor;
        `uvm_component_utils(ALSU_monitor)
        
        virtual ALSU_if.MON ALSU_vif;
        ALSU_seq_item rsp_seq_item;
        uvm_analysis_port #(ALSU_seq_item) mon_ap;

        function new(string name = "ALSU_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            mon_ap = new("mon_ap", this);
            if (!uvm_config_db#(virtual ALSU_if.MON)::get(this, "", "ALSU_if", ALSU_vif)) begin
                `uvm_fatal("MONITOR", "Virtual interface not found!")
            end
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            `uvm_info("MONITOR", "Monitor started", UVM_LOW)
            
            forever begin
                @(ALSU_vif.mon_cb);
                
                rsp_seq_item = ALSU_seq_item::type_id::create("rsp_seq_item");
                
                // Sample signals using clocking block
                rsp_seq_item.A = ALSU_vif.mon_cb.A;
                rsp_seq_item.B = ALSU_vif.mon_cb.B;
                rsp_seq_item.cin = ALSU_vif.mon_cb.cin;
                rsp_seq_item.serial_in = ALSU_vif.mon_cb.serial_in;
                rsp_seq_item.red_op_A = ALSU_vif.mon_cb.red_op_A;
                rsp_seq_item.red_op_B = ALSU_vif.mon_cb.red_op_B;
                rsp_seq_item.opcode = opcode_e'(ALSU_vif.mon_cb.opcode);
                rsp_seq_item.bypass_A = ALSU_vif.mon_cb.bypass_A;
                rsp_seq_item.bypass_B = ALSU_vif.mon_cb.bypass_B;
                rsp_seq_item.direction = direction_e'(ALSU_vif.mon_cb.direction);
                rsp_seq_item.rst = ALSU_vif.mon_cb.rst;
                rsp_seq_item.dataout = ALSU_vif.mon_cb.out;
                rsp_seq_item.leds = ALSU_vif.mon_cb.leds;
                
                mon_ap.write(rsp_seq_item);
                `uvm_info("MONITOR", $sformatf("Captured: %s", rsp_seq_item.convert2string()), UVM_HIGH)
            end
        endtask
    endclass

endpackage


