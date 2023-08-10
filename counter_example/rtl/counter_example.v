`default_nettype none
/*
 * TODO
 */

module counter_example (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Input
    input CLK,
    input RESET,

    // Output
    output C0,
    output C1,
    output C2,
    output C3,
    output C4,
    output C5,
    output C6,
    output C7,
);
    reg [7:0] counter;
    
    always @(posedge CLK, posedge RESET) begin
        if (RESET == 1'b1) begin
            counter <= '0;
        end else begin
            counter <= counter + 8'd1;
        end
    end
    
    assign C0 = counter[0];
    assign C1 = counter[1];
    assign C2 = counter[2];
    assign C3 = counter[3];
    assign C4 = counter[4];
    assign C5 = counter[5];
    assign C6 = counter[6];
    assign C7 = counter[7];

endmodule
`default_nettype wire
