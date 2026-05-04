module ALU_tb;

  import ALU_pkg::*;

  // ================================
  // DUT signals
  // ================================
  logic clk;
  logic reset;
  opcode_t Opcode;
  logic signed [3:0] A, B;
  logic signed [4:0] C_dut;

  // ================================
  // DUT instantiation
  // ================================
  ALU dut (
    .clk   (clk),
    .reset (reset),
    .Opcode(Opcode),
    .A     (A),
    .B     (B),
    .C     (C_dut)
  );

  // ================================
  // Transaction object
  // ================================
  ALU_inputs tr;

  // ================================
  // Golden model – pure combinational
  // ================================
  function automatic logic signed [4:0] golden_model(
    input opcode_t op,
    input logic signed [3:0] a,
    input logic signed [3:0] b,
    input logic rst
  );
    if (rst) begin
      golden_model = '0;
    end else begin
      case (op)
        ADD:          golden_model = a + b;
        SUB:          golden_model = a - b;
        NOT_A:        golden_model = ~a;
        REDUCTION_OR: golden_model = |b;
      endcase
    end
  endfunction

  // ================================
  // Clock generation
  // ================================
  always #5 clk = ~clk;

  // ================================
  // Self-check block
  // ================================
  int pass_count = 0;
  int err_count  = 0;

  initial begin
    // Init
    clk    = 0;
    reset  = 1;
    Opcode = ADD;
    A      = '0;
    B      = '0;

    // Hold reset a few cycles
    repeat(2) @(posedge clk);
    reset = 0;

    // Create transaction object
    tr = new();

    // Run randomized test
    repeat (200) begin

      logic signed [4:0] expected;

      // Randomize transaction
      assert(tr.randomize()) else $fatal("Randomization failed!");

      // Drive signals
      A      = tr.A;
      B      = tr.B;
      Opcode = tr.Opcode;
      reset  = tr.reset;

      // Wait for clock edge so DUT actually registers outputs
      @(posedge clk);

      // Golden model expected value
      expected = golden_model(Opcode, A, B, reset);

      // Compare
      if (C_dut !== expected) begin
        $display("ERROR: op=%s A=%0d B=%0d -> DUT=%0d, EXP=%0d, reset=%0b",
                  Opcode.name(), A, B, C_dut, expected, reset);
        err_count++;
      end else begin
        pass_count++;
      end

            // Golden model expected value
      expected = golden_model(Opcode, A, B, reset);

    end

    $display("✅ Simulation finished: pass=%0d, errors=%0d", pass_count, err_count);
    $stop;
  end

endmodule
