module ALSU_assertions (input clk, rst, 
                       input signed [2:0] A, B,
                       input cin, serial_in, red_op_A, red_op_B,
                       input [2:0] opcode,
                       input bypass_A, bypass_B, direction,
                       input signed [5:0] out,       
                       input [15:0] leds);            

    // Internal signals
    logic invalid_red_op, invalid_opcode, invalid;
    logic signed [5:0] expected_out;
    logic [15:0] expected_leds;
    logic [15:0] leds_prev_reg;

    // Invalid operation detection
    assign invalid_red_op = (red_op_A | red_op_B) & (opcode[1] | opcode[2]);
    assign invalid_opcode = opcode[1] & opcode[2];
    assign invalid = invalid_red_op | invalid_opcode;

    // LED reference model - registered version
    always @(posedge clk or posedge rst) begin
        if (rst)
            leds_prev_reg <= 0;
        else
            leds_prev_reg <= expected_leds;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            expected_leds <= 0;
        else if (invalid)
            expected_leds <= ~leds_prev_reg;
        else
            expected_leds <= 0;
    end

    // Output reference model
    always @(*) begin
        if (rst)
            expected_out = 0;
        else if (invalid)
            expected_out = 0;
        else if (bypass_A && bypass_B)
            expected_out = ("A" == "A") ? A : B;
        else if (bypass_A)
            expected_out = A;
        else if (bypass_B)
            expected_out = B;
        else begin
            case (opcode)
                3'h0: begin 
                    if (red_op_A && red_op_B)
                        expected_out = ("A" == "A") ? |A : |B;
                    else if (red_op_A) 
                        expected_out = |A;
                    else if (red_op_B)
                        expected_out = |B;
                    else 
                        expected_out = A | B;
                end
                3'h1: begin
                    if (red_op_A && red_op_B)
                        expected_out = ("A" == "A") ? ^A : ^B;
                    else if (red_op_A) 
                        expected_out = ^A;
                    else if (red_op_B)
                        expected_out = ^B;
                    else 
                        expected_out = A ^ B;
                end
                3'h2: expected_out = ("ON" == "ON") ? (A + B + cin) : (A + B);
                3'h3: expected_out = A * B;
                3'h4: expected_out = direction ? {out[4:0], serial_in} : {serial_in, out[5:1]};
                3'h5: expected_out = direction ? {out[4:0], out[5]} : {out[0], out[5:1]};
                default: expected_out = 0;
            endcase
        end
    end

    // Assertions with timing fixes

    // ALSU_1: Output correctness - check one cycle later for registered output
    property output_correct_p;
        @(posedge clk) disable iff (rst)
        ##1 out == expected_out;
    endproperty
    ASSERT_OUTPUT_CORRECT: assert property (output_correct_p);

    // ALSU_2: LED correctness - check one cycle later
    property leds_correct_p;
        @(posedge clk) disable iff (rst)
        ##1 leds == expected_leds;
    endproperty
    ASSERT_LEDS_CORRECT: assert property (leds_correct_p);

    // ALSU_3: Reset behavior
    property reset_behavior_p;
        @(posedge clk) rst |-> out == 0 && leds == 0;
    endproperty
    ASSERT_RESET_BEHAVIOR: assert property (reset_behavior_p);

    // ALSU_4: Invalid operation output zero
    property invalid_output_zero_p;
        @(posedge clk) disable iff (rst)
        invalid |-> ##1 out == 0;
    endproperty
    ASSERT_INVALID_OUTPUT_ZERO: assert property (invalid_output_zero_p);

    // ALSU_5: Invalid operation LEDs blink
    property invalid_leds_blink_p;
        @(posedge clk) disable iff (rst)
        invalid |-> ##1 leds == ~$past(leds);
    endproperty
    ASSERT_INVALID_LEDS_BLINK: assert property (invalid_leds_blink_p);

    // ALSU_6: Valid operation LEDs off
    property valid_leds_off_p;
        @(posedge clk) disable iff (rst)
        !invalid |-> ##1 leds == 0;
    endproperty
    ASSERT_VALID_LEDS_OFF: assert property (valid_leds_off_p);

    // ALSU_7: Bypass A functionality
    property bypass_A_p;
        @(posedge clk) disable iff (rst || invalid)
        (bypass_A && !bypass_B) |-> ##1 out == A;
    endproperty
    ASSERT_BYPASS_A: assert property (bypass_A_p);

    // ALSU_8: Bypass B functionality
    property bypass_B_p;
        @(posedge clk) disable iff (rst || invalid)
        (!bypass_A && bypass_B) |-> ##1 out == B;
    endproperty
    ASSERT_BYPASS_B: assert property (bypass_B_p);

    // ALSU_9: Reduction operations - A only
    property reduction_A_p;
        @(posedge clk) disable iff (rst || invalid)
        (red_op_A && !red_op_B && opcode inside {3'h0, 3'h1}) |-> 
        A inside {3'b001, 3'b010, 3'b100} && B == 0;
    endproperty
    ASSERT_REDUCTION_A: assert property (reduction_A_p);

    // ALSU_10: Reduction operations - B only
    property reduction_B_p;
        @(posedge clk) disable iff (rst || invalid)
        (!red_op_A && red_op_B && opcode inside {3'h0, 3'h1}) |-> 
        B inside {3'b001, 3'b010, 3'b100} && A == 0;
    endproperty
    ASSERT_REDUCTION_B: assert property (reduction_B_p);

    // ALSU_11: Invalid reduction operations
    property invalid_reduction_p;
        @(posedge clk) disable iff (rst)
        ((red_op_A || red_op_B) && opcode inside {3'h2, 3'h3, 3'h4, 3'h5}) |-> invalid;
    endproperty
    ASSERT_INVALID_REDUCTION: assert property (invalid_reduction_p);

    // ALSU_12: Invalid opcodes
    property invalid_opcodes_p;
        @(posedge clk) disable iff (rst)
        (opcode inside {3'h6, 3'h7}) |-> invalid;
    endproperty
    ASSERT_INVALID_OPCODES: assert property (invalid_opcodes_p);

endmodule