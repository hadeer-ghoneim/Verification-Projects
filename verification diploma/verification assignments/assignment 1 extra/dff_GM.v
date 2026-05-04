module dff_GM(clk, rst, d, q, en);
parameter USE_EN = 0;
input clk, rst, d, en;
output reg q;

always @(posedge clk) begin 
   if (rst)
      q <= 0;
   else
      if(USE_EN)
            q <= d;
      else 
       if (en)
            q <= d;
end 

endmodule
