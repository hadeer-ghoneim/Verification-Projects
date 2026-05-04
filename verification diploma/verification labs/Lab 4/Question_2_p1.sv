//===========================================
// Testbench Module
//===========================================
module tb;
  bit clk, rst_n, request, ack;

  receiver r1(clk, rst_n, request, ack);

  // Clock generation
  initial
    forever #1 clk = ~clk;

  // Test stimulus
  initial begin
    // Reset
    rst_n = 0;
    @(negedge clk);
    rst_n = 1;

    // Drive data
    request = 1;

    // Check if ack is received within maximum delay
    fork
      begin
        wait (ack == 1);
      end
      begin
        repeat (5) @(negedge clk);
        $display("Ack timed out");
        $stop;
      end
    join_any
    disable fork;
  end
endmodule

//===========================================
// Assertions and Coverage
//===========================================

// Assertion for property C
assert_C: assert property (@(posedge clk) disable iff (reset) C == $past(A) + $past(B));

// Coverage for property C
cover_C: cover property (@(posedge clk) disable iff (reset) C == $past(A) + $past(B));

// Check that C is zero when reset is active
always_comb begin
  if (reset)
    assert (C == 0);
end

// Final assertion
assert_final: assert final(C == 0);

//===========================================
// Sequence and Property Explanation
//===========================================
// Example sequence rules:
// 1. When signal A rises, then starting next cycle, signal B eventually shall fall
//    assert property (@(posedge signal_a) $fell(signal_b));

// 2. When valid signal is high, then after a cycle, ack should remain high until done is high
//    assert property (@(posedge clk) valid |-> (ack throughout (done[-1:1])));

// 3. When signal req rises, then after 1 clk cycle, ack is expected to be high,
//    and it's expected to get low the following clk cycle
//    assert property (@(posedge clk) $rose(req) |=> ack[*1] ##1 !ack[*1]);

//===========================================
// Vending Machine Interface
//===========================================
interface vending_machine_if (input clk);
  parameter WAIT = 2'b00;
  parameter Q_25 = 2'b01;
  parameter Q_50 = 2'b11;

  input clk;
  logic Q_in, D_in, rstn, dispense, change;

  // Modports
  modport DUT (
    input Q_in, D_in, rstn, clk,
    output dispense, change
  );

  modport TEST (
    output Q_in, D_in, rstn,
    input clk, dispense, change
  );

  modport MONITOR (
    input Q_in, D_in, rstn, clk, dispense, change
  );
endinterface
