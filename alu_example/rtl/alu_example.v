`default_nettype none
/*
 * TODO
 */

module alu_example (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Input A
    input A0,
    input A1,
    input A2,
    input A3,

    // Input B
    input B0,
    input B1,
    input B2,
    input B3,

    // Control signals
    input CTRL0,
    input CTRL1,

    // Result
    output C0,
    output C1,
    output C2,
    output C3,
);
    wire [3:0] A, B;
    reg [3:0] C;
    
    assign A = {A3, A2, A1, A0};
    assign B = {B3, B2, B1, B0};
    
    always @(*) begin
        case ({CTRL1, CTRL0})
            2'd0: C = A + B;
            2'd1: C = A - B;
            2'd2: C = A & B;
            2'd3: C = A > B;
        endcase
    end
    
    assign C0 = C[0];
    assign C1 = C[1];
    assign C2 = C[2];
    assign C3 = C[3];

endmodule
`default_nettype wire
