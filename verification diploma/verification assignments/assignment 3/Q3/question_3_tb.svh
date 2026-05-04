
import alsu_pkg::*;

module question_3_tb;

  // DUT Signals
  logic clk, rst;
  logic signed [2:0] A, B;
  logic cin, serial_in;
  logic red_op_A, red_op_B;
  logic bypass_A, bypass_B;
  logic direction;
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

  initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;

    t = new();

    // ---------- First Loop ----------
    t.en_c8 = 0; // disable constraint #8
    repeat (1000) begin
      if (!t.randomize()) begin
        $display("Randomization failed in first loop!");
      end

      // Drive DUT inputs
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

      // Coverage sampling condition
      if (!rst && !bypass_A && !bypass_B) begin
        t.cvr_gp.sample();
      end

      #10;
    end

    // ---------- Second Loop ----------
    $display("Starting second loop for opcode sequence...");
    rst = 0;
    bypass_A = 0;
    bypass_B = 0;
    red_op_A = 0;
    red_op_B = 0;

    t.en_c1 = 0;
    t.en_c2 = 0;
    t.en_c3 = 0;
    t.en_c8 = 1; // enable constraint #8

    // Generate unique opcode sequence
    if (!t.randomize()) begin
      $display("Randomization failed for opcode sequence!");
    end

    // Iterate through the unique opcode sequence
    foreach (t.opcode_seq[i]) begin
      opcode = t.opcode_seq[i];

      repeat (6) begin
        if (!t.randomize()) begin
          $display("Randomization failed inside second loop!");
        end

        A = t.A;
        B = t.B;
        cin = t.cin;
        serial_in = t.serial_in;
        direction = t.direction;

        if (!rst && !bypass_A && !bypass_B) begin
          t.cvr_gp.sample();
        end

        #10;
      end
    end

    $display("Simulation completed.");
    $stop;
  end
endmodule




/* import alsu_pkg::*;

module ALSU_tb;

  // DUT signals
  logic clk, rst;
  logic signed [2:0] A, B;
  logic cin, serial_in;
  logic red_op_A, red_op_B;
  logic bypass_A, bypass_B;
  logic direction;
  opcode_e opcode;
  logic signed [5:0] result;

  // Transaction object
  ALSU_transaction t;

  // DUT instantiation
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
    .result(result)
  );

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;

    t = new();

    // ---------- First Loop ----------
    // Randomize with constraints 1-7, disable #8
    repeat (1000) begin
      if (!t.randomize() with { !unique_opcodes; }) begin
        $display("Randomization failed in first loop!");
      end

      // Drive inputs
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

      // Sampling condition
      if (!rst && !bypass_A && !bypass_B) begin
        t.cvr_gp.sample();
      end

      #10;
    end

    // ---------- Second Loop ----------
    // Disable constraints 1-7, enable constraint #8
    rst = 0;
    bypass_A = 0;
    bypass_B = 0;
    red_op_A = 0;
    red_op_B = 0;

    if (!t.randomize() with { unique_opcodes; }) begin
      $display("Randomization failed for opcode sequence!");
    end

    // Iterate through unique opcodes
    foreach (t.opcode_array[i]) begin
      opcode = t.opcode_array[i];

      // Keep other random inputs constant for these 6 iterations
      repeat (6) begin
        if (!t.randomize() with { !unique_opcodes; }) begin
          $display("Randomization failed inside second loop!");
        end

        A = t.A;
        B = t.B;
        cin = t.cin;
        serial_in = t.serial_in;
        direction = t.direction;

        if (!rst && !bypass_A && !bypass_B) begin
          t.cvr_gp.sample();
        end

        #10;
      end
    end

    $display("Simulation completed.");
    $stop;
  end
endmodule */



/* module question_3_tb();
  import alsu_pkg::*;

  // ===========================================
  // DUT signals
  // ===========================================
  logic clk, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, direction, rst;
  opcode_e opcode;
  logic signed [2:0] A, B;
  logic [15:0] leds;
  logic signed [5:0] out;

  // DUT internal nets to avoid multiple drivers
  logic signed [5:0] out_dut;
  logic [15:0] leds_dut;
  assign out  = out_dut;
  assign leds = leds_dut;

  // Instantiate DUT
  ALSU dut (
    .clk(clk), .cin(cin), .serial_in(serial_in),
    .red_op_A(red_op_A), .red_op_B(red_op_B),
    .bypass_A(bypass_A), .bypass_B(bypass_B),
    .direction(direction), .rst(rst),
    .opcode(opcode), .A(A), .B(B),
    .leds(leds_dut), .out(out_dut)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Registered versions of inputs (to match DUT registers)
  logic signed [2:0] A_reg, B_reg;
  opcode_e opcode_reg;
  logic red_op_A_reg, red_op_B_reg;
  logic bypass_A_reg, bypass_B_reg;
  logic direction_reg, serial_in_reg;
  logic cin_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      A_reg <= 0; B_reg <= 0;
      opcode_reg <= OR_OP;
      red_op_A_reg <= 0; red_op_B_reg <= 0;
      bypass_A_reg <= 0; bypass_B_reg <= 0;
      direction_reg <= 0; serial_in_reg <= 0;
      cin_reg <= 0;
    end else begin
      A_reg <= A; B_reg <= B;
      opcode_reg <= opcode;
      red_op_A_reg <= red_op_A; red_op_B_reg <= red_op_B;
      bypass_A_reg <= bypass_A; bypass_B_reg <= bypass_B;
      direction_reg <= direction; serial_in_reg <= serial_in;
      cin_reg <= cin;
    end
  end

  // Transaction object
  alsu_txn t;

  // Golden model task
  task automatic golden_model (
    input logic signed [2:0] A_i, B_i,
    input opcode_e opcode_i,
    input logic redA, redB,
    input logic bypassA, bypassB,
    input logic dir, sin,
    input logic cin_i,
    output logic signed [5:0] exp_out
  );
    localparam string INPUT_PRIORITY = "A";
    localparam string FULL_ADDER = "ON";
    begin
      exp_out = 0;
      if (bypassA && bypassB)
        exp_out = (INPUT_PRIORITY == "A") ? A_i : B_i;
      else if (bypassA)
        exp_out = A_i;
      else if (bypassB)
        exp_out = B_i;
      else begin
        case (opcode_i)
          OR_OP: begin
            if (redA && redB)
              exp_out = (INPUT_PRIORITY == "A") ? (|A_i) : (|B_i);
            else if (redA) exp_out = |A_i;
            else if (redB) exp_out = |B_i;
            else exp_out = A_i | B_i;
          end
          XOR_OP: begin
            if (redA && redB)
              exp_out = (INPUT_PRIORITY == "A") ? (^A_i) : (^B_i);
            else if (redA) exp_out = ^A_i;
            else if (redB) exp_out = ^B_i;
            else exp_out = A_i ^ B_i;
          end
          ADD_OP: begin
            if (FULL_ADDER == "ON")
              exp_out = A_i + B_i + cin_i;
            else
              exp_out = A_i + B_i;
          end
          MUL_OP: exp_out = A_i * B_i;
          SHIFT_OP, ROT_OP: exp_out = 0;
          default: exp_out = 0;
        endcase
      end
    end
  endtask

  // ---------------------------
  // Test procedure
  // ---------------------------
  initial begin
    // initialize signals
    clk = 0; cin = 0; serial_in = 0;
    red_op_A = 0; red_op_B = 0; bypass_A = 0; bypass_B = 0;
    direction = 0; opcode = ADD_OP; A = '0; B = '0; rst = 1;

    #12 rst = 0; // release reset

    // create transaction object
    t = new();

    // ----- FIRST LOOP: constraints 1..7 enabled, C8 disabled -----
    t.en_c1 = 1; t.en_c2 = 1; t.en_c3 = 1; t.en_c4 = 1;
    t.en_c5 = 1; t.en_c6 = 1; t.en_c7 = 1; t.en_c8 = 0;

    repeat (50000) begin

      // golden check
      logic signed [5:0] exp_out;

      if (!t.randomize()) $display("Randomize failed at time %0t", $time);

      // apply randomized inputs
      {cin, serial_in, red_op_A, red_op_B, rst, bypass_A, bypass_B, direction, opcode, A, B} =
      {t.cin, t.serial_in, t.red_op_A, t.red_op_B, t.rst,
       t.bypass_A, t.bypass_B, t.direction, t.opcode, t.A, t.B};

      @(posedge clk);
      t.sample();

      golden_model(A_reg, B_reg, opcode_reg, red_op_A_reg, red_op_B_reg,
                   bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg,
                   cin_reg, exp_out);

      if (out_dut !== exp_out)
        $display("Mismatch FIRST_LOOP time=%0t opcode=%0d A=%0d B=%0d cin=%0d dut=%0d exp=%0d",
                 $time, opcode_reg, A_reg, B_reg, cin_reg, out_dut, exp_out);
    end
    $stop;

    // ----- SECOND LOOP: constraint 8 (unique opcode sequence) enabled -----
    // Disable 1..7, enable 8
    t.en_c1 = 0; t.en_c2 = 0; t.en_c3 = 0; t.en_c4 = 0;
    t.en_c5 = 0; t.en_c6 = 0; t.en_c7 = 0; t.en_c8 = 1;

    if (!t.randomize())
      $display("Randomize failed when creating opcode sequence");


    // --- MOVE baseline declarations BEFORE any procedural statements that follow ---
    // (declarations must appear before statements in the initial block)
    logic baseline_cin = t.cin;
    logic baseline_serial_in = t.serial_in;
    logic baseline_redA = t.red_op_A;
    logic baseline_redB = t.red_op_B;
    logic baseline_bypassA = t.bypass_A;
    logic baseline_bypassB = t.bypass_B;
    logic baseline_dir = t.direction;
    logic signed [2:0] baseline_A = t.A;
    logic signed [2:0] baseline_B = t.B;
    

    // Now the repeat loop and procedural statements may follow safely
    repeat (40000) begin
      opcode_e i;
      foreach (t.opcode_seq[i]) begin
        // declare exp_out2 before using it (inside the foreach block is fine)
        logic signed [5:0] exp_out2;

        // apply baseline inputs and current opcode from the unique sequence
        {cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, direction, A, B} =
        {baseline_cin, baseline_serial_in, baseline_redA, baseline_redB,
         baseline_bypassA, baseline_bypassB, baseline_dir, baseline_A, baseline_B};

        opcode = t.opcode_seq[i];

        @(posedge clk);
        t.sample();

        golden_model(A_reg, B_reg, opcode_reg, red_op_A_reg, red_op_B_reg,
                     bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg,
                     cin_reg, exp_out2);

        if (out_dut !== exp_out2)
          $display("Mismatch SECOND_LOOP time=%0t opcode=%0d A=%0d B=%0d dut=%0d exp=%0d",
                   $time, opcode_reg, A_reg, B_reg, out_dut, exp_out2);
      end
    end
  end
  $stop;

endmodule */





/* module question_3_tb();
  import alsu_pkg::*;

  // ===========================================
  // DUT signals
  // ===========================================
  logic clk, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, direction, rst;
  opcode_e opcode;
  logic signed [2:0] A, B;
  logic [15:0] leds;
  logic signed [5:0] out;

  // DUT instance outputs (internal nets assigned to avoid multiple drivers)
  logic signed [5:0] out_dut;
  logic [15:0] leds_dut;
  assign out  = out_dut;
  assign leds = leds_dut;

  // Instantiate DUT
  ALSU dut (
    .clk(clk), .cin(cin), .serial_in(serial_in),
    .red_op_A(red_op_A), .red_op_B(red_op_B),
    .bypass_A(bypass_A), .bypass_B(bypass_B),
    .direction(direction), .rst(rst),
    .opcode(opcode), .A(A), .B(B),
    .leds(leds_dut), .out(out_dut)
  );

  // Clock
  initial clk = 0;
  always #5 clk = ~clk;

  // Input registers (to match DUT internal registering)
  logic signed [2:0] A_reg, B_reg;
  opcode_e opcode_reg;
  logic red_op_A_reg, red_op_B_reg;
  logic bypass_A_reg, bypass_B_reg;
  logic direction_reg, serial_in_reg;
  logic cin_reg;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      A_reg <= 0; B_reg <= 0;
      opcode_reg <= OR_OP;
      red_op_A_reg <= 0; red_op_B_reg <= 0;
      bypass_A_reg <= 0; bypass_B_reg <= 0;
      direction_reg <= 0; serial_in_reg <= 0;
      cin_reg <= 0;
    end else begin
      A_reg <= A; B_reg <= B;
      opcode_reg <= opcode;
      red_op_A_reg <= red_op_A; red_op_B_reg <= red_op_B;
      bypass_A_reg <= bypass_A; bypass_B_reg <= bypass_B;
      direction_reg <= direction; serial_in_reg <= serial_in;
      cin_reg <= cin;
    end
  end

  // Transaction object
  alsu_txn t;

  // Golden model task (identical logic to DUT)
  task automatic golden_model (
    input logic signed [2:0] A_i, B_i,
    input opcode_e opcode_i,
    input logic redA, redB,
    input logic bypassA, bypassB,
    input logic dir, sin,
    input logic cin_i,
    output logic signed [5:0] exp_out
  );
    localparam string INPUT_PRIORITY = "A";
    localparam string FULL_ADDER = "ON";
    begin
      exp_out = 0;
      if (bypassA && bypassB) begin
        exp_out = (INPUT_PRIORITY == "A") ? A_i : B_i;
      end else if (bypassA) begin
        exp_out = A_i;
      end else if (bypassB) begin
        exp_out = B_i;
      end else begin
        case (opcode_i)
          OR_OP: begin
            if (redA && redB)
              exp_out = (INPUT_PRIORITY == "A") ? (|A_i) : (|B_i);
            else if (redA) exp_out = |A_i;
            else if (redB) exp_out = |B_i;
            else exp_out = A_i | B_i;
          end
          XOR_OP: begin
            if (redA && redB)
              exp_out = (INPUT_PRIORITY == "A") ? (^A_i) : (^B_i);
            else if (redA) exp_out = ^A_i;
            else if (redB) exp_out = ^B_i;
            else exp_out = A_i ^ B_i;
          end
          ADD_OP: begin
            if (FULL_ADDER == "ON")
              exp_out = A_i + B_i + cin_i;
            else
              exp_out = A_i + B_i;
          end
          MUL_OP: exp_out = A_i * B_i;
          SHIFT_OP, ROT_OP: begin
            // Mirror DUT partial behavior: shift/rotate are serial/rotational on previous out
            // For golden model simplicity, emulate default behavior: 0 (or a simple shift)
            exp_out = 0;
          end
          default: exp_out = 0;
        endcase
      end
    end
  endtask

  // ---------------------------
  // Test procedure
  // ---------------------------
  initial begin
    // initialize signals
    clk = 0;
    cin = 0;
    serial_in = 0;
    red_op_A = 0;
    red_op_B = 0;
    bypass_A = 0;
    bypass_B = 0;
    direction = 0;
    opcode = ADD_OP;
    A = '0;
    B = '0;
    rst = 1;

    // hold reset a little
    #12 rst = 0;

    // create transaction object and ensure constraint config for loop1
    t = new();

    // -------------------
    // FIRST LOOP
    // -------------------
    // Enable constraints 1..7, disable constraint 8
    t.en_c1 = 1; t.en_c2 = 1; t.en_c3 = 1; t.en_c4 = 1;
    t.en_c5 = 1; t.en_c6 = 1; t.en_c7 = 1; t.en_c8 = 0;

    // Randomize many samples under constraints 1..7 (C8 disabled)
    repeat (50000) begin
      if (!t.randomize()) begin
        $display("Randomize failed in first loop at time %0t", $time);
      end

      // apply randomized inputs
      cin        = t.cin;
      serial_in  = t.serial_in;
      red_op_A   = t.red_op_A;
      red_op_B   = t.red_op_B;
      rst        = t.rst;
      bypass_A   = t.bypass_A;
      bypass_B   = t.bypass_B;
      direction  = t.direction;
      opcode     = t.opcode;
      A          = t.A;
      B          = t.B;

      // advance one clock to capture registers inside DUT
      @(posedge clk);

      // sample the covergroup using registered inputs (we sample using the transaction
      // object's sample method which samples the covergroup defined in the class)
      t.sample();

      // run golden model and check
      logic signed [5:0] exp_out;
      golden_model (A_reg, B_reg, opcode_reg, red_op_A_reg, red_op_B_reg,
                    bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg,
                    cin_reg, exp_out);

      if (out_dut !== exp_out) begin
        $display("Mismatch FIRST_LOOP time=%0t opcode=%0d A=%0d B=%0d cin=%0d dut=%0d exp=%0d",
                 $time, opcode_reg, A_reg, B_reg, cin_reg, out_dut, exp_out);
      end
    end

    // -------------------
    // PREPARE FOR SECOND LOOP
    // -------------------
    // Disable all constraints 1..7
    t.en_c1 = 0; t.en_c2 = 0; t.en_c3 = 0; t.en_c4 = 0;
    t.en_c5 = 0; t.en_c6 = 0; t.en_c7 = 0;
    // Force the following inputs to zero as required
    rst = 0;
    bypass_A = 0; bypass_B = 0;
    red_op_A = 0; red_op_B = 0;

    // Enable constraint 8 only
    t.en_c8 = 1;

    // Generate a unique sequence of 6 valid opcodes by randomizing the opcode_seq array
    if (!t.randomize()) begin
      // try randomize again if necessary
      $display("Randomize failed when creating opcode sequence, trying again");
    end

    t.en_c8 = 1; // keep C8 enabled so opcode_seq stays valid
    t.en_c1 = 0; t.en_c2 = 0; t.en_c3 = 0; t.en_c4 = 0; t.en_c5 = 0; t.en_c6 = 0; t.en_c7 = 0;

    // Keep constant baseline values for these fields across 6 iterations:
    logic baseline_cin = t.cin;
    logic baseline_serial_in = t.serial_in;
    logic baseline_redA = t.red_op_A;
    logic baseline_redB = t.red_op_B;
    logic baseline_bypassA = t.bypass_A;
    logic baseline_bypassB = t.bypass_B;
    logic baseline_dir = t.direction;
    logic signed [2:0] baseline_A = t.A;
    logic signed [2:0] baseline_B = t.B;

    // Now iterate over the opcode sequence with the other inputs constant across the 6 iterations.
    repeat (40000) begin // repeat the whole sequence multiple times to sample transitions and more coverage
      opcode_e i;
      foreach (t.opcode_seq[i]) begin
        // golden check
        logic signed [5:0] exp_out2;
        // apply baseline inputs and current opcode from the unique sequence
        cin = baseline_cin;
        serial_in = baseline_serial_in;
        red_op_A = baseline_redA;
        red_op_B = baseline_redB;
        bypass_A = baseline_bypassA;
        bypass_B = baseline_bypassB;
        direction = baseline_dir;
        A = baseline_A;
        B = baseline_B;

        opcode = t.opcode_seq[i];

        // wait for register capture
        @(posedge clk);

        // sample coverage
        t.sample();

        golden_model (A_reg, B_reg, opcode_reg, red_op_A_reg, red_op_B_reg,
                      bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg,
                      cin_reg, exp_out2);

        if (out_dut !== exp_out2) begin
          $display("Mismatch SECOND_LOOP time=%0t opcode=%0d A=%0d B=%0d dut=%0d exp=%0d",
                   $time, opcode_reg, A_reg, B_reg, out_dut, exp_out2);
        end
      end
    end

    // Save coverage and finish
    $display("Test completed. Stopping simulation.");
    $stop;
  end

endmodule */
