module dff(clk, rst, d, q, en);
parameter USE_EN = 1;
input clk, rst, d, en;
output reg q;

always @(posedge clk) begin 
   if (rst)
      q <= 0;
   else
      if (USE_EN) begin
        if (en) 
            q <= d;
      end 
      else begin
             q <= d;
end
end 

endmodule

