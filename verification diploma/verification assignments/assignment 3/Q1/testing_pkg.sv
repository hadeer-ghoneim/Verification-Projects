package testing_pkg;

  typedef enum {ADD, SUB, MULT, DIV} opcode_e;

  class Transaction;
    rand opcode_e opcode;
    rand byte operand1;
    rand byte operand2;
    bit clk;

    covergroup CovCode @(posedge clk);

      operand1_cp: coverpoint operand1 {
        bins max_neg = {-128};
        bins zero    = {0};
        bins max_pos = {127};
        bins misc    = default;
      }


	  operand2_cp: coverpoint operand2 {
        bins max_neg = {-128};
        bins zero    = {0};
        bins max_pos = {127};
        bins misc    = default;
      }


      opcode_cp: coverpoint opcode {
        bins add_sub     = {ADD, SUB};
		bins add_mult     = {ADD, MULT};
        bins mult_sub     = {MULT, SUB};
        bins add_then_sub = (ADD => SUB);
		bins add_then_mult = (SUB => MULT);
		bins mult_then_sub = (MULT => ADD);
        illegal_bins no_div = {DIV};
      }


	  opcode_operand1: cross opcode_cp, operand1_cp {
        option.weight = 5;
        option.cross_auto_bin_max = 0;

        bins max_pos_add_or_sub = 
         binsof(operand1_cp.max_pos) && binsof(opcode_cp.add_sub);

		bins max_pos_add_or_mult = 
         binsof(operand1_cp.max_pos) && binsof(opcode_cp.add_mult);

		bins max_pos_mult_or_sub =
         binsof(operand1_cp.max_pos) && binsof(opcode_cp.mult_sub);

        bins max_neg_add_or_sub =
         binsof(operand1_cp.max_neg) && binsof(opcode_cp.add_sub);

		bins max_neg_add_or_mult =
         binsof(operand1_cp.max_neg) && binsof(opcode_cp.add_mult);

		bins max_neg_mult_or_sub =
         binsof(operand1_cp.max_neg) && binsof(opcode_cp.mult_sub);
      }


	  opcode_operand2: cross opcode_cp, operand2_cp {
        option.weight = 5;
        option.cross_auto_bin_max = 0;

        bins max_pos_add_or_sub = 
         binsof(operand2_cp.max_pos) && binsof(opcode_cp.add_sub);

		bins max_pos_add_or_mult = 
         binsof(operand2_cp.max_pos) && binsof(opcode_cp.add_mult);

		bins max_pos_mult_or_sub =
         binsof(operand2_cp.max_pos) && binsof(opcode_cp.mult_sub);

        bins max_neg_add_or_sub =
         binsof(operand2_cp.max_neg) && binsof(opcode_cp.add_sub);

		bins max_neg_add_or_mult =
         binsof(operand2_cp.max_neg) && binsof(opcode_cp.add_mult);

		bins max_neg_mult_or_sub =
         binsof(operand2_cp.max_neg) && binsof(opcode_cp.mult_sub);
      }


    endgroup

    function new();
      CovCode = new();
    endfunction

  endclass : Transaction

endpackage : testing_pkg
