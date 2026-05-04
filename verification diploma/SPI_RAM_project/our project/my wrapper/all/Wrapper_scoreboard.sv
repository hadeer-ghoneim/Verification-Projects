package scoreboard_wrapper;
`include "uvm_macros.svh"
import uvm_pkg::*;
import sequence_wrapper_item::*;

class SPI_Wrapper_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(SPI_Wrapper_scoreboard)
    
    uvm_analysis_imp #(SPI_Wrapper_seq_item, SPI_Wrapper_scoreboard) sb_imp;
    
    // Memory model for reference
    bit [7:0] memory [256];
    bit [7:0] current_address;
    
    int pass_count, fail_count;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        sb_imp = new("sb_imp", this);
        // Initialize memory
        foreach(memory[i]) memory[i] = 8'h00;
        current_address = 8'h00;
    endfunction
    
    function void write(SPI_Wrapper_seq_item item);
        // Update reference model based on operation
        case(item.operation)
            SPI_Wrapper_seq_item::SET_ADDR: begin
                current_address = item.address;
                `uvm_info("SCOREBOARD", $sformatf("Address set to 0x%02h", current_address), UVM_MEDIUM)
            end
            
            SPI_Wrapper_seq_item::WRITE: begin
                memory[current_address] = item.data;
                `uvm_info("SCOREBOARD", $sformatf("Write: mem[0x%02h] = 0x%02h", 
                          current_address, item.data), UVM_MEDIUM)
            end
            
            SPI_Wrapper_seq_item::READ_DATA: begin
                bit [7:0] expected_data = memory[current_address];
                if (item.read_data === expected_data) begin
                    `uvm_info("SCOREBOARD", $sformatf("PASS: Read mem[0x%02h] = 0x%02h (Expected: 0x%02h)", 
                              current_address, item.read_data, expected_data), UVM_MEDIUM)
                    pass_count++;
                end else begin
                    `uvm_error("SCOREBOARD", $sformatf("FAIL: Read mem[0x%02h] = 0x%02h (Expected: 0x%02h)", 
                              current_address, item.read_data, expected_data))
                    fail_count++;
                end
            end
            
            // Handle READ_ADDR if needed
            SPI_Wrapper_seq_item::READ_ADDR: begin
                current_address = item.address;
                `uvm_info("SCOREBOARD", $sformatf("Read address set to 0x%02h", current_address), UVM_MEDIUM)
            end
            
            default: begin
                `uvm_info("SCOREBOARD", $sformatf("Operation %s not handled in scoreboard", 
                          item.operation.name()), UVM_HIGH)
            end
        endcase
        
        // Check reset behavior
        if (!item.rst_n) begin
            // Reset should clear internal state
            current_address = 8'h00;
            `uvm_info("SCOREBOARD", "Reset detected - internal state cleared", UVM_MEDIUM)
        end
    endfunction
    
    function void report_phase(uvm_phase phase);
        real coverage = (pass_count + fail_count > 0) ? (pass_count * 100.0) / (pass_count + fail_count) : 0;
        `uvm_info("SCOREBOARD", $sformatf("\n=== FINAL SCOREBOARD RESULTS ===\nPass: %0d\nFail: %0d\nCoverage: %.2f%%", 
                  pass_count, fail_count, coverage), UVM_LOW)
    endfunction
endclass

endpackage