//new
import alsu_pkg::*;

module question_3_tb;

  // DUT Signals
  logic clk, rst;
  logic signed [2:0] A, B;
  logic cin, serial_in;
  logic red_op_A, red_op_B;
  logic bypass_A, bypass_B, direction;
  opcode_e opcode;
  logic signed [5:0] result;
  logic [15:0] leds;

  // Transaction object
  alsu_txn t;

  // Instantiate DUT
  ALSU DUT (
    .clk(clk),
    .rst(rst),
    .A(A),
    .B(B),
    .cin(cin),
    .serial_in(serial_in),
    .red_op_A(red_op_A),
    .red_op_B(red_op_B),
    .bypass_A(bypass_A),
    .bypass_B(bypass_B),
    .direction(direction),
    .opcode(opcode),
    .out(result),
    .leds(leds)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Helper arrays
  logic signed [2:0] A_vals[3] = '{ -4, 0, 3 }; // {MAXNEG, ZERO, MAXPOS}
  logic signed [2:0] B_vals[3] = '{ -4, 0, 3 };

  logic direction_val[2] = '{0,1};
  logic serial_in_val[2] = '{0,1};

  // Covergroup sampling process
  initial begin
    forever begin
      @(posedge clk);
      if (!rst && !bypass_A && !bypass_B) begin
        t.cvr_gp.sample();
      end
    end
  end

  // ---------- Assertions ----------
  // Assert A walking-one
  assert property (@(posedge clk) disable iff (rst)
    (opcode inside {OR_OP, XOR_OP} && red_op_A && (B == 0)) |-> (A inside {3'b001, 3'b010, 3'b100}))
    else $error("A is not walking-one when red_op_A is active!");

  // Assert B walking-one
  assert property (@(posedge clk) disable iff (rst)
    (opcode inside {OR_OP, XOR_OP} && red_op_B && (A == 0)) |-> (B inside {3'b001, 3'b010, 3'b100}))
    else $error("B is not walking-one when red_op_B is active!");

  // Main test sequence
  initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;

    t = new();

    // Initialize defaults
    bypass_A = 0;
    bypass_B = 0;
    red_op_A = 0;
    red_op_B = 0;
    cin = 0;
    serial_in = 0;
    direction = 0;

    // -----------------------------------------
    // STAGE 1: DIRECTED TESTS
    // -----------------------------------------
    $display("Starting directed tests...");

    // 1) ADD & MUL with A,B permutations
    foreach (A_vals[i]) begin
      foreach (B_vals[j]) begin
        A = A_vals[i];
        B = B_vals[j];

        @(posedge clk);
        opcode = ADD_OP;
        cin = 0; @(posedge clk);
        cin = 1; @(posedge clk);

        opcode = MUL_OP;
        @(posedge clk);
      end
    end

    // 2) direction and serial_in tests
    foreach (direction_val[d]) begin
      direction = direction_val[d];

      opcode = SHIFT_OP;
      foreach (serial_in_val[s]) begin
        serial_in = serial_in_val[s];
        @(posedge clk);
      end

      opcode = ROT_OP;
      @(posedge clk);
    end

    // 3) Walking-One A patterns
    red_op_A = 1;
    B = 0;
    for (int k = 0; k < 3; k++) begin
      A = (3'b001 << k);
      opcode = OR_OP;  @(posedge clk);
      opcode = XOR_OP; @(posedge clk);
    end
    red_op_A = 0;

    // 4) Walking-One B patterns
    red_op_B = 1;
    A = 0;
    for (int k = 0; k < 3; k++) begin
      B = (3'b001 << k);
      opcode = OR_OP;  @(posedge clk);
      opcode = XOR_OP; @(posedge clk);
    end
    red_op_B = 0;

    // 5) Invalid Reduction cases
    red_op_A = 1;
    opcode = ADD_OP; @(posedge clk);
    opcode = MUL_OP; @(posedge clk);
    red_op_A = 0;

    red_op_B = 1;
    opcode = SHIFT_OP; @(posedge clk);
    opcode = ROT_OP;   @(posedge clk);
    red_op_B = 0;

    $display("Directed tests completed.");

    // -----------------------------------------
    // STAGE 2: RANDOMIZED TESTS
    // -----------------------------------------
    $display("Starting random tests...");

    t.en_c8 = 0;
    repeat (1000) begin
      if (!t.randomize()) begin
        $display("Randomization failed!");
        continue;
      end

      A = t.A;
      B = t.B;
      cin = t.cin;
      serial_in = t.serial_in;
      red_op_A = t.red_op_A;
      red_op_B = t.red_op_B;
      bypass_A = t.bypass_A;
      bypass_B = t.bypass_B;
      direction = t.direction;
      opcode = t.opcode;

      @(posedge clk);
    end

    // -----------------------------------------
    // STAGE 3: UNIQUE OPCODE SEQUENCE
    // -----------------------------------------
    $display("Starting unique opcode sequence loop...");
    
    t.en_c1 = 0;
    t.en_c2 = 0;
    t.en_c3 = 0;
    t.en_c8 = 1;

    if (!t.randomize()) begin
      $display("Randomization failed for opcode sequence!");
    end else begin
      foreach (t.opcode_seq[i]) begin
        opcode = t.opcode_seq[i];

        repeat (6) begin
          if (!t.randomize()) begin
            $display("Randomization failed inside unique opcode loop!");
            continue;
          end

          A = t.A;
          B = t.B;
          cin = t.cin;
          serial_in = t.serial_in;
          direction = t.direction;

          @(posedge clk);
        end
      end
    end

    $display("Simulation completed.");
    $display("Coverage: %.2f%%", t.cvr_gp.get_inst_coverage());
    $finish;
  end

  // Monitor to display transactions
  initial begin
    $monitor("Time: %0t | Opcode: %s | A: %0d | B: %0d | Result: %0d | LEDs: %h", 
             $time, opcode.name(), A, B, result, leds);
  end

endmodule


/*
//old
import alsu_pkg::*;

module question_3_tb;

  // DUT Signals
  logic clk, rst;
  logic signed [2:0] A, B;
  logic cin, serial_in;
  logic red_op_A, red_op_B;
  logic bypass_A, bypass_B, direction;
  opcode_e opcode;
  logic signed [5:0] result;

  // Transaction object
  alsu_txn t;

  // Instantiate DUT
  ALSU DUT (
    .clk(clk),
    .rst(rst),
    .A(A),
    .B(B),
    .cin(cin),
    .serial_in(serial_in),
    .red_op_A(red_op_A),
    .red_op_B(red_op_B),
    .bypass_A(bypass_A),
    .bypass_B(bypass_B),
    .direction(direction),
    .opcode(opcode),
    .out(result)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Helper arrays
  logic signed [2:0] A_vals[3] = '{ -4, 0, 3 }; // {MAXNEG, ZERO, MAXPOS}
  logic signed [2:0] B_vals[3] = '{ -4, 0, 3 };

  logic direction_val[2] = '{0,1};
  logic serial_in_val[2] = '{0,1};

  // ---------- Assertions ----------
  // Assert A walking-one
  assert property (@(posedge clk)
    (opcode inside {OR_OP, XOR_OP} && red_op_A && (B == 0)) |-> (A inside {3'b001, 3'b010, 3'b100}))
    else $error("A is not walking-one when red_op_A is active!");

  // Assert B walking-one
  assert property (@(posedge clk)
    (opcode inside {OR_OP, XOR_OP} && red_op_B && (A == 0)) |-> (B inside {3'b001, 3'b010, 3'b100}))
    else $error("B is not walking-one when red_op_B is active!");

  initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;

    t = new();

    // -----------------------------------------
    // STAGE 1: DIRECTED TESTS
    // -----------------------------------------
    $display("Starting directed tests...");

    bypass_A = 0;
    bypass_B = 0;
    red_op_A = 0;
    red_op_B = 0;
    cin = 0;
    serial_in = 0;
    direction = 0;

    // 1) ADD & MUL with A,B permutations
    foreach (A_vals[i]) begin
      foreach (B_vals[j]) begin
        A = A_vals[i];
        B = B_vals[j];

        opcode = ADD_OP;
        cin = 0; #10 if (!rst) t.cvr_gp.sample();
        cin = 1; #10 if (!rst) t.cvr_gp.sample();

        opcode = MUL_OP;
        #10 if (!rst) t.cvr_gp.sample();
      end
    end

    // 2) direction and serial_in tests
    foreach (direction_val[d]) begin
      direction = direction_val[d];

      opcode = SHIFT_OP;
      foreach (serial_in_val[s]) begin
        serial_in = serial_in_val[s];
        #10 if (!rst) t.cvr_gp.sample();
      end

      opcode = ROT_OP;
      #10 if (!rst) t.cvr_gp.sample();
    end

    // 3) Walking-One A patterns
    red_op_A = 1;
    B = 0;
    for (int k = 0; k < 3; k++) begin
      A = (3'b001 << k);
      opcode = OR_OP;  #10 if (!rst) t.cvr_gp.sample();
      opcode = XOR_OP; #10 if (!rst) t.cvr_gp.sample();
    end
    red_op_A = 0;

    // 4) Walking-One B patterns
    red_op_B = 1;
    A = 0;
    for (int k = 0; k < 3; k++) begin
      B = (3'b001 << k);
      opcode = OR_OP;  #10 if (!rst) t.cvr_gp.sample();
      opcode = XOR_OP; #10 if (!rst) t.cvr_gp.sample();
    end
    red_op_B = 0;

    // 5) Invalid Reduction cases
    red_op_A = 1;
    opcode = ADD_OP; #10 if (!rst) t.cvr_gp.sample();
    opcode = MUL_OP; #10 if (!rst) t.cvr_gp.sample();
    red_op_A = 0;

    red_op_B = 1;
    opcode = SHIFT_OP; #10 if (!rst) t.cvr_gp.sample();
    opcode = ROT_OP;   #10 if (!rst) t.cvr_gp.sample();
    red_op_B = 0;

    $display("Directed tests completed.");

    // -----------------------------------------
    // STAGE 2: RANDOMIZED TESTS
    // -----------------------------------------
    $display("Starting random tests...");

    t.en_c8 = 0;
    repeat (1000) begin
      if (!t.randomize()) $display("Randomization failed!");

      A = t.A;
      B = t.B;
      cin = t.cin;
      serial_in = t.serial_in;
      red_op_A = t.red_op_A;
      red_op_B = t.red_op_B;
      bypass_A = t.bypass_A;
      bypass_B = t.bypass_B;
      direction = t.direction;
      opcode = t.opcode;

      if (!rst && !bypass_A && !bypass_B)
        t.cvr_gp.sample();

      #10;
    end

    // -----------------------------------------
    // STAGE 3: UNIQUE OPCODE SEQUENCE
    // -----------------------------------------
    $display("Starting unique opcode sequence loop...");
    rst = 0;
    bypass_A = 0;
    bypass_B = 0;
    red_op_A = 0;
    red_op_B = 0;

    t.en_c1 = 0;
    t.en_c2 = 0;
    t.en_c3 = 0;
    t.en_c8 = 1;

    if (!t.randomize())
      $display("Randomization failed for opcode sequence!");

    foreach (t.opcode_seq[i]) begin
      opcode = t.opcode_seq[i];

      repeat (6) begin
        if (!t.randomize())
          $display("Randomization failed inside unique opcode loop!");

        A = t.A;
        B = t.B;
        cin = t.cin;
        serial_in = t.serial_in;
        direction = t.direction;

        if (!rst && !bypass_A && !bypass_B)
          t.cvr_gp.sample();

        #10;
      end
    end

    $display("Simulation completed.");
    $stop;
  end
endmodule
*/