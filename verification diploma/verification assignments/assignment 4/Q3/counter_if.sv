// counter_if.sv
interface counter_if(input clk);
    logic rst_n;
    logic load_n;
    logic up_down;
    logic ce;
    logic [3:0] data_load;
    logic [3:0] count_out;
    logic max_count;
    logic zero;

    // Modport for DUT
    modport DUT (
        input clk, rst_n, load_n, up_down, ce, data_load,
        output count_out, max_count, zero
    );

    // Modport for TB
    modport TB (
        output rst_n, load_n, up_down, ce, data_load,
        input clk, count_out, max_count, zero
    );

    // Modport for SVA
    modport SVA (
        input clk, rst_n, load_n, up_down, ce, data_load, count_out, max_count, zero
    );

    // Modport for Monitor
    modport MONITOR (
        input clk, rst_n, load_n, up_down, ce, data_load, count_out, max_count, zero
    );
endinterface
/*
interface counter_if #(parameter WIDTH = 4);

    logic clk;
    logic rst_n;
    logic load_n;
    logic up_down;
    logic ce;
    logic [WIDTH-1:0] data_load;
    logic [WIDTH-1:0] count_out;
    logic max_count;
    logic zero;

    // Modport for SVA
    modport SVA (
        input clk, rst_n, load_n, up_down, ce, data_load, count_out, max_count, zero
    );

    // Modport for TB (driving signals)
    modport TB (
        output rst_n, load_n, up_down, ce, data_load,
        input  clk, count_out, max_count, zero
    );

    // Modport for Monitor (read-only)
    modport MONITOR (
        input clk, rst_n, load_n, up_down, ce, data_load, count_out, max_count, zero
    );

endinterface
*/

//Guide lines:
// 1. Add the parameters (WAIT = 0, Q_25 = 1, Q_50 =2)
// 2. Add the clock as an input port
// 3. Add the internal signals of the interface
// 4. Add the modports
