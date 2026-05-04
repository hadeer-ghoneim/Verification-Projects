package sequenceItem_pkg;
import shared_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name, this);

// Sequence Item class Valid and Invalid
class ALSU_sequenceItem extends uvm_sequence_item;
    `uvm_object_utils(ALSU_sequenceItem) 
    logic clk;
    rand logic rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
    rand opcode_e opcode;
    rand logic signed [2:0] A, B;
    logic [15:0] leds;
    logic [5:0] out;
    logic [15:0] leds_ref;
    logic [5:0] out_ref;

    function new(string name = "ALSU_sequenceItem");
        super.new(name);
    endfunction //new()

    // built in function
    function string convert2string();
        return $sformatf("%s, rst = %0d, A = %0d, B = %0d cin = %0d, red_op_A = %0d, red_op_B = %0d, bypass_A = %0d, bypass_B = %0d,
        direction = %0d, serial_in = %0d \n out = %0d, out_ref = 0%0d ",
        super.convert2string(), rst, A, B, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in, out, out_ref
        );
    endfunction
    // my function to print ALSU inputs and outputs
    function string convert2string_stim();
        return $sformatf("rst = %0d, opcode = %0s, cin = %0d, red_op_A = %0d, red_op_B = %0d, bypass_A = %0d, bypass_B = %0d,
        direction = %0d, serial_in = %0d \n out = %0d",
        rst, opcode, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in, out
        ); 
    endfunction

    /////// ////// ////// ////// //////
    //       Constraint block        //
    ////// /////// ///// /////// //////
    constraint rules1_7 {
        //rst constraint
            rst dist {0:=100-RESET_DIST, 1:=RESET_DIST};

        // Invalid cases constraint
            opcode dist {INVALID_6:=5, INVALID_7:=5, [0:5]:/90};

        // A & B constraint when opcode is ADD or MULT
            (opcode == MULT || opcode == ADD) -> A dist {MAXPOS:=20, ZERO:=10, MAXNEG:=20, [MAXNEG+1:MAXPOS-1]:/50};
            (opcode == MULT || opcode == ADD) -> B dist {MAXPOS:=20, ZERO:=10, MAXNEG:=20, [MAXNEG+1:MAXPOS-1]:/50};

        // A & B constraint when opcode is OR or XOR and red_op_A is high
            ((opcode==XOR || opcode==OR) && red_op_A) -> A dist {3'b001:=30, 3'b010:=30, 3'b100:=30, [MAXNEG+1:MAXPOS-1]:/10};
            ((opcode==XOR || opcode==OR) && red_op_A) -> B == 0;

        // A & B constraint when opcode is OR or XOR and red_op_B is high
            ((opcode==XOR || opcode==OR) && red_op_B) -> A == 0;
            ((opcode==XOR || opcode==OR) && red_op_B) -> B dist {3'b001:=30, 3'b010:=30, 3'b100:=30, [MAXNEG+1:MAXPOS-1]:/10};

        //  Do not constraint the inputs A or B when the operation is shift or rotate
        // it's achieved by default after the 2,3 and 4 Constraint achieved

        // bypass constraint
            bypass_A dist {0:=90, 1:=10};
            bypass_B dist {0:=90, 1:=10};

        // red_op constraint
            red_op_A dist {0:=80, 1:=20};
            red_op_B dist {0:=80, 1:=20};

        // A & B constraint when opcode is OR or XOR and red_op is low
            ((opcode==XOR || opcode==OR) && ~red_op_A && ~red_op_B) -> A == ~B;
    }

    rand opcode_e arr [6];
    constraint rules_8 {
        foreach(arr[i])
            arr[i] inside {OR, XOR, ADD, MULT, SHIFT, ROTATE};
        unique {arr};
        //foreach(arr[i])
    }

    constraint MAKE_bypass_red_rst_ZERO {
        rst == 0;
        bypass_A == 0; bypass_B == 0;
        red_op_A == 0; red_op_B == 0;
    }

    constraint INPUT_PRIORITY_CONS {
        red_op_A == red_op_B;
        bypass_A == bypass_B;
    }
endclass //ALSU_sequenceItem extends uvm_sequence_item
endpackage