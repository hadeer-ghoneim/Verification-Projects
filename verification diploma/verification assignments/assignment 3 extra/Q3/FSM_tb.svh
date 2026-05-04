module FSM_tb;

  import fsm_pkg::*;

  // DUT signals
  logic clk, rst, x, y;
  logic [9:0] users_count;

  // Instantiate DUT
  FSM_010 dut (.clk(clk), .rst(rst), .x(x), .y(y), .users_count(users_count));

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Transaction object
  fsm_transaction tr;

  // Golden model states
  state_e cs, ns;

  // Stimulus and checking
  initial begin
    tr = new();

    // Reset sequence
    rst = 1;
    #15 rst = 0;

    repeat (20000) begin
      assert(tr.randomize()); // generate random input
      x = tr.x;
      rst = tr.rst;

      @(posedge clk);

      // Sample functional coverage
      tr.cg_x.sample();

      // Compare DUT with expected
      check_result(tr);
    end

    $display("TEST COMPLETED");

    $stop;
  end

  // Check task
  task check_result(fsm_transaction tr);
    golden_model(tr);

    // Compare expected vs DUT
    if (tr.y_exp !== y || tr.user_count_exp !== users_count) begin
      $error("Mismatch! Expected y=%0d, count=%0d | Got y=%0d, count=%0d",
              tr.y_exp, tr.user_count_exp, y, users_count);
    end
  endtask

  // Golden model task
  task golden_model(fsm_transaction tr);
    static bit [9:0] exp_count = 0;

    if (tr.rst) begin
      cs = IDLE;
      exp_count = 0;
      tr.y_exp = 0;
      tr.user_count_exp = 0;
    end else begin
      // next state logic
      case (cs)
        IDLE:  ns = (tr.x==0) ? ZERO : IDLE;
        ZERO:  ns = (tr.x==1) ? ONE  : ZERO;
        ONE:   ns = (tr.x==0) ? STORE: IDLE;
        STORE: ns = (tr.x==0) ? ZERO : IDLE;
      endcase

      // Output and count update
      if (ns == STORE) begin
        exp_count++;
        tr.y_exp = 1;
      end else begin
        tr.y_exp = 0;
      end

      tr.user_count_exp = exp_count;
      cs = ns;
    end
  endtask

endmodule


/*
module FSM_tb;

  import fsm_pkg::*;

  // DUT signals
  logic clk, rst, x, y;
  logic [9:0] users_count;

  // Instantiate DUT
  FSM_010 dut (.clk(clk), .rst(rst), .x(x), .y(y), .users_count(users_count));

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Transaction object
  fsm_transaction tr;

  // Golden model states
  state_e cs, ns;

  // Stimulus and checking
  initial begin
    tr = new();

    // Reset sequence
    rst = 1;
    #15 rst = 0;

    repeat (20000) begin
      assert(tr.randomize()); // generate random input
      x = tr.x;
      rst = tr.rst;

      @(posedge clk);

      check_result(tr);
    end

    $display("TEST COMPLETED");
    $stop;
  end

  // Check task
  task check_result(fsm_transaction tr);
    golden_model(tr);

    // Compare expected vs DUT
    if (tr.y_exp !== y || tr.user_count_exp !== users_count) begin
      $error("Mismatch! Expected y=%0d, count=%0d | Got y=%0d, count=%0d",
              tr.y_exp, tr.user_count_exp, y, users_count);
    end
  endtask

  // Golden model task

  task golden_model(fsm_transaction tr);
  static bit [9:0] exp_count = 0;

  if (tr.rst) begin
    cs = IDLE;
    exp_count = 0;
    tr.y_exp = 0;
    tr.user_count_exp = 0;
  end else begin
    // next state
    case (cs)
      IDLE:  ns = (tr.x==0) ? ZERO : IDLE;
      ZERO:  ns = (tr.x==1) ? ONE  : ZERO;
      ONE:   ns = (tr.x==0) ? STORE: IDLE;
      STORE: ns = (tr.x==0) ? ZERO : IDLE;
    endcase

   
    if (ns == STORE) begin
      exp_count++;
      tr.y_exp = 1;
    end else begin
      tr.y_exp = 0;
    end
    tr.user_count_exp = exp_count;
    cs = ns;
  end
endtask
endmodule
*/