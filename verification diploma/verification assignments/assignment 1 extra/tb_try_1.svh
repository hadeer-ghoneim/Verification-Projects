module tb_try;

    integer a, temp;

    initial begin
        repeat (1000) begin
            temp = $random;  // generate any random number

            // check if number is in [7:21], even and positive
            if ((temp >= 7) && (temp <= 21) && (temp % 2 == 0)) begin
                a = temp;
                $display("a = %0d", a);
            end
        end
    end

endmodule
