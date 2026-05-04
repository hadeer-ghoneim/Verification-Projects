`timescale 1ps/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
import test_pkg::*;
module top ();
    bit clk;

    initial begin
        forever #1 clk = ~clk;
    end

    ALSU_interface intf (clk);
    ALSU DUT (
        intf.A, intf.B, intf.cin, intf.serial_in, intf.red_op_A,
        intf.red_op_B, intf.opcode, intf.bypass_A, intf.bypass_B,
        intf.clk, intf.rst, intf.direction, intf.leds, intf.out
    );    

    ALSU_ref GLD (
        intf.A, intf.B, intf.cin, intf.serial_in, intf.red_op_A,
        intf.red_op_B, intf.opcode, intf.bypass_A, intf.bypass_B,
        intf.clk, intf.rst, intf.direction, intf.leds_ref, intf.out_ref
    );

    bind ALSU ALSU_sva ALSU_sva_inst(
        A, B, cin, serial_in, red_op_A, red_op_B,
        opcode, bypass_A, bypass_B, clk, rst, direction, leds, out
    );

    initial begin
        uvm_config_db#(virtual ALSU_interface)::set(null, "uvm_test_top", "INTERFACE", intf);
        run_test("ALSU_test");
    end
endmodule