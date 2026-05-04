import shared_pkg::*;
`define reset disable iff(rst)
module ALSU_sva(A, B, cin, serial_in, red_op_A, red_op_B, opcode, bypass_A, bypass_B, clk, rst, direction, leds, out);
input bit clk;
input logic rst, cin, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
input [2:0] opcode;
input logic signed [2:0] A, B;
input logic [15:0] leds;
input logic [5:0] out;
////////////////////////////////////////////////////////
// this variable to make writing assertion more easer //
////////////////////////////////////////////////////////
bit isBypass, InvalidOP, bitwise;
assign isBypass = bypass_A | bypass_B;
assign InvalidOP = opcode==6 | opcode==7;
assign bitwise = opcode==0 | opcode==1;
assign isRed = red_op_B | red_op_A;

///////////////////////////////////
// assertion of bypass operation //
///////////////////////////////////
bypass_A_assert: assert property (@(posedge clk) `reset bypass_A |-> ##2 out==$past(A,2)); 
bypass_B_assert: assert property (@(posedge clk) `reset (bypass_B && !bypass_A) |-> ##2 out==$past(B,2));

//////////////////////////////////////
// assertion of reduction operation //
//////////////////////////////////////
sequence redValid(red, op,red2);
    (red && !isBypass && opcode==op && !red2);
endsequence

redA_OR_assert: assert property (@(posedge clk) `reset redValid(red_op_A,0,0)        |-> ##2 out==|($past(A,2)));
redB_OR_assert: assert property (@(posedge clk) `reset redValid(red_op_B,0,red_op_A) |-> ##2 out==|($past(B,2)));

redA_XR_assert: assert property (@(posedge clk) `reset redValid(red_op_A,1,0)        |-> ##2 out==^($past(A,2)));
redB_XR_assert: assert property (@(posedge clk) `reset redValid(red_op_B,1,red_op_A) |-> ##2 out==^($past(B,2)));

////////////////////////////////
// assertion of invalid cases //
////////////////////////////////
sequence Invalid_seq;
    ((isRed && !isBypass && !bitwise) || (InvalidOP && !isBypass));
endsequence

Invalid_assert: assert property (@(posedge clk) `reset Invalid_seq |-> ##[0:2](out==0 && leds=='hffff));

////////////////////////////////////////
// assertion when opcode always valid //
////////////////////////////////////////

always_comb begin : assert_alwaysValid
  if (alwaysValid) begin
    alwValid_opcode_assert:  assert final (!InvalidOP);
    alwZero_bypass_A_assert: assert final (!bypass_A);
    alwZero_bypass_B_assert: assert final (!bypass_B);
    alwZero_red_op_A_assert: assert final (!red_op_A);
    alwZero_red_op_B_assert: assert final (!red_op_B);
  end
end

/////////////////////
// reset assertion //
/////////////////////
always_comb begin : reset_assertion
    if (rst) begin
        rst_out_assert: assert final (out==0);
        rst_leds_assert: assert final (leds==0);
    end
end

//////////////////////////////////////////////////////////////////
// assertion for opcode Valid cases without bypass or reduction //
//////////////////////////////////////////////////////////////////
sequence sh_ro(op, dir);
    (opcode==op && dir && !isRed && !isBypass);
endsequence
sequence op_assert(op);
  (!isBypass && !isRed && opcode==op);
endsequence
  
OR_assert:   assert property (@(posedge clk) `reset op_assert(0) |-> ##2  out== $past(A,2) | $past(B,2) );
XOR_assert:  assert property (@(posedge clk) `reset op_assert(1) |-> ##2  out==($past(A,2)^$past(B,2)) );
add_assert:  assert property (@(posedge clk) `reset op_assert(2) |-> ##2  out==($past(A,2)+$past(B,2)+$past(cin,2)) );
mult_assert: assert property (@(posedge clk) `reset op_assert(3) |-> ##2  out==($past(A,2)*$past(B,2)) );

shiftL_assert: assert property (@(posedge clk) `reset sh_ro(4, direction) |-> ##2  out=={$past(out[4:0]), $past(serial_in,2)} ); 
shiftR_assert: assert property (@(posedge clk) `reset sh_ro(4, !direction) |-> ##2  out=={$past(serial_in,2), $past(out[5:1])} ); 

rotateL_assert: assert property (@(posedge clk) `reset sh_ro(5, direction) |-> ##2  out=={$past(out[4:0]), $past(out[5])} ); 
rotateR_assert: assert property (@(posedge clk) `reset sh_ro(5, !direction) |-> ##2  out=={$past(out[0]), $past(out[5:1])} );

/////////////////////////////////////////////////////////////////////////////
//////////////////////////          cover          //////////////////////////
/////////////////////////////////////////////////////////////////////////////

///////////////////////////////
// cover of bypass operation //
///////////////////////////////
bypass_A_cover: cover property (@(posedge clk) `reset bypass_A |-> ##2 out==$past(A,2)); 
bypass_B_cover: cover property (@(posedge clk) `reset (bypass_B && !bypass_A) |-> ##2 out==$past(B,2));

//////////////////////////////////
// cover of reduction operation //
//////////////////////////////////

redA_OR_cover: cover property (@(posedge clk) `reset redValid(red_op_A,0,0)        |-> ##2 out==|($past(A,2)));
redB_OR_cover: cover property (@(posedge clk) `reset redValid(red_op_B,0,red_op_A) |-> ##2 out==|($past(B,2)));

redA_XR_cover: cover property (@(posedge clk) `reset redValid(red_op_A,1,0)        |-> ##2 out==^($past(A,2)));
redB_XR_cover: cover property (@(posedge clk) `reset redValid(red_op_B,1,red_op_A) |-> ##2 out==^($past(B,2)));

////////////////////////////
// cover of invalid cases //
////////////////////////////
Invalid_cover: cover property (@(posedge clk) `reset Invalid_seq |-> ##[0:2](out==0 && leds=='hffff));

////////////////////////////////////
// cover when opcode always valid //
////////////////////////////////////

always_comb begin : cover_alwaysValid
  if (alwaysValid) begin
    alwValid_opcode_cover:  cover final (!InvalidOP);
    alwZero_bypass_A_cover: cover final (!bypass_A);
    alwZero_bypass_B_cover: cover final (!bypass_B);
    alwZero_red_op_A_cover: cover final (!red_op_A);
    alwZero_red_op_B_cover: cover final (!red_op_B);
  end
end

/////////////////
// reset cover //
/////////////////
always_comb begin : reset_cover
    if (rst) begin
        rst_out_cover: cover final (out==0);
        rst_leds_cover: cover final (leds==0);
    end
end

//////////////////////////////////////////////////////////////
// cover for opcode Valid cases without bypass or reduction //
//////////////////////////////////////////////////////////////
  
OR_cover:   cover property (@(posedge clk) `reset op_assert(0) |-> ##2  out== $past(A,2) | $past(B,2) );
XOR_cover:  cover property (@(posedge clk) `reset op_assert(1) |-> ##2  out==($past(A,2) ^ $past(B,2)) );
add_cover:  cover property (@(posedge clk) `reset op_assert(2) |-> ##2  out==($past(A,2) + $past(B,2) + $past(cin,2)) );
mult_cover: cover property (@(posedge clk) `reset op_assert(3) |-> ##2  out==($past(A,2) * $past(B,2)) );

shiftL_cover: cover property (@(posedge clk) `reset sh_ro(4, direction) |-> ##2  out=={$past(out[4:0]), $past(serial_in,2)} ); 
shiftR_cover: cover property (@(posedge clk) `reset sh_ro(4, !direction) |-> ##2  out=={$past(serial_in,2), $past(out[5:1])} ); 

rotateL_cover: cover property (@(posedge clk) `reset sh_ro(5, direction) |-> ##2  out=={$past(out[4:0]), $past(out[5])} ); 
rotateR_cover: cover property (@(posedge clk) `reset sh_ro(5, !direction) |-> ##2  out=={$past(out[0]), $past(out[5:1])} );
endmodule