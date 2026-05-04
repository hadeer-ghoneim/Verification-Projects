import shared_pkg::*;

module ALSU_ref (A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, clk, rst, direction, leds, out);    
input clk, rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
//input opcode_e opcode;
input [2:0] opcode;
input signed [2:0] A, B;
output reg [15:0] leds;
output reg [5:0] out;

reg cin_reg, red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg;
reg [2:0] A_reg, B_reg;
reg [2:0] opcode_reg;

wire invalid, invalid_c1, invalid_c2;
assign invalid_c1 = (opcode_reg == 6 || opcode_reg == 7);
assign invalid_c2 = (red_op_A_reg || red_op_B_reg) && (opcode_reg != 0 && opcode_reg != 1);
assign invalid = invalid_c1 || invalid_c2;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        out <= 0;
        leds <= 0;
        cin_reg <= 0;
        red_op_A_reg <= 0;
        red_op_B_reg <= 0;
        bypass_A_reg <= 0;
        bypass_B_reg <= 0;
        direction_reg <= 0;
        serial_in_reg <= 0;
        opcode_reg <= 0;
        A_reg <= 0;
        B_reg <= 0;
    end
    else begin
        if (invalid&&!(bypass_A_reg || bypass_B_reg)) leds <= ~leds;
        else leds <= 0;
            
        cin_reg <= cin;
        red_op_A_reg <= red_op_A;
        red_op_B_reg <= red_op_B;
        bypass_A_reg <= bypass_A;
        bypass_B_reg <= bypass_B;
        direction_reg <= direction;
        serial_in_reg <= serial_in;
        opcode_reg <= opcode;
        A_reg <= A;
        B_reg <= B;

        if (bypass_A_reg && bypass_B_reg)
            out <= (INPUT_PRIORITY=="A")? A_reg:B_reg;
        else if (bypass_A_reg)
            out <= A_reg;
        else if (bypass_B_reg) 
            out <= B_reg;
        else if (invalid) 
            out <= 0;
        else if (opcode_reg == 0) begin 
            if (red_op_A_reg && red_op_B_reg)
                out <= (INPUT_PRIORITY=="A")? (|A_reg):(|B_reg);
            else if (red_op_A_reg)
                out <= |A_reg;
            else if (red_op_B_reg)
                out <= |B_reg;
            else
                out <= A_reg|B_reg;            
        end
        else if (opcode_reg == 1) begin
            if (red_op_A_reg && red_op_B_reg)
                out <= (INPUT_PRIORITY=="A")? (^A_reg):(^B_reg);
            else
                out <= (red_op_A_reg)? (^A_reg): (red_op_B_reg)? (^B_reg):(A_reg^B_reg);
        end
        else if (opcode_reg == 2) 
            out <= (FULL_ADDER=="ON")? (A_reg + B_reg + cin_reg):(A_reg + B_reg);
        else if (opcode_reg == 3) 
            out <= A_reg * B_reg;
        else if (opcode_reg == 4) begin
            if (direction_reg)
                out <= {out[4:0], serial_in_reg};
            else
                out <= {serial_in_reg, out[5:1]}; 
        end
        else if (opcode_reg == 5) begin
            if (direction_reg)
                out <= {out[4:0],out[5]};
            else
                out <= {out[0],out[5:1]}; 
        end 
    end
end    
endmodule
