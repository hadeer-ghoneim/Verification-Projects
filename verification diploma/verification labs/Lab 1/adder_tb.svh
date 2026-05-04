module adder_tb ();

    reg signed [3:0] A_tb, B_tb;
    reg signed [4:0] C_tb;
    bit clk;
    bit rst;
    localparam  MAXPOS = 7;
    localparam  MAXNEG = -8;
    localparam  ZERO = 0 ;
    int error_count; 
    int correct_count;


    adder DUT(clk,rst,A_tb,B_tb,C_tb);

always begin
    #5 clk = ~clk;
end

initial begin
    clk = 0; 
    error_count = 0; 
    correct_count = 0; 

    asser_reset();

     A_tb = MAXPOS ; B_tb = MAXPOS ; check_result(MAXPOS + MAXPOS);
     A_tb = MAXPOS ; B_tb = MAXNEG ; check_result(MAXPOS + MAXNEG);
     A_tb = MAXPOS ; B_tb = ZERO ; check_result(MAXPOS + ZERO);

     A_tb = MAXNEG ; B_tb = MAXPOS ; check_result(MAXNEG + MAXPOS);
     A_tb = MAXNEG ; B_tb = MAXNEG ; check_result(MAXNEG + MAXNEG);
     A_tb = MAXNEG ; B_tb = ZERO ; check_result(MAXNEG + ZERO);

     A_tb = ZERO ; B_tb = MAXPOS ; check_result(ZERO + MAXPOS);
     A_tb = ZERO ; B_tb = MAXNEG ; check_result(ZERO + MAXNEG);
     A_tb = ZERO ; B_tb = ZERO ; check_result(ZERO + ZERO);

     //extra check to achieve 100% coverage
     //Add more test vectors 
     A_tb = 0 ; B_tb = 1 ; check_result(1);
     A_tb = 1 ; B_tb = 2 ; check_result(3);
     A_tb = 1 ; B_tb = 7 ; check_result(8);
     A_tb = 5 ; B_tb = 4 ; check_result(9);

     $stop;

end

task asser_reset ();
    A_tb = 0 ; B_tb = 0;
    C_tb = 0; rst =0;
    check_result(0);
 @(negedge clk);
    A_tb = 0 ; B_tb = 0;
    rst =1;
    check_result(0);
    rst =0;
endtask


task check_result(input signed [4:0]sum);
 @(negedge clk);

    if(C_tb != sum)
        error_count = error_count + 1;
    else
        correct_count = correct_count +1;
endtask

endmodule
