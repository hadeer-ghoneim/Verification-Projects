import shared_pkg::*;

interface shift_reg_if (clk);

    input clk;
    logic reset;
    logic serial_in;
    direction_e direction;
    mode_e mode;
    logic [5:0] datain, dataout;

endinterface : shift_reg_if