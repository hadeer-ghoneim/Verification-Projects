interface ALSU_if (input clk);
    logic cin, rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
    logic [2:0] opcode;
    logic signed [2:0] A, B;
    logic [15:0] leds;
    logic signed [5:0] out;
    
    // Clocking block for synchronized driving
    clocking drv_cb @(posedge clk);
        output A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, direction, rst;
        input out, leds;
    endclocking
    
    // Clocking block for monitoring
    clocking mon_cb @(posedge clk);
        input A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, direction, rst, out, leds;
    endclocking
    
    // Modports for different components
    modport DRV (clocking drv_cb);
    modport MON (clocking mon_cb);
    modport DUT (
        input A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, clk, rst, direction,
        output leds, out
    );
    
endinterface : ALSU_if