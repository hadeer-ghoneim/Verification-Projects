module ALU_tb ();

    reg signed [3:0] A_tb, B_tb;
    logic signed [4:0] C_tb;
    reg [1:0] Opcode;
    bit clk;
    bit rst;
    localparam  MAXPOS = 7;
    localparam  MAXNEG = -8;
    localparam  ZERO = 0 ;
    int error_count; 
    int correct_count;

    ALU DUT_ALU(clk,rst,Opcode,A_tb,B_tb,C_tb);

    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0; 
        error_count = 0; 
        correct_count = 0; 

        //reset
        asser_reset();


        //adder1 & sub1

        A_tb = MAXPOS ; B_tb = MAXPOS ; check_Add(MAXPOS + MAXPOS);
        check_Sub(MAXPOS - MAXPOS); 

        A_tb = MAXPOS ; B_tb = MAXNEG ; check_Add(MAXPOS + MAXNEG);
        check_Sub(MAXPOS - MAXNEG); 

        A_tb = MAXPOS ; B_tb = ZERO ; check_Add(MAXPOS + ZERO);
        check_Sub(MAXPOS - ZERO); 


        //adder2 & sub2

        A_tb = MAXNEG ; B_tb = MAXPOS ; check_Add(MAXNEG + MAXPOS);
        check_Sub(MAXNEG - MAXPOS);

        A_tb = MAXNEG ; B_tb = MAXNEG ; check_Add(MAXNEG + MAXNEG);
        check_Sub(MAXNEG - MAXNEG);

        A_tb = MAXNEG ; B_tb = ZERO ; check_Add(MAXNEG + ZERO);
        check_Sub(MAXNEG - ZERO);


        //adder3 & sub3

        A_tb = ZERO ; B_tb = MAXPOS ; check_Add(ZERO + MAXPOS);
        check_Sub(ZERO - MAXPOS);

        A_tb = ZERO ; B_tb = MAXNEG ; check_Add(ZERO + MAXNEG);
        check_Sub(ZERO - MAXNEG);

        A_tb = ZERO ; B_tb = ZERO ; check_Add(ZERO + ZERO);
        check_Sub(ZERO - ZERO);


        //adder4 & sub4
        //extra check to achieve 100% coverage
        //Add more test vectors 
        A_tb = 1 ; B_tb = 0 ; check_Add(1); check_Sub(1);
        A_tb = 2 ; B_tb = 1 ; check_Add(3); check_Sub(1);
        A_tb = 7 ; B_tb = 1 ; check_Add(8); check_Sub(6);
        A_tb = 5 ; B_tb = 4 ; check_Add(9); check_Sub(1);

        // reduction or and not A checker1
        A_tb = 4; B_tb = 9;
        check_NotA(~4);          
        check_ReductionOR(|9);


        // reduction or and not A checker2
        A_tb = 6; B_tb = 1;
        check_NotA(~6);          
        check_ReductionOR(|1);


        // Final sweep
        A_tb = 3; B_tb = 2;
        check_Add(3 + 2);
        check_Sub(3 - 2);
        check_NotA(~3);          
        check_ReductionOR(|2);  // reduction OR

        $stop;

    end

    task asser_reset ();
    
        A_tb = 0 ; B_tb = 0; Opcode = 0;
        rst =0;
        check_Add(0); check_Sub(0);
        check_NotA(0); check_ReductionOR(0);
       @(negedge clk);
        A_tb = 0 ; B_tb = 0; Opcode = 0;
        rst =1;
        check_Add(0); check_Sub(0);
        check_NotA(0); check_ReductionOR(0);
        rst =0;

    endtask


    task check_Add(input signed [4:0]sum);

        Opcode = 2'b00; // A + B [Add]
       @(negedge clk);
        if(C_tb != sum)
            error_count = error_count + 1;
        else
            correct_count = correct_count +1;

    endtask


    task check_Sub(input signed [4:0]sub);

       Opcode = 2'b01; // A - B [Sub]
       @(negedge clk);
        if(C_tb != sub)
            error_count = error_count + 1;
        else
            correct_count = correct_count +1;

    endtask


    task check_NotA(input signed [4:0] inv);
        
        Opcode = 2'b10; // NOT A
        @(negedge clk);
        if (C_tb != inv) error_count++;
        else correct_count++;
        
    endtask


    task check_ReductionOR(input signed [4:0] red);

        Opcode = 2'b11; // Reduction OR
        @(negedge clk);
        if (C_tb != red) error_count++;
        else correct_count++;

    endtask


endmodule
