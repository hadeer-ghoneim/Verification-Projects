module tb;

initial begin
    integer a, res;

    a = 2;

    $display("Before calling fn: a=%0d res=%0d", a, res);

    res = fn(a);

    $display("After calling fn: a=%0d res=%0d", a, res);

    $finish;
end

function int fn(int a);
    a = a + 5;
    return a * 10;
endfunction

endmodule
