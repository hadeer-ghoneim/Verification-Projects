module adder_tb;

  // Import the package
  import adder_pkg::*;

  // Clock and reset
  bit clk;
  bit reset;

  // DUT signals
  logic signed [3:0] A_tb, B_tb;
  logic signed [4:0] C_tb;

  // Counters
  int error_count;
  int correct_count;

  // DUT instantiation
  adder dut (
    .clk(clk),
    .reset(reset),
    .A(A_tb),
    .B(B_tb),
    .C(C_tb)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Create object from adder_transaction
  adder_transaction t;

  // Initial block
  initial begin
    error_count   = 0;
    correct_count = 0;

    // Initialize transaction object
    t = new();

    // Apply initial reset
    reset = 1;
    A_tb  = 0;
    B_tb  = 0;
    @(posedge clk);
    reset = 0;

    // Run random tests
    repeat (10000) begin
      // Randomize the transaction
      assert(t.randomize()) else $fatal("Randomization failed!");

      // Drive DUT inputs
      @(negedge clk);
      reset = t.reset;   // Random reset with low probability
      A_tb  = t.A;
      B_tb  = t.B;

      // Sample coverage only when reset is de-asserted
      @(posedge clk);
      t.sample();

      // Self-checking: verify the result
      if (!reset) begin
        if (C_tb !== (A_tb + B_tb)) begin
          $display("ERROR: A=%0d, B=%0d, Expected=%0d, Got=%0d", A_tb, B_tb, (A_tb+B_tb), C_tb);
          error_count++;
        end else begin
          correct_count++;
        end
      end
    end

    // Final report
    $display("=======================================");
    $display("Simulation Finished!");
    $display("Correct operations: %0d", correct_count);
    $display("Errors detected:   %0d", error_count);
    $display("=======================================");

    $stop;
  end

endmodule
