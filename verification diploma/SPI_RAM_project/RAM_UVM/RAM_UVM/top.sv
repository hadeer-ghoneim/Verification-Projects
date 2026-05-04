import uvm_pkg::*;
import RAM_test_pkg::*;

`include "uvm_macros.svh"

module top();

    bit clk;
        
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    RAM_if r_if(clk);
    RAM dut (.r_if(r_if));
    SinglePort_SRAM golden_model (
        .clk(clk),
        .rst_n(r_if.rst_n),
        .rx_valid(r_if.rx_valid),
        .din(r_if.din),         
        .dout(r_if.dout_ref),    
        .tx_valid(r_if.tx_valid_ref) 
    );
    bind RAM RAM_assertions RAM_assertions_inst (.r_if(r_if));

    initial begin
        uvm_config_db#(virtual RAM_if)::set(null, "uvm_test_top", "RAM_IF", r_if);
        run_test("RAM_test");
    end

endmodule