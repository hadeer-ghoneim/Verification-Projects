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
        valid <= 1'b0;   // Fix 1: valid = 0 at reset
    end 
    else begin           // Fix 2: casex and valid in begin-end
        casex (D)
            4'b1000: Y <= 2'b00;
            4'bX100: Y <= 2'b01;
            4'bXX10: Y <= 2'b10;
            4'bXXX1: Y <= 2'b11;
        endcase

        valid <= (~|D) ? 1'b0 : 1'b1; 
    end
end
endmodule
