package shift_reg_cvr_pkg ;
    import shift_reg_seqitem_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class shift_reg_cvr extends uvm_component;
        `uvm_component_utils(shift_reg_cvr)
         uvm_analysis_export #(shift_reg_seqitem) cvr_export ;
        uvm_tlm_analysis_fifo #(shift_reg_seqitem) cvr_fifo ;
        shift_reg_seqitem seq_item_cvr ;

        covergroup cvr_grp;
            datain_cvp : coverpoint  seq_item_cvr.datain;
            serialin_cvp : coverpoint seq_item_cvr.serial_in;
            direction_cvp : coverpoint seq_item_cvr.direction ;
            mode_cvp : coverpoint seq_item_cvr.mode ;
        endgroup

        function new (string name = "shift_reg_cvr" , uvm_component parent = null);
            super.new(name , parent) ;
            cvr_grp = new () ;
        endfunction

         function void build_phase (uvm_phase phase);
            super.build_phase(phase) ;
            cvr_export = new("cvr_export",this) ;
            cvr_fifo = new("cvr_fifo",this) ; 
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase) ;
            cvr_export.connect(cvr_fifo.analysis_export) ;
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase) ;
            forever begin
                cvr_fifo.get(seq_item_cvr) ;
                cvr_grp.sample() ;
            end
        endtask
    endclass

endpackage