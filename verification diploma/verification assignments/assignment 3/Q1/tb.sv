import testing_pkg::*;

module tb();

  Transaction tr = new();
  byte operand1, operand2, out, expected;
  opcode_e opcode;
  logic clk, rst;

  int correct_count = 0;
  int error_count   = 0;

  // Clock Generation
  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
      tr.clk = clk;
    end
  end

  // DUT Instantiation
  alu_seq DUT (
    .operand1 (operand1),
    .operand2 (operand2),
    .clk      (clk),
    .rst      (rst),
    .opcode   (opcode),
    .out      (out)
  );

  // ---------------------------
  // Tasks
  // ---------------------------

  // Reset task
  task do_reset();
    rst = 1; 
    @(negedge clk);
    rst = 0;
  endtask

  // Calculate expected output
  task calc_expected();
    case (opcode)
      ADD:  expected = operand1 + operand2;
      SUB:  expected = operand1 - operand2;
      MULT: expected = operand1 * operand2;
      DIV:  expected = (operand2 != 0) ? (operand1 / operand2) : 0;
      default: expected = 0;
    endcase
  endtask

  // Compare DUT vs Expected
  task check_output();
    if (out === expected) begin
      correct_count++;
      $display("PASS: opcode=%0s, op1=%0d, op2=%0d, out=%0d", 
                opcode.name(), operand1, operand2, out);
    end
    else begin
      error_count++;
      $display("FAIL: opcode=%0s, op1=%0d, op2=%0d, expected=%0d, got=%0d", 
                opcode.name(), operand1, operand2, expected, out);
    end
  endtask

  task force_operand1_operand2_cross();
  static byte corners[3] = '{-128, 0, 127};
  int i, j;

  for (i = 0; i < 3; i++) begin
    for (j = 0; j < 3; j++) begin
      operand1 = corners[i];
      operand2 = corners[j];
      opcode   = ADD;   
      opcode   = SUB; 
      opcode   = MULT; 
      opcode   = DIV; 

      @(negedge clk);
      calc_expected();
      check_output();   
    end
  end
endtask

 
  // ---------------------------
  // Stimulus
  // ---------------------------
  initial begin
    do_reset();

    force_operand1_operand2_cross();

    repeat (5000) begin
      assert(tr.randomize());  // generate transaction
      operand1 = tr.operand1;
      operand2 = tr.operand2;
      opcode   = tr.opcode;

      @(negedge clk); // wait for DUT
      calc_expected();
      check_output();

      do_reset();
    end

    $display("=======================================");
    $display("Simulation finished!");
    $display("Correct Count = %0d", correct_count);
    $display("Error Count   = %0d", error_count);
    $display("=======================================");

    $stop();
  end
endmodule

