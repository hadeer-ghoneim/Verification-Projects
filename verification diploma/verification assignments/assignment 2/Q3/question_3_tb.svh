module question_3_tb();

  import alsu_pkg::*;

  // ===========================================
  // DUT signals
  // ===========================================
  logic clk, cin, serial_in, red_op_A, red_op_B, bypass_A, bypass_B, direction, rst;
  opcode_e opcode;
  logic signed [2:0] A, B;
  logic [15:0] leds;
  logic signed [5:0] out;

  // ===========================================
  // Registered copies of DUT inputs for Golden Model
  // ===========================================
  logic signed [2:0] A_reg, B_reg;
  opcode_e opcode_reg;
  logic red_op_A_reg, red_op_B_reg;
  logic bypass_A_reg, bypass_B_reg;
  logic direction_reg, serial_in_reg;
  logic cin_reg;

  // ===========================================
  // DUT output registers to avoid multiple drivers
  // ===========================================
  logic signed [5:0] out_dut;
  logic [15:0] leds_dut;

  // Assign to DUT through internal wires only
  assign out  = out_dut;
  assign leds = leds_dut;

  // ===========================================
  // Instantiate DUT
  // ===========================================
  ALSU dut (
    .clk(clk), .cin(cin), .serial_in(serial_in),
    .red_op_A(red_op_A), .red_op_B(red_op_B),
    .bypass_A(bypass_A), .bypass_B(bypass_B),
    .direction(direction), .rst(rst),
    .opcode(opcode), .A(A), .B(B),
    .leds(leds_dut), .out(out_dut)
  );

  // ===========================================
  // Clock generation
  // ===========================================
  always #5 clk = ~clk;

  // ===========================================
  // Input Register Stage (to match DUT internal behavior)
  // ===========================================
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      A_reg <= 0;
      B_reg <= 0;
      opcode_reg <= OR_OP;
      red_op_A_reg <= 0;
      red_op_B_reg <= 0;
      bypass_A_reg <= 0;
      bypass_B_reg <= 0;
      direction_reg <= 0;
      serial_in_reg <= 0;
      cin_reg <= 0;
    end else begin
      A_reg <= A;
      B_reg <= B;
      opcode_reg <= opcode;
      red_op_A_reg <= red_op_A;
      red_op_B_reg <= red_op_B;
      bypass_A_reg <= bypass_A;
      bypass_B_reg <= bypass_B;
      direction_reg <= direction;
      serial_in_reg <= serial_in;
      cin_reg <= cin;
    end
  end

  // ===========================================
  // Transaction object
  // ===========================================
  alsu_txn t;

  // ===========================================
  // Golden model task
  // ===========================================
  task golden_model
  (
    input logic signed [2:0] A, B,
    input opcode_e opcode,
    input logic red_op_A, red_op_B,
    input logic bypass_A, bypass_B,
    input logic direction, serial_in,
    input logic cin,
    output logic signed [5:0] exp_out
  );
    localparam string INPUT_PRIORITY = "A";
    localparam string FULL_ADDER = "ON";

    begin
      exp_out = 0;
      if (bypass_A && bypass_B) begin
        exp_out = (INPUT_PRIORITY == "A") ? A : B;
      end
      else if (bypass_A) begin
        exp_out = A;
      end
      else if (bypass_B) begin
        exp_out = B;
      end
      else begin
        case (opcode)
          OR_OP: begin
            if (red_op_A && red_op_B)
              exp_out = (INPUT_PRIORITY == "A") ? (|A) : (|B);
            else if (red_op_A) exp_out = |A;
            else if (red_op_B) exp_out = |B;
            else exp_out = A | B;
          end

          XOR_OP: begin
            if (red_op_A && red_op_B)
              exp_out = (INPUT_PRIORITY == "A") ? (^A) : (^B);
            else if (red_op_A) exp_out = ^A;
            else if (red_op_B) exp_out = ^B;
            else exp_out = A ^ B;
          end

          ADD_OP: begin
            if (FULL_ADDER == "ON")
              exp_out = A + B + cin;
            else
              exp_out = A + B;
          end

          MUL_OP: exp_out = A * B;

          default: exp_out = 0; // Shift/Rotate not implemented yet
        endcase
      end
    end
  endtask

  // ===========================================
  // Self-check initial block
  // ===========================================
  initial begin
    clk = 0;
    cin        = 1'b0;
    red_op_A   = 1'b0;
    red_op_B   = 1'b0;
    bypass_A   = 1'b0;
    bypass_B   = 1'b0;
    direction  = 1'b0;
    serial_in  = 1'b0;
    opcode     = ADD_OP;
    A          = '0;
    B          = '0;
    rst        = 1;

    // Hold reset for a few cycles
    #12 rst = 0;

    t = new();

    repeat (1000) begin
      logic signed [5:0] exp_out;
      assert(t.randomize());

      // Apply randomized inputs
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

      // Wait a clock cycle to capture registered values
      @(posedge clk);


      // Golden model expected output
      golden_model (
        A_reg, B_reg, opcode_reg,
        red_op_A_reg, red_op_B_reg,
        bypass_A_reg, bypass_B_reg,
        direction_reg, serial_in_reg,
        cin_reg,
        exp_out
      );

      // Compare results
      if (out_dut !== exp_out) begin
        $display("Mismatch at time %0t: opcode=%0d A=%0d B=%0d cin=%0d out=%0d exp=%0d",
                 $time, opcode_reg, A_reg, B_reg, cin_reg, out_dut, exp_out);
      end
    end

    $stop;
  end

endmodule