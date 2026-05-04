package assertions_pkg;

  // Property for assertion 1: a -> ##2 b
  property a_then_b_after_2(clk, rst, test_en, a, b);
    @(posedge clk) disable iff (rst) (test_en && a) |-> ##2 b;
  endproperty


  // Property for assertion 2: (a && b) -> ##[1:3] c
  property a_and_b_then_c_1to3(clk, rst, test_en, a, b, c);
    @(posedge clk) disable iff (rst) 
    $rose(test_en && a && b) |-> ##[1:3] c;
  endproperty

  // Sequence for assertion 3: ##2 !b
  sequence s11b(b);
    ##2 !b;
  endsequence

  property prop_s11b(clk, rst, test_en, b);
    @(posedge clk) disable iff (rst) test_en |-> s11b(b);
  endproperty

  // Property for assertion 4-i: Decoder one-hot
  property decoder_one_hot(clk, rst, decoder_Y);
    @(posedge clk) disable iff (rst) $onehot(decoder_Y);
  endproperty

  // Property for assertion 4-ii: Priority encoder valid
  property priority_encoder_valid(clk, rst, D, valid);
    @(posedge clk) disable iff (rst) (D == 4'b0000) |=> !valid;
  endproperty

endpackage