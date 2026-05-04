module dff_t2_tb();

    reg   d_tb; 
    logic q_tb, q_expected;
    reg en;
    bit clk;
    bit rst;
    int error_count; 
    int correct_count;

    dff #(.USE_EN(0)) DUT_DFF_2 (clk, rst, d_tb, q_tb, en);

    dff_GM #(.USE_EN(0)) DUT_DFF_GM_2 (clk, rst, d_tb, q_expected, en);


    always begin
        #5 clk = ~clk;
    end

    //COUNTER_1
    task asser_reset ();
    @(negedge clk);
        d_tb = 0 ; 
        rst =1;
        check_fun(0);
        rst =0;
    endtask

    //COUNTER_2
    integer i;
    initial begin
        clk = 0; 
        error_count = 0; 
        correct_count = 0; 

        asser_reset();

        for(i=0; i<99; i=i+1)begin
            d_tb = $random; 
            en = $random;
            check_fun(q_expected);
        end

         $stop;

    end

    task check_fun(input q_expected);
    @(negedge clk);
        if(q_tb != q_expected)
            error_count = error_count + 1;
        else
            correct_count = correct_count +1;
    endtask

endmodule