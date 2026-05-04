package RAM_scoreboard_pkg;
import uvm_pkg::*;
import RAM_seq_item_pkg::*;
`include "uvm_macros.svh"

class RAM_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(RAM_scoreboard)

    uvm_analysis_imp #(RAM_seq_item, RAM_scoreboard) sb_export;
    
    // Reference memory model
    bit [7:0] ref_memory [256];
    bit [7:0] current_addr;
    
    int pass_count, fail_count;

    function new(string name = "RAM_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        sb_export = new("sb_export", this);
        // Initialize reference memory
        foreach(ref_memory[i]) ref_memory[i] = 8'h00;
        current_addr = 8'h00;
    endfunction

    function void write(RAM_seq_item item);
        // Update reference model based on operation when rx_valid is high
        if (item.rx_valid && item.rst_n) begin
            case(item.operation)
                RAM_seq_item::SET_ADDR: begin
                    current_addr = item.address;
                    `uvm_info("RAM_SB", $sformatf("Ref: Address set to 0x%02h", current_addr), UVM_HIGH)
                    pass_count++;
                end
                
                RAM_seq_item::WRITE: begin
                    ref_memory[current_addr] = item.write_data;
                    `uvm_info("RAM_SB", $sformatf("Ref: Write mem[0x%02h] = 0x%02h", 
                              current_addr, item.write_data), UVM_HIGH)
                    pass_count++;
                end
                
                RAM_seq_item::READ_ADDR: begin
                    current_addr = item.address;
                    `uvm_info("RAM_SB", $sformatf("Ref: Read address set to 0x%02h", current_addr), UVM_HIGH)
                    pass_count++;
                end
                
                RAM_seq_item::READ_DATA: begin
                    // Read operation - data will come later with tx_valid
                    `uvm_info("RAM_SB", $sformatf("Ref: Read command for address 0x%02h", current_addr), UVM_HIGH)
                    pass_count++;
                end
            endcase
        end
        
        // Check read data when tx_valid is high
        if (item.tx_valid && item.rst_n) begin
            bit [7:0] expected_data = ref_memory[current_addr];
            if (item.dout === expected_data) begin
                `uvm_info("RAM_SB", $sformatf("PASS: Read mem[0x%02h] = 0x%02h (Expected: 0x%02h)", 
                          current_addr, item.dout, expected_data), UVM_MEDIUM)
                pass_count++;
            end else begin
                `uvm_error("RAM_SB", $sformatf("FAIL: Read mem[0x%02h] = 0x%02h (Expected: 0x%02h)", 
                          current_addr, item.dout, expected_data))
                fail_count++;
            end
        end
        
        // Check against reference model outputs (optional - for direct comparison)
        if (item.rst_n && item.tx_valid) begin
            if (item.dout !== item.dout_ref) begin
                `uvm_warning("RAM_SB", $sformatf("DUT vs REF mismatch: DUT=0x%02h, REF=0x%02h",
                          item.dout, item.dout_ref))
            end
        end
        
        // Reset handling
        if (!item.rst_n) begin
            current_addr = 8'h00;
            `uvm_info("RAM_SB", "Reset detected - address reset to 0x00", UVM_MEDIUM)
        end
    endfunction

    function void report_phase(uvm_phase phase);
        real coverage = (pass_count + fail_count > 0) ? (pass_count * 100.0) / (pass_count + fail_count) : 0;
        `uvm_info("RAM_SCOREBOARD", $sformatf(
            "\n=== RAM SCOREBOARD RESULTS ===\n" +
            "Pass: %0d\n" +
            "Fail: %0d\n" + 
            "Total: %0d\n" +
            "Coverage: %.2f%%", 
            pass_count, fail_count, pass_count + fail_count, coverage), UVM_LOW)
    endfunction

endclass
endpackage