package shared_pkg;

    //opcode
    typedef enum logic [2:0] {
        OR_OP     = 3'h0, 
        XOR_OP    = 3'h1,
        ADD_OP    = 3'h2, 
        MUL_OP    = 3'h3,
        SHIFT_OP  = 3'h4, 
        ROT_OP    = 3'h5,
        INVALID_6 = 3'h6, 
        INVALID_7 = 3'h7
    } opcode_e;

    //direction
    typedef enum bit {
        DIR_LEFT  = 1'b0,
        DIR_RIGHT = 1'b1
    } direction_e;

    
    // ALSU configuration parameters (same as DUT)
    parameter string INPUT_PRIORITY = "A";
    parameter string FULL_ADDER = "ON";
    

endpackage