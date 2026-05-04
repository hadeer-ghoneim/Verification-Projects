package ALU_pkg;
  // ------------------------------------------
  // Typedef enum for opcode
  // ------------------------------------------
  typedef enum logic [1:0] {
    ADD           = 2'b00,
    SUB           = 2'b01,
    NOT_A         = 2'b10,
    REDUCTION_OR  = 2'b11
  } opcode_t;
  // ------------------------------------------
  // ALU Transaction Class
  // ------------------------------------------
  class ALU_inputs;
    rand bit signed [3:0] A;
    rand bit signed [3:0] B;
    rand opcode_t Opcode;
    rand bit reset;

    // Constraint: reset is low most of the time
    constraint c_reset {
      reset dist { 1 := 1, 0 := 9 }; // 10% high, 90% low
    }

    // Constructor
    function new();
    endfunction

    // For debugging / printing
    function void display();
      $display("Time=%0t | reset=%0b | Opcode=%s | A=%0d | B=%0d",
               $time, reset, Opcode.name(), A, B);
    endfunction
  endclass

endpackage
