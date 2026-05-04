module dsp_block 
#( parameter OPERATION = "ADD") // or "SUBTRACT" 
(   input wire clk,
    input wire rst_n,
    input wire [17:0] A,
    input wire [17:0] B,
    input wire [17:0] D,
    input wire [47:0] C,
    output reg [47:0] P  );

    // Internal pipeline registers
    reg [35:0] multiplier_out;
    reg [17:0] D_minus_B;
    reg [47:0] sub_result;

    always @(posedge clk) begin

        if (!rst_n) begin
            multiplier_out <= 36'b0;
            P <= 48'b0;
        end 
        
        else begin
            multiplier_out <= A * B;

            if (OPERATION == "ADD") begin
                P <= multiplier_out + C;
            end 
            else begin // SUBTRACT
                D_minus_B <= D - B;
                sub_result <= D_minus_B - C[17:0]; 
                // You may need to extend properly
                P <= sub_result;
            end
        end
    end
endmodule