package coverage_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;


class SPI_Wrapper_coverage extends uvm_subscriber #(SPI_Wrapper_seq_item);
    `uvm_component_utils(SPI_Wrapper_coverage)
    
    SPI_Wrapper_seq_item cov_item;

    // Coverage export
    uvm_analysis_export#(SPI_Wrapper_seq_item) cov_export;
    uvm_tlm_analysis_fifo#(SPI_Wrapper_seq_item) cov_fifo;

    // functional coverage 
    
    covergroup spi_wrapper_cg;
        
        // Cover all operation types
        op_cp: coverpoint cov_item.operation {
            bins set_addr  = {SPI_Wrapper_seq_item::SET_ADDR};
            bins write     = {SPI_Wrapper_seq_item::WRITE};
            bins read_addr = {SPI_Wrapper_seq_item::READ_ADDR};
            bins read_data = {SPI_Wrapper_seq_item::READ_DATA};
        }
        
        // Cover address range
        addr_cp: coverpoint cov_item.address {
            bins low_addr    = {[0:63]};
            bins mid_addr    = {[64:191]};
            bins high_addr   = {[192:255]};
        }
        
        // Cover data values
        data_cp: coverpoint cov_item.data {
            bins zero      = {0};
            bins low       = {[1:85]};
            bins mid       = {[86:170]};
            bins high      = {[171:255]};
        }
        
        // Cover operation transitions (from constraints)
        op_trans_cp: coverpoint cov_item.operation {
            // Write sequence transitions (Constraint 4)
            bins set_to_write  = (SPI_Wrapper_seq_item::SET_ADDR => SPI_Wrapper_seq_item::WRITE);
            bins set_to_set    = (SPI_Wrapper_seq_item::SET_ADDR => SPI_Wrapper_seq_item::SET_ADDR);
            
            // Read sequence transitions (Constraint 5)  
            bins read_to_read  = (SPI_Wrapper_seq_item::READ_ADDR => SPI_Wrapper_seq_item::READ_ADDR);
            bins read_to_data  = (SPI_Wrapper_seq_item::READ_ADDR => SPI_Wrapper_seq_item::READ_DATA);
            
            // Write-read sequence transitions (Constraint 6)
            bins write_to_read = (SPI_Wrapper_seq_item::WRITE => SPI_Wrapper_seq_item::READ_ADDR);
            bins write_to_set  = (SPI_Wrapper_seq_item::WRITE => SPI_Wrapper_seq_item::SET_ADDR);
            bins data_to_write = (SPI_Wrapper_seq_item::READ_DATA => SPI_Wrapper_seq_item::SET_ADDR);
            bins data_to_read  = (SPI_Wrapper_seq_item::READ_DATA => SPI_Wrapper_seq_item::READ_ADDR);
        }
        
        // Cover SPI command bits (first 3 bits - Constraint 3)
        spi_cmd_cp: coverpoint cov_item.spi_frame[10:8] {
            bins write_addr_cmd = {3'b000};
            bins write_data_cmd = {3'b001};
            bins read_addr_cmd  = {3'b110};
            bins read_data_cmd  = {3'b111};
        }
        
        // Cover reset behavior (Constraint 1)
        reset_cp: coverpoint cov_item.rst_n {
            bins reset_active = {0};
            bins reset_inactive = {1};
        }
        
        // Cover SS_n timing patterns (Constraint 2)
        timing_cp: coverpoint cov_item.operation {
            bins normal_timing = {SPI_Wrapper_seq_item::SET_ADDR, SPI_Wrapper_seq_item::WRITE, SPI_Wrapper_seq_item::READ_ADDR};
            bins extended_timing = {SPI_Wrapper_seq_item::READ_DATA};
        }
        
        // Cross coverage
        op_addr_cross: cross op_cp, addr_cp;
        op_data_cross: cross op_cp, data_cp;
        cmd_op_cross: cross spi_cmd_cp, op_cp;
        reset_op_cross: cross reset_cp, op_cp;
        
    endgroup
    
    function new(string name = "SPI_Wrapper_coverage", uvm_component parent = null);
        super.new(name, parent);
        spi_wrapper_cg = new();
    endfunction
    
    function void write(SPI_Wrapper_seq_item t);
        cov_item = t;
        spi_wrapper_cg.sample();
    endfunction


   function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       cov_export = new("cov_export", this);
         cov_fifo = new("cov_fifo", this);

    endfunction
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect the export to the FIFO
        cov_export.connect(cov_fifo.analysis_export);
    endfunction    

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            // Wait for an cov_item to be written to the FIFO
        cov_fifo.get(cov_item);
        spi_wrapper_cg.sample();
           
            
        end
    endtask    

    
    function void report_phase(uvm_phase phase);
        real total_cov = spi_wrapper_cg.get_coverage();
        `uvm_info(get_type_name(), $sformatf(
            "\n=== SPI WRAPPER COVERAGE SUMMARY ===\n" +
            "Total Coverage: %.2f%%\n" +
            "Operations: %.2f%%\n" +
            "Address: %.2f%%\n" + 
            "Data: %.2f%%\n" +
            "Transitions: %.2f%%\n" +
            "SPI Commands: %.2f%%\n" +
            "Reset: %.2f%%\n" +
            "Timing: %.2f%%",
            total_cov,
            spi_wrapper_cg.op_cp.get_coverage(),
            spi_wrapper_cg.addr_cp.get_coverage(),
            spi_wrapper_cg.data_cp.get_coverage(),
            spi_wrapper_cg.op_trans_cp.get_coverage(),
            spi_wrapper_cg.spi_cmd_cp.get_coverage(),
            spi_wrapper_cg.reset_cp.get_coverage(),
            spi_wrapper_cg.timing_cp.get_coverage()
        ), UVM_LOW)
    endfunction
    
endclass

endpackage