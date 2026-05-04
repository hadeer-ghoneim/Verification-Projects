// Stimulus Generation
initial begin
  fork
    clock_gen();
    monitor_DUT();
  join_none

  assert_reset;

  repeat(10000) begin
    assert(c_txn.randomize());
    fork
      drive_stimulus(c_txn);
      golden_model(c_txn);
      check_result(c_txn);
    join
  end

  $display("%t: At end of test execution", $time);
  $stop;
end

// Clock generation task
task clock_gen();
  forever #1 clk = ~clk;
endtask

// Monitor DUT task
task monitor_DUT();
  forever begin
    @(negedge clk);
    if (!rst_n || !load_n || ce)
      $display("time = %0t: rst_n = %b, load_n = %b, ce = %b", $time, rst_n, load_n, ce);
  end
endtask

// Drive stimulus task
task drive_stimulus(input counter_transaction c_txn_c);
  rst_n     = c_txn.rst_n;
  load_n    = c_txn.load_n;
  up_down   = c_txn.up_down;
  ce        = c_txn.ce;
  data_load = c_txn.data_load;
endtask
