`timescale 1ps/1ps
package shared_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
parameter INPUT_PRIORITY = "A";
parameter FULL_ADDER = "ON";

typedef enum reg [2:0] {OR, XOR, ADD, MULT, SHIFT, ROTATE, INVALID_6, INVALID_7} opcode_e;
parameter MAXPOS = 3;
parameter ZERO = 0; 
parameter MAXNEG = -4;

parameter HOBBIT_LOOP = 1000;
parameter DWARF_LOOP = 10_000;
parameter HUMAN_LOOP = 20_000;
parameter GIANT_LOOP = 30_000;

bit alwaysValid = 0;
int RESET_DIST = 5;
endpackage