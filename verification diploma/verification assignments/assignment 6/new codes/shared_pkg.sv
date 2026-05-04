package shared_pkg;

    // opcode enum - محدث حسب الصور
    typedef enum bit [2:0] {
        OR       = 3'h0,
        XOR      = 3'h1, 
        ADD      = 3'h2,
        MULT     = 3'h3,
        SHIFT    = 3'h4,
        ROTATE   = 3'h5,
        INVALID_6 = 3'h6,
        INVALID_7 = 3'h7
    } opcode_e;

    // register value enum - جديد
    typedef enum bit [2:0] {
        MAXPOS = 3'b011,  // 3
        ZERO   = 3'b000,  // 0
        MAXNEG = 3'b100   // -4
    } reg_c;

    // direction enum
    typedef enum bit {
        DIR_LEFT  = 1'b0,
        DIR_RIGHT = 1'b1
    } direction_e;

    // ALSU configuration parameters
    parameter string INPUT_PRIORITY = "A";
    parameter string FULL_ADDER = "ON";
    parameter int VALID_OP = 6;

endpackage