`timescale 1ps/1ps
import shared_pkg::*;
interface ALSU_interface(input bit clk);
logic rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
opcode_e opcode;
logic signed [2:0] A, B;
logic [15:0] leds;
logic [5:0] out;
logic [5:0] out_ref;
logic [15:0] leds_ref;
endinterface //ALSU_interface