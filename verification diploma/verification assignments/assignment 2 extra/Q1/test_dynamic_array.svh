module data_types_extra;

  // 1) Declare a 2-state array that holds four 12-bit values
  bit [11:0] my_array [0:3];

  initial begin
    // 2) Initialize array
    my_array[0] = 12'h012;
    my_array[1] = 12'h345;
    my_array[2] = 12'h678;
    my_array[3] = 12'h9AB;

    // Print header
    $display("---- Using for loop ----");

    // 3a) Traverse using for loop
    for (int i = 0; i < 4; i++) begin
      $display("my_array[%0d][5:4] = %b", i, my_array[i][5:4]);
    end

    $display("---- Using foreach loop ----");

    // 3b) Traverse using foreach loop
    foreach (my_array[i]) begin
      $display("my_array[%0d][5:4] = %b", i, my_array[i][5:4]);
    end
  end

endmodule
