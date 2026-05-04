module DSP_tb();

  reg clk = 0;
  reg rst_n;
  reg [17:0] A, B, D;
  reg [47:0] C;
  wire [47:0] P_TB;

  localparam  MAXPOS = 7;
  localparam  MAXNEG = -8;
  localparam  ZERO = 0 ;
  int error_count; 
  int correct_count;

    DSP #(.OPERATION("ADD")) DUT_DSP (
      .clk(clk),
      .rst_n(rst_n),
      .A(A), .B(B), .D(D), .C(C),
      .P(P_TB)
    );
 
    always begin
        #5 clk = ~clk;
    end

    integer i;
    initial begin

        clk = 0; 
        error_count = 0; 
        correct_count = 0; 
        A = 0; B = 0; D = 0; C = 0;
        

        //COUNTER_1
        asser_reset();

        //COUNTER_2
        for(i=0; i<99; i=i+1)begin
            A = $random; 
            B = $random;
            D = $random;
            C = $random;
            check_result(A,B,D,C);
        end
        $display("error_count = %d , correct_count = %d " , error_count , correct_count);
        $stop();

    end

    task asser_reset ();
        A=0; B=0; C=0; D=0;
        rst_n =1;
        check_result(0);
    @(negedge clk);
        A=0; B=0; C=0; D=0;
        rst_n =0;
        check_result(0);
        rst_n =1;
    endtask

    function [47:0] golden (input [17:0] a, input [17:0]
    b, input [17:0] d, input [47:0] c);
    reg [17:0] pre_add;
    reg [47:0] mult_result;
    begin
    pre_add = d + b; 
    mult_result = a * pre_add;
    golden = mult_result + c;
    end
    endfunction

    task check_result;
    input [17:0] a_val , b_val , d_val;
    input [47:0] c_val;
    input [47:0] expected_out;
    begin
        #1
        golden(a_val,b_val,d_val,c_val);

           if(P_TB != expected_out)
            error_count = error_count + 1;
        else
            correct_count = correct_count +1;
    end
    endtask

endmodule