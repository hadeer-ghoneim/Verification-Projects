package shift_reg_mon_pkg ;
    import shared_pkg::*;
    import shift_reg_config_pkg::*;
    import shift_reg_seqitem_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class shift_reg_mon extends uvm_monitor;
        `uvm_component_utils(shift_reg_mon)
        virtual shift_reg_if shift_reg_vif ;
        shift_reg_seqitem rsp_seq_item ;
        uvm_analysis_port #(shift_reg_seqitem) mon_ap ;

         function new (string name = "shift_reg_mon", uvm_component parent = null);
             super.new(name , parent) ;
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase) ;
            mon_ap = new("mon_ap",this) ;
        endfunction

        task run_phase(uvm_phase phase);
        super.run_phase(phase) ;
        forever begin
            rsp_seq_item = shift_reg_seqitem::type_id::create("rsp_seq_item");
             @ (negedge shift_reg_vif.clk) ;
             rsp_seq_item.direction = direction_e'(shift_reg_vif.direction) ;
             rsp_seq_item.mode = mode_e'(shift_reg_vif.mode) ;
             rsp_seq_item.serial_in =  shift_reg_vif.serial_in ;
             rsp_seq_item.datain = shift_reg_vif.datain;
             rsp_seq_item.reset = shift_reg_vif.reset;
             rsp_seq_item.dataout = shift_reg_vif.datain;
             mon_ap.write(rsp_seq_item) ;
            `uvm_info("run_phase", rsp_seq_item.convert2string_stimuls() , UVM_HIGH) ;
            
        end
     endtask
    endclass
endpackage