module ALSU(A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, clk, rst, direction, leds, out);
parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";
input clk, cin, rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
input [2:0] opcode;
input signed [2:0] A, B;
output reg [15:0] leds;
output reg signed [5:0] out;

reg red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg;
reg signed [1:0] cin_reg;
reg [2:0] opcode_reg;
reg signed [2:0] A_reg, B_reg;

wire invalid_red_op, invalid_opcode, invalid;

//Invalid handling
assign invalid_red_op = (red_op_A_reg | red_op_B_reg) & (opcode_reg[1] | opcode_reg[2]);
assign invalid_opcode = opcode_reg[1] & opcode_reg[2];
assign invalid = invalid_red_op | invalid_opcode;

//Registering input signals
always @(posedge clk or posedge rst) begin
  if(rst) begin
     cin_reg <= 0;
     red_op_B_reg <= 0;
     red_op_A_reg <= 0;
     bypass_B_reg <= 0;
     bypass_A_reg <= 0;
     direction_reg <= 0;
     serial_in_reg <= 0;
     opcode_reg <= 0;
     A_reg <= 0;
     B_reg <= 0;
  end else begin
     cin_reg <= cin;
     red_op_B_reg <= red_op_B;
     red_op_A_reg <= red_op_A;
     bypass_B_reg <= bypass_B;
     bypass_A_reg <= bypass_A;
     direction_reg <= direction;
     serial_in_reg <= serial_in;
     opcode_reg <= opcode;
     A_reg <= A;
     B_reg <= B;
  end
end

//leds output blinking 
always @(posedge clk or posedge rst) begin
  if(rst) begin
     leds <= 0;
  end else begin
      if (invalid)
        leds <= ~leds;
      else
        leds <= 0;
  end
end

//ALSU output processing
always @(posedge clk or posedge rst) begin
  if(rst) begin
    out <= 0;
  end
  else begin
    if (bypass_A_reg && bypass_B_reg)
      out <= (INPUT_PRIORITY == "A")? A_reg: B_reg;
    else if (bypass_A_reg)
      out <= A_reg;
    else if (bypass_B_reg)
      out <= B_reg;
    else if (invalid) 
        out <= 0;
    else begin
        case (opcode_reg)
          3'h0: begin 
            if (red_op_A_reg && red_op_B_reg)
              out <= (INPUT_PRIORITY == "A")? |A_reg: |B_reg;
            else if (red_op_A_reg) 
              out <= |A_reg;
            else if (red_op_B_reg)
              out <= |B_reg;
            else 
              out <= A_reg | B_reg;
          end
          3'h1: begin
            if (red_op_A_reg && red_op_B_reg)
              out <= (INPUT_PRIORITY == "A")? ^A_reg: ^B_reg;
            else if (red_op_A_reg) 
              out <= ^A_reg;
            else if (red_op_B_reg)
              out <= ^B_reg;
            else 
              out <= A_reg ^ B_reg;
          end
          3'h2: out <= (FULL_ADDER == "ON") ? (A_reg + B_reg + cin_reg) : (A_reg + B_reg);
          3'h3: out <= A_reg * B_reg;
          3'h4: begin
            if (direction_reg)
              out <= {out[4:0], serial_in_reg};
            else
              out <= {serial_in_reg, out[5:1]};
          end
          3'h5: begin
            if (direction_reg)
              out <= {out[4:0], out[5]};
            else
              out <= {out[0], out[5:1]};
          end
          default: out <= 0;
        endcase
    end 
  end
end

// =============================================
// ASSERTIONS INSIDE DESIGN MODULE
// =============================================

// Internal signals for reference model
logic signed [5:0] expected_out;
logic [15:0] expected_leds;
logic [15:0] leds_prev_assert;

// Reference model for assertions
always @(posedge clk or posedge rst) begin
    if (rst) begin
        expected_leds <= 0;
        leds_prev_assert <= 0;
    end else if (invalid) begin
        expected_leds <= ~leds_prev_assert;
        leds_prev_assert <= expected_leds;
    end else begin
        expected_leds <= 0;
        leds_prev_assert <= 0;
    end
end

// Output reference model
always @(*) begin
    if (rst)
        expected_out = 0;
    else if (invalid)
        expected_out = 0;
    else if (bypass_A_reg && bypass_B_reg)
        expected_out = (INPUT_PRIORITY == "A") ? A_reg : B_reg;
    else if (bypass_A_reg)
        expected_out = A_reg;
    else if (bypass_B_reg)
        expected_out = B_reg;
    else begin
        case (opcode_reg)
            3'h0: begin 
                if (red_op_A_reg && red_op_B_reg)
                    expected_out = (INPUT_PRIORITY == "A") ? |A_reg : |B_reg;
                else if (red_op_A_reg) 
                    expected_out = |A_reg;
                else if (red_op_B_reg)
                    expected_out = |B_reg;
                else 
                    expected_out = A_reg | B_reg;
            end
            3'h1: begin
                if (red_op_A_reg && red_op_B_reg)
                    expected_out = (INPUT_PRIORITY == "A") ? ^A_reg : ^B_reg;
                else if (red_op_A_reg) 
                    expected_out = ^A_reg;
                else if (red_op_B_reg)
                    expected_out = ^B_reg;
                else 
                    expected_out = A_reg ^ B_reg;
            end
            3'h2: expected_out = (FULL_ADDER == "ON") ? (A_reg + B_reg + cin_reg) : (A_reg + B_reg);
            3'h3: expected_out = A_reg * B_reg;
            3'h4: expected_out = direction_reg ? {out[4:0], serial_in_reg} : {serial_in_reg, out[5:1]};
            3'h5: expected_out = direction_reg ? {out[4:0], out[5]} : {out[0], out[5:1]};
            default: expected_out = 0;
        endcase
    end
end

// =============================================
// ASSERTION PROPERTIES
// =============================================

// ALSU_1: Output correctness
property output_correct_p;
    @(posedge clk) disable iff (rst)
    ##1 out == expected_out;
endproperty
ASSERT_OUTPUT_CORRECT: assert property (output_correct_p) else
    $error("ALSU_1: Output mismatch! out=%0d, expected=%0d", out, expected_out);

// ALSU_2: LED correctness  
property leds_correct_p;
    @(posedge clk) disable iff (rst)
    ##1 leds == expected_leds;
endproperty
ASSERT_LEDS_CORRECT: assert property (leds_correct_p) else
    $error("ALSU_2: LED mismatch! leds=%0h, expected=%0h", leds, expected_leds);

// ALSU_3: Reset behavior
property reset_behavior_p;
    @(posedge clk) rst |-> out == 0 && leds == 0;
endproperty
ASSERT_RESET_BEHAVIOR: assert property (reset_behavior_p) else
    $error("ALSU_3: Reset behavior failed!");

// ALSU_4: Invalid operation output zero
property invalid_output_zero_p;
    @(posedge clk) disable iff (rst)
    invalid |-> ##1 out == 0;
endproperty
ASSERT_INVALID_OUTPUT_ZERO: assert property (invalid_output_zero_p) else
    $error("ALSU_4: Invalid operation should output zero!");

// ALSU_5: Invalid operation LEDs blink
property invalid_leds_blink_p;
    @(posedge clk) disable iff (rst)
    invalid |-> ##1 leds == ~$past(leds);
endproperty
ASSERT_INVALID_LEDS_BLINK: assert property (invalid_leds_blink_p) else
    $error("ALSU_5: Invalid operation LEDs should blink!");

// ALSU_6: Valid operation LEDs off
property valid_leds_off_p;
    @(posedge clk) disable iff (rst)
    !invalid |-> ##1 leds == 0;
endproperty
ASSERT_VALID_LEDS_OFF: assert property (valid_leds_off_p) else
    $error("ALSU_6: Valid operation LEDs should be off!");

// ALSU_7: Bypass A functionality
property bypass_A_p;
    @(posedge clk) disable iff (rst || invalid)
    (bypass_A_reg && !bypass_B_reg) |-> ##1 out == A_reg;
endproperty
ASSERT_BYPASS_A: assert property (bypass_A_p) else
    $error("ALSU_7: Bypass A failed! out=%0d, A_reg=%0d", out, A_reg);

// ALSU_8: Bypass B functionality
property bypass_B_p;
    @(posedge clk) disable iff (rst || invalid)
    (!bypass_A_reg && bypass_B_reg) |-> ##1 out == B_reg;
endproperty
ASSERT_BYPASS_B: assert property (bypass_B_p) else
    $error("ALSU_8: Bypass B failed! out=%0d, B_reg=%0d", out, B_reg);

// ALSU_9: Reduction operations - A only
property reduction_A_p;
    @(posedge clk) disable iff (rst || invalid)
    (red_op_A_reg && !red_op_B_reg && opcode_reg inside {3'h0, 3'h1}) |-> 
    A_reg inside {3'b001, 3'b010, 3'b100} && B_reg == 0;
endproperty
ASSERT_REDUCTION_A: assert property (reduction_A_p) else
    $error("ALSU_9: Reduction A constraints failed!");

// ALSU_10: Reduction operations - B only
property reduction_B_p;
    @(posedge clk) disable iff (rst || invalid)
    (!red_op_A_reg && red_op_B_reg && opcode_reg inside {3'h0, 3'h1}) |-> 
    B_reg inside {3'b001, 3'b010, 3'b100} && A_reg == 0;
endproperty
ASSERT_REDUCTION_B: assert property (reduction_B_p) else
    $error("ALSU_10: Reduction B constraints failed!");

// ALSU_11: Invalid reduction operations
property invalid_reduction_p;
    @(posedge clk) disable iff (rst)
    ((red_op_A_reg || red_op_B_reg) && opcode_reg inside {3'h2, 3'h3, 3'h4, 3'h5}) |-> invalid;
endproperty
ASSERT_INVALID_REDUCTION: assert property (invalid_reduction_p) else
    $error("ALSU_11: Invalid reduction operation detection failed!");

// ALSU_12: Invalid opcodes
property invalid_opcodes_p;
    @(posedge clk) disable iff (rst)
    (opcode_reg inside {3'h6, 3'h7}) |-> invalid;
endproperty
ASSERT_INVALID_OPCODES: assert property (invalid_opcodes_p) else
    $error("ALSU_12: Invalid opcode detection failed!");

endmodule