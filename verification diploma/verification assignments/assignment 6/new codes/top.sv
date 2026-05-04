import ALSU_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top();

  bit clk;

  initial begin
    forever
      #1 clk = ~clk;
  end

  ALSU_if ALSUif (clk);
  
  ALSU #(
    .INPUT_PRIORITY("A"),
    .FULL_ADDER("ON")
  ) DUT (
    .A(ALSUif.A),
    .B(ALSUif.B), 
    .cin(ALSUif.cin),
    .serial_in(ALSUif.serial_in),
    .red_op_A(ALSUif.red_op_A),
    .red_op_B(ALSUif.red_op_B),
    .opcode(ALSUif.opcode),
    .bypass_A(ALSUif.bypass_A),
    .bypass_B(ALSUif.bypass_B),
    .clk(ALSUif.clk),
    .rst(ALSUif.rst),
    .direction(ALSUif.direction),
    .leds(ALSUif.leds),
    .out(ALSUif.out)
  );

  initial begin
    // Set virtual interfaces with proper modports
    uvm_config_db#(virtual ALSU_if.DRV)::set(null, "uvm_test_top.env.agt.drv", "ALSU_if", ALSUif);
    uvm_config_db#(virtual ALSU_if.MON)::set(null, "uvm_test_top.env.agt.mon", "ALSU_if", ALSUif);
    run_test("ALSU_test");
  end

  initial begin
    ALSUif.rst = 1;
    ALSUif.A = 0;
    ALSUif.B = 0;
    ALSUif.cin = 0;
    ALSUif.serial_in = 0;
    ALSUif.red_op_A = 0;
    ALSUif.red_op_B = 0;
    ALSUif.opcode = 0;
    ALSUif.bypass_A = 0;
    ALSUif.bypass_B = 0;
    ALSUif.direction = 0;
    #10 ALSUif.rst = 0;
  end

endmodule