module ALU (
    input  wire clk,
    input  wire reset,
    input  wire [1:0] Opcode,	    // ALU opcode
    input  wire signed [3:0] A,	// Input A in 2's complement
    input  wire signed [3:0] B,	// Input B in 2's complement
    output reg signed [4:0] C    // Output in 2's complement
);
    // Internal signal to hold result before register
    reg signed [4:0] Alu_out;

    // ALU operation codes
    localparam Add           = 2'b00; // A + B
    localparam Sub           = 2'b01; // A - B
    localparam Not_A         = 2'b10; // ~A
    localparam ReductionOR_B = 2'b11; // |B

    // Combinational ALU logic
    always @(*) begin
        case (Opcode)
            Add:           Alu_out = A + B;     // Addition
            Sub:           Alu_out = A - B;     // Subtraction
            Not_A:         Alu_out = ~A;        // Bitwise NOT of A
            ReductionOR_B: Alu_out = |B;        // Reduction OR of B
            default:       Alu_out = 5'd0;      // Should never happen in testing
        endcase
    end

    // Sequential block to register the output
    always @(posedge clk or posedge reset) begin
        if (reset)
            C <= 5'd0;
        else
            C <= Alu_out;
    end

endmodule
