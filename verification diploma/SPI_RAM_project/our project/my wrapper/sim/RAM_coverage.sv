package RAM_coverage_pkg;
import uvm_pkg::*;
import RAM_seq_item_pkg::*;
`include "uvm_macros.svh"

class RAM_coverage extends uvm_component;
    `uvm_component_utils(RAM_coverage)
    
    uvm_analysis_export #(RAM_seq_item) cov_export;
    uvm_tlm_analysis_fifo #(RAM_seq_item) cov_fifo;
    RAM_seq_item seq_item_cov;
    
    covergroup cvr_grp;
        // Operation coverage
        cp_op : coverpoint seq_item_cov.operation {
            bins set_addr  = {RAM_seq_item::SET_ADDR};
            bins write     = {RAM_seq_item::WRITE};
            bins read_addr = {RAM_seq_item::READ_ADDR};
            bins read_data = {RAM_seq_item::READ_DATA};
            
            // Transition bins for sequence coverage
            bins wr_addr_to_wr_data = (RAM_seq_item::SET_ADDR => RAM_seq_item::WRITE);
            bins rd_addr_to_rd_data = (RAM_seq_item::READ_ADDR => RAM_seq_item::READ_DATA);
            bins wr_sequence = (RAM_seq_item::SET_ADDR => RAM_seq_item::WRITE => RAM_seq_item::SET_ADDR);
            bins rd_sequence = (RAM_seq_item::READ_ADDR => RAM_seq_item::READ_DATA => RAM_seq_item::READ_ADDR);
        }

        // Address coverage
        cp_addr : coverpoint seq_item_cov.address {
            bins low_addr  = {[0:85]};
            bins mid_addr  = {[86:170]};
            bins high_addr = {[171:255]};
        }

        // Data coverage
        cp_data : coverpoint seq_item_cov.write_data {
            bins zero_data = {0};
            bins low_data  = {[1:127]};
            bins high_data = {[128:255]};
        }

        // Control signals coverage
        cp_rx : coverpoint seq_item_cov.rx_valid {
            bins r_valid_low  = {1'b0};
            bins r_valid_high = {1'b1};
        }

        cp_tx : coverpoint seq_item_cov.tx_valid {
            bins t_valid_low  = {1'b0};
            bins t_valid_high = {1'b1};
        }

        // Cross coverage: operation x rx_valid
        cross_op_rx : cross cp_op, cp_rx {
            bins valid_set_addr  = binsof(cp_op.set_addr) && binsof(cp_rx.r_valid_high);
            bins valid_write     = binsof(cp_op.write) && binsof(cp_rx.r_valid_high);
            bins valid_read_addr = binsof(cp_op.read_addr) && binsof(cp_rx.r_valid_high);
            bins valid_read_data = binsof(cp_op.read_data) && binsof(cp_rx.r_valid_high);
        }

        // Cross coverage: read operations x tx_valid
        cross_rd_tx : cross cp_op, cp_tx {
            bins rddata_txvalid = binsof(cp_op.read_data) && binsof(cp_tx.t_valid_high);
        }

        // Cross coverage: address x operation
        cross_addr_op : cross cp_addr, cp_op;

    endgroup

    function new(string name = "RAM_coverage", uvm_component parent = null);
        super.new(name, parent);
        cvr_grp = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cov_export = new("cov_export", this);
        cov_fifo = new("cov_fifo", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        cov_export.connect(cov_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            cov_fifo.get(seq_item_cov);
            cvr_grp.sample();
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("RAM_COVERAGE", $sformatf(
            "\n=== RAM COVERAGE SUMMARY ===\n" +
            "Total Coverage: %.2f%%\n" +
            "Operations: %.2f%%\n" +
            "Address: %.2f%%\n" +
            "Data: %.2f%%\n" +
            "Transitions: %.2f%%",
            cvr_grp.get_coverage(),
            cvr_grp.cp_op.get_coverage(),
            cvr_grp.cp_addr.get_coverage(),
            cvr_grp.cp_data.get_coverage(),
            cvr_grp.cp_op.get_inst_coverage()
        ), UVM_LOW)
    endfunction

endclass
endpackage