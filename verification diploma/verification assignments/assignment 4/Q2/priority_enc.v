module priority_enc (
    input  clk,
    input  rst,
    input  [3:0] D,    
    output reg [1:0] Y,    
    output reg valid
);

always @(posedge clk) begin
    if (rst) begin
        Y <= 2'b00;
        valid <= 1'b0;
    end 
    else begin
        casex (D)
            4'b1xxx: Y <= 2'b11;  // Highest priority: D[3]
            4'b01xx: Y <= 2'b10;  // D[2]
            4'b001x: Y <= 2'b01;  // D[1]
            4'b0001: Y <= 2'b00;  // D[0]
            default: Y <= 2'b00;  // Handle all other cases
        endcase

        valid <= (D != 4'b0000);
    end
end
endmodule