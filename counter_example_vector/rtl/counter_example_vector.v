`default_nettype none
/*
 * TODO
 */

module counter_example_vector (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Input
    input CLK,
    input RESET,

    // Output
    output [7:0] C
);
    reg [7:0] counter;
    
    always @(posedge CLK, posedge RESET) begin
        if (RESET == 1'b1) begin
            counter <= '0;
        end else begin
            counter <= counter + 8'd1;
        end
    end
    
    assign C = counter;

endmodule
`default_nettype wire
