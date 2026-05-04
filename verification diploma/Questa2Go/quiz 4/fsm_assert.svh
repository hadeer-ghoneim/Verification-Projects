interface c_if #(parameter WIDTH = 8);
    logic [WIDTH-1:0] data;
endinterface

module tb(c_if interf);
    initial $display("WIDTH = %0d", $bits(interf.data)); // $bits returns number of bits
endmodule

module top_questa;
    c_if #(16) interf();
    tb d(interf);
endmodule