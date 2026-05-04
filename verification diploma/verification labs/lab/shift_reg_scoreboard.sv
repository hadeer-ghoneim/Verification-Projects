package shift_reg_scoreboard_pkg ;
    import shared_pkg::*;
    import shift_reg_seqitem_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class shift_reg_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(shift_reg_scoreboard)
        uvm_analysis_export #(shift_reg_seqitem) sb_export ;
        uvm_tlm_analysis_fifo #(shift_reg_seqitem) sb_fifo ;
        shift_reg_seqitem seq_item_sb ;
        logic [5:0] dataout_ref ;

        int error_counter = 0 ;
        int correct_counter = 0 ;

        function new (string name = "shift_reg_scoreboard" , uvm_component parent = null);
            super.new(name , parent) ;
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase) ;
            sb_export = new("sb_export",this) ;
            sb_fifo = new("sb_fifo",this) ; 
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase) ;
            sb_export.connect(sb_fifo.analysis_export) ;
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase) ;
            forever begin
                sb_fifo.get(seq_item_sb);
                ref_model(seq_item_sb) ;
                if(seq_item_sb.dataout != dataout_ref) begin
                    `uvm_error("run_phase" , $sformatf("comparison failed transaction recived by the DUT:=%s while the referance out :0b%0b" , 
                    seq_item_sb.convert2string(), dataout_ref))
                    error_counter++ ;
                end
                else begin
                    `uvm_info("run_phase",  $sformatf("correct dataout:%s", seq_item_sb.convert2string()) ,UVM_HIGH );
                    correct_counter++;
                end
            end
        endtask

        task ref_model(shift_reg_seqitem seq_item_chk);
            if (seq_item_chk.reset) begin
                dataout_ref = 0 ;
            end
            else begin

                 case (seq_item_chk.mode)   // rotate
                SHIFT:
                if (seq_item_chk.direction == LEFT)  // left
                    dataout_ref = {seq_item_chk.datain[4:0], seq_item_chk.serial_in};
                else 
                    dataout_ref = {seq_item_chk.serial_in, seq_item_chk.datain[5:1]};
                ROTATE:
                if (seq_item_chk.direction == LEFT)
                    dataout_ref = {seq_item_chk.datain[4:0], seq_item_chk.datain[5]};
                else
                    dataout_ref = {seq_item_chk.datain[0], seq_item_chk.datain[5:1]};
            endcase
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("run_phase",$sformatf("total successful transaction : %0d",correct_counter ), UVM_MEDIUM)
             `uvm_info("run_phase",$sformatf("total failed transaction : %0d",error_counter ), UVM_MEDIUM)
        endfunction
    endclass
endpackage