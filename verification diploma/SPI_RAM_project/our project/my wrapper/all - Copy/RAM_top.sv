import uvm_pkg::*;
import RAM_test_pkg::*;

`include "uvm_macros.svh"

module top();

    bit clk;
        
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Interface instantiation - match OLD top style
    RAM_vif r_if(clk);
    
    // DUT instantiation - match OLD top style (.r_if interface)
    RAM dut (.r_if(r_if));
    
    // Golden model instantiation - match OLD top style
    SinglePort_SRAM golden_model (
        .clk(clk),
        .rst_n(r_if.rst_n),
        .rx_valid(r_if.rx_valid),
        .din(r_if.din),         
        .dout(r_if.dout_ref),    
        .tx_valid(r_if.tx_valid_ref) 
    );
    
    // Bind assertions - match OLD top style
    bind RAM RAM_assertions RAM_assertions_inst (.r_if(r_if));

    initial begin
        // Set virtual interface in config DB - match OLD top style
        uvm_config_db#(virtual RAM_vif)::set(null, "uvm_test_top", "RAM_VIF", r_if);
        
        // Run test - match OLD top style
        run_test("RAM_test");
    end

    // Simulation timeout - NEW addition (keep this improvement)
    initial begin
        #1000000;
        $display("ERROR: Simulation timeout!");
        $finish;
    end

endmodule