package sequenceItem_valid_pkg;
import sequenceItem_pkg::*;
import shared_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"
`define create_obj(type, name) type::type_id::create(name, this);
// Sequence Item class Valid Cases Only
class ALSU_sequenceItem_valid extends ALSU_sequenceItem;
    `uvm_object_utils(ALSU_sequenceItem_valid) 

    function new(string name = "ALSU_sequenceItem_valid");
        super.new(name);
    endfunction //new()

    /////// ////// ////// ////// //////
    //       Constraint block        //
    ////// /////// ///// /////// //////
    constraint rules1_7 {
    //rst constraint
        rst dist {0:=100-RESET_DIST, 1:=RESET_DIST};

    // make opcode always valid
        //opcode dist {INVALID_6:=5, INVALID_7:=5, [0:5]:/90};
        opcode inside {OR, XOR, ADD, MULT, SHIFT, ROTATE};
        // to avoid invalid cases
        if (opcode==OR||opcode==XOR)
            red_op_A dist {0:=90, 1:=10};
        else
            red_op_A == 0;
        if (opcode==OR||opcode==XOR)
            red_op_B dist {0:=90, 1:=10};
        else
            red_op_B == 0;

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

    // A & B constraint when opcode is OR or XOR and red_op is low
        ((opcode==XOR || opcode==OR) && ~red_op_A && ~red_op_B) -> A == ~B;
    }
endclass //ALSU_sequenceItem_valid extends uvm_sequence_item
endpackage