`default_nettype none
/*
 * TODO
 */

module alu_example_vector (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Input A
    input [3:0] A,

    // Input B
    input [3:0] B,

    // Control signals
    input CTRL0,
    input CTRL1,

    // Result
    output [3:0] C,
    output OVF
);
    reg [4:0] result;
    
    always @(*) begin
        case ({CTRL1, CTRL0})
            2'd0: result = A + B;
            2'd1: result = A - B;
            2'd2: result = A & B;
            2'd3: result = A > B;
        endcase
    end
    
    assign C = result[3:0];
    assign OVF = result[4];

endmodule
`default_nettype wire
