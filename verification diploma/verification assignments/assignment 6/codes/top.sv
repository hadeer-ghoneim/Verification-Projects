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
  ALSU DUT (
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

  // Bind assertions to DUT
  bind ALSU ALSU_assertions alsu_assertions_inst (
      .clk(clk),
      .rst(rst),
      .A(A),
      .B(B),
      .cin(cin),
      .serial_in(serial_in),
      .red_op_A(red_op_A),
      .red_op_B(red_op_B),
      .opcode(opcode),
      .bypass_A(bypass_A),
      .bypass_B(bypass_B),
      .direction(direction),
      .out(out),
      .leds(leds)
  );

  initial begin
    uvm_config_db#(virtual ALSU_if)::set(null, "uvm_test_top", "ALSU_if", ALSUif);
    run_test("ALSU_test");
  end

endmodule