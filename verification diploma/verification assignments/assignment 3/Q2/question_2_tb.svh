import question_2_pkg::*;   

module question_2_tb();
  parameter int WIDTH = question_2_pkg::WIDTH;

  // ============================
  // DUT signals
  // ============================
  logic clk;
  logic rst_n, load_n, up_down, ce;
  logic [WIDTH-1:0] data_load;
  logic [WIDTH-1:0] count_out;
  logic max_count, zero;

  // expected
  logic [WIDTH-1:0] count_out_expected;
  bit expected_max;
  bit expected_zero;

  // class object
  question_2_class question_2_object;

  // ============================
  // DUT instantiation
  // ============================
  counter #(.WIDTH(WIDTH)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .load_n(load_n),
    .up_down(up_down),
    .ce(ce),
    .data_load(data_load),
    .count_out(count_out),
    .max_count(max_count),
    .zero(zero)
  );

  // ============================
  // Clock generation
  // ============================
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period
  end

  // ============================
  // Tasks
  // ============================
  task assert_reset();
    begin
      rst_n = 0;
      @(posedge clk);
      rst_n = 1;
      @(posedge clk);
    end
  endtask

  task golden_model (
    input logic [WIDTH-1:0] prev_count,
    input bit load_n_in, ce_in, up_down_in,
    input logic [WIDTH-1:0] data_load_in,
    output logic [WIDTH-1:0] expected,
    output bit expected_max_o,
    output bit expected_zero_o
  );
    if (!load_n_in)
      expected = data_load_in;
    else if (ce_in)
      expected = up_down_in ? prev_count + 1 : prev_count - 1;
    else
      expected = prev_count;

    expected_max_o  = (expected == {WIDTH{1'b1}});
    expected_zero_o = (expected == 0);
  endtask

  task check_result(
    input logic [WIDTH-1:0] expected,
    input bit expected_max_i,
    input bit expected_zero_i
  );
    if (count_out !== expected)
      $display("ERROR @%0t: count_out mismatch. got=%0d expected=%0d",
               $time, count_out, expected);
    if (max_count !== expected_max_i)
      $display("ERROR @%0t: max_count mismatch. got=%b expected=%b",
               $time, max_count, expected_max_i);
    if (zero !== expected_zero_i)
      $display("ERROR @%0t: zero mismatch. got=%b expected=%b",
               $time, zero, expected_zero_i);
    if ((count_out === expected) &&
        (max_count === expected_max_i) &&
        (zero === expected_zero_i))
      $display("PASS @%0t: count_out=%0d, max=%b, zero=%b",
               $time, count_out, max_count, zero);
  endtask

  // ============================
  // Stimulus
  // ============================
  initial begin
    // init signals
    rst_n     = 1'b1;
    load_n    = 1'b1;
    ce        = 1'b0;
    up_down   = 1'b1;
    data_load = '0;

    count_out_expected = '0;
    expected_max  = 1'b0;
    expected_zero = 1'b1;

    // create class object
    question_2_object = new();

    // apply reset
    assert_reset();

    // run randomized tests
    repeat (40000) begin

      // save previous count before DUT update
      static logic [WIDTH-1:0] prev_count = count_out;

      // randomize fields in class
      assert(question_2_object.randomize())
        else $fatal("Randomization failed!");

      // drive DUT inputs
      load_n   = question_2_object.load_n_class;
      ce       = question_2_object.ce_class;
      up_down  = question_2_object.up_down_class;
      data_load = question_2_object.data_load_class;

      // wait for DUT update
      @(posedge clk);

      // compute expected output
      golden_model(prev_count, load_n, ce, up_down, data_load,
                   count_out_expected, expected_max, expected_zero);

      // sample coverage
      question_2_object.sampled_count = count_out;
      question_2_object.counter_cov.sample();

      // check result
      check_result(count_out_expected, expected_max, expected_zero);
    end

    $display("=== TEST COMPLETE ===");
    $finish;
  end

endmodule 

