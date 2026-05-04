package adder_pkg;

  // Enum 
  typedef enum logic signed [3:0] {
    MAXNEG = -4'sd8,
    ZERO   = 4'sd0,
    MAXPOS = 4'sd7
  } special_values_e;

  // Class
  class adder_transaction;

    // Randomized inputs
    rand logic signed [3:0] A;
    rand logic signed [3:0] B;
    rand bit reset;

    // Reset happens rarely
    constraint c_reset_low_prob {
      reset dist {1 := 1, 0 := 9};
    }

    // A more likely to be MAXPOS, ZERO, MAXNEG
    constraint c_A_values {
      A dist {-4'sd8 := 5, 4'sd0 := 5, 4'sd7 := 5, [-8:7] := 1};
    }

    // B more likely to be MAXPOS, ZERO, MAXNEG
    constraint c_B_values {
      B dist {-4'sd8 := 5, 4'sd0 := 5, 4'sd7 := 5, [-8:7] := 1};
    }

    // Functional coverage for A
    covergroup Covgrp_A;
      cp_A_values: coverpoint A {
        bins data_0       = {ZERO};
        bins data_max     = {MAXPOS};
        bins data_min     = {MAXNEG};
        bins data_default = default;
      }
      cp_A_transitions: coverpoint A {
        bins data_0max   = (ZERO => MAXPOS);
        bins data_maxmin = (MAXPOS => MAXNEG);
        bins data_minmax = (MAXNEG => MAXPOS);
      }
    endgroup

    // Functional coverage for B
    covergroup Covgrp_B;
      cp_B_values: coverpoint B {
        bins data_0       = {ZERO};
        bins data_max     = {MAXPOS};
        bins data_min     = {MAXNEG};
        bins data_default = default;
      }
      cp_B_transitions: coverpoint B {
        bins data_0max   = (ZERO => MAXPOS);
        bins data_maxmin = (MAXPOS => MAXNEG);
        bins data_minmax = (MAXNEG => MAXPOS);
      }
    endgroup

    // Constructor
    function new();
      Covgrp_A = new();
      Covgrp_B = new();
    endfunction

    // Manual sampling
    function void sample();
      if (!reset) begin
        Covgrp_A.sample();
        Covgrp_B.sample();
      end
    endfunction

  endclass : adder_transaction

endpackage : adder_pkg
