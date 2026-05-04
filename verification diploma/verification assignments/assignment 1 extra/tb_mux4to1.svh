module tb_mux4to1;

bit [3:0] d;
bit [1:0] sel;
logic y;

mux4to1 dut (.*);

initial begin
    d   = 4'b1010;
    sel = 2'b00;

    #10 sel = 2'b10;
    #10 sel = 2'b01;

    #20 $stop;
end

endmodule