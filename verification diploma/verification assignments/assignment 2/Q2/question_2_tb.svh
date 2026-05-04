module question_2_tb;

  import question_2_pkg::*;   // Import package

  // DUT signals
  logic clk, rst_n, load_n, up_down, ce;
  logic [WIDTH-1:0] data_load, count_out;
  logic max_count, zero;

  // Expected outputs
  logic [WIDTH-1:0] count_out_expected;
  bit expected_zero;
  bit expected_max;

  // Create object from class
  question_2_class question_2_object;

  // DUT instantiation (WIDTH overridden by package)
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

  // Clock
  always begin
      #5 clk = ~clk; 
  end

  // ============================
  // Tasks
  // ============================

  task assert_reset();
    rst_n = 0;
    @(negedge clk);
    rst_n = 1;
  endtask


  task golden_model (
      input  logic [WIDTH-1:0] prev_count,
      input  bit load_n, ce, up_down,
      input  logic [WIDTH-1:0] data_load,
      output logic [WIDTH-1:0] expected,
      output bit expected_max,
      output bit expected_zero
  );
    if (!load_n)
      expected = data_load;
    else if (ce)
      expected = up_down ? prev_count + 1 : prev_count - 1;
    else
      expected = prev_count;

    expected_max  = (expected == {WIDTH{1'b1}});
    expected_zero = (expected == 0);
  endtask


  task check_result(
      input logic [WIDTH-1:0] expected,
      input bit expected_max,
      input bit expected_zero
  );
    @(negedge clk);
    if (count_out != expected)
      $display("count_out mismatch: got %0d, expected %0d", count_out, expected);
    if (max_count != expected_max)
      $display("max_count mismatch: got %b, expected %b", max_count, expected_max);
    if (zero != expected_zero)
      $display("zero mismatch: got %b, expected %b", zero, expected_zero);
    else
      $display("test passed: count_out=%0d, max_count=%b, zero=%b", count_out, max_count, zero);
  endtask


  // ============================
  // Stimulus
  // ============================

  initial begin
    clk = 0;
    rst_n     = 1'b1;  
    load_n    = 1'b1;   
    ce        = 1'b0;   
    up_down   = 1'b1;   
    data_load = '0;
  
    count_out_expected = '0;
    expected_max       = 1'b0;
    expected_zero      = 1'b1; 

    question_2_object = new();

    // 1. Apply reset
    assert_reset();
    
    // 2. Run random tests
    repeat (20) begin
      assert(question_2_object.randomize());

      load_n    = question_2_object.load_n_class;
      ce        = question_2_object.ce_class;
      assert_reset();
      up_down   = question_2_object.up_down_class;
      data_load = question_2_object.data_load_class;

      golden_model(count_out, load_n, ce, up_down, data_load,
                   count_out_expected, expected_max, expected_zero);

      check_result(count_out_expected, expected_max, expected_zero);
    end
    $finish;
  end
endmodule
