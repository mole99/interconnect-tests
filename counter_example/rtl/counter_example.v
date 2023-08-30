`default_nettype none
/*
 * A simple 8-bit counter
 * - It can be reset asynchronously via RESET
 * - Loaded with a new value via LOAD and VALUE
 * - And counts upon a rising edge of CLK
 */

module counter_example (
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Input
    input CLK,
    input RESET,
    input LOAD,
    input [7:0] VALUE,

    // Output
    output [7:0] C
);
    reg [7:0] counter;
    
    always @(posedge CLK, posedge RESET) begin
        if (RESET == 1'b1) begin
            counter <= '0;
        end else begin
            if (LOAD) begin
                counter <= VALUE;
            end else begin
                counter <= counter + 8'd1;
            end
        end
    end
    
    assign C = counter;

endmodule
`default_nettype wire
