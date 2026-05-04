
module RAM (RAM_vif r_if);

reg [7:0] MEM [255:0];

reg [7:0] Rd_Addr, Wr_Addr;

always @(posedge r_if.clk) begin
    if (~r_if.rst_n) begin
        r_if.dout <= 0;
        r_if.tx_valid <= 0;
        Rd_Addr <= 0;
        Wr_Addr <= 0;
    end
    else                                           
        if (r_if.rx_valid) begin
            case (r_if.din[9:8])
                2'b00 : Wr_Addr <= r_if.din[7:0];
                2'b01 : MEM[Wr_Addr] <= r_if.din[7:0];
                2'b10 : Rd_Addr <= r_if.din[7:0];
                2'b11 : r_if.dout <= MEM[Rd_Addr];  //changed to read address
                default : r_if.dout <= 0;
            endcase
        end 

    r_if.tx_valid <= (r_if.din[9] && r_if.din[8] && r_if.rx_valid && r_if.rst_n)? 1'b1 : 1'b0; 
    //added the rst_n to avoid any clashes between tx assignment in rst condition and this one
end

endmodule