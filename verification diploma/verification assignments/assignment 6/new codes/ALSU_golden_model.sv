package ALSU_golden_model_pkg;

    import shared_pkg::*;

    class ALSU_golden_model;
        
        // Model parameters (same as DUT)
        string INPUT_PRIORITY = "A";
        string FULL_ADDER = "ON";
        
        // Model state
        logic signed [5:0] current_out = 0;
        logic [15:0] current_leds = 0;
        logic [15:0] leds_prev = 0;

        function new(string priority = "A", string full_adder = "ON");
            this.INPUT_PRIORITY = priority;
            this.FULL_ADDER = full_adder;
        endfunction

        // Check for invalid cases - from picture
        function bit is_invalid(
            input opcode_e opcode_reg,
            input bit red_op_A_reg,
            input bit red_op_B_reg
        );
            // invalid case 1: invalid opcodes
            if (opcode_reg inside {INVALID_6, INVALID_7})
                return 1;
            // invalid case 2: reduction with non-bitwise opcodes  
            else if ((opcode_reg > 3'h1) && (red_op_A_reg || red_op_B_reg))
                return 1;
            else
                return 0;
        endfunction

        // Golden model task - from picture logic
        task predict_output(
            input logic signed [2:0] A,
            input logic signed [2:0] B,
            input logic cin,
            input logic serial_in,
            input logic red_op_A,
            input logic red_op_B,
            input opcode_e opcode,
            input logic bypass_A,
            input logic bypass_B,
            input logic direction,
            input logic reset,
            output logic signed [5:0] predicted_out,
            output logic [15:0] predicted_leds
        );
            
            bit invalid;
            
            // Check invalid cases
            invalid = is_invalid(opcode, red_op_A, red_op_B);
            
            // Handle leds - from picture
            if (reset) begin
                predicted_leds = 0;
                leds_prev = 0;
            end else if (invalid) begin
                predicted_leds = ~leds_prev;
                leds_prev = predicted_leds;
            end else begin
                predicted_leds = 0;
                leds_prev = 0;
            end
            
            // Handle output - from picture logic
            if (reset) begin
                predicted_out = 0;
                current_out = 0;
            end else if (bypass_A) begin
                predicted_out = A;
            end else if (bypass_B) begin
                predicted_out = B;
            end else if (invalid) begin
                predicted_out = 0;
            end else begin
                case (opcode)
                    OR: begin
                        if (red_op_A)
                            predicted_out = |A;
                        else if (red_op_B)
                            predicted_out = |B;
                        else
                            predicted_out = A | B;
                    end
                    XOR: begin
                        if (red_op_A)
                            predicted_out = ^A;
                        else if (red_op_B)
                            predicted_out = ^B;
                        else
                            predicted_out = A ^ B;
                    end
                    ADD: predicted_out = (FULL_ADDER == "ON") ? (A + B + cin) : (A + B);
                    MULT: predicted_out = A * B;
                    SHIFT: begin
                        if (direction)
                            predicted_out = {current_out[4:0], serial_in};
                        else
                            predicted_out = {serial_in, current_out[5:1]};
                    end
                    ROTATE: begin
                        if (direction)
                            predicted_out = {current_out[4:0], current_out[5]};
                        else
                            predicted_out = {current_out[0], current_out[5:1]};
                    end
                    default: predicted_out = 0;
                endcase
            end
            
            // Update current state for next operation
            current_out = predicted_out;
            
        endtask

        // Reset the model state
        function void reset();
            current_out = 0;
            current_leds = 0;
            leds_prev = 0;
        endfunction

        // Check reset behavior - from picture
        function bit check_reset(
            input logic signed [5:0] out,
            input logic [15:0] leds
        );
            return (out == 0 && leds == 0);
        endfunction

    endclass

endpackage