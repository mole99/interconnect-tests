`timescale 1ns / 1ps

module top;

    reg CLK = 1'b0;
    reg RESET = 1'b1;
    reg LOAD = 1'b0;
    reg [7:0] VALUE = 8'b0;
    wire [7:0] C;
    
    counter counter_inst (
    `ifdef USE_POWER_PINS
        .vccd1(1'b1),	// User area 1 1.8V supply
        .vssd1(1'b0),	// User area 1 digital ground
    `endif
    
        .CLK    (CLK),
        .RESET  (RESET),
        
        .LOAD   (LOAD),
        .VALUE  (VALUE),
        
        .C      (C)
    );
    
    initial begin
        $dumpfile("examples/counter/counter.vcd");
        $dumpvars(0, top);
        
        $sdf_annotate("examples/counter/sdf/counter.sdf", counter_inst);
    end
    
    always #10 CLK = ! CLK;
    
    initial begin
        #40;
        
        RESET = 1'b0;
        
        #500;
        
        VALUE = 8'd42;
        LOAD = 1'b1;

        #40;

        LOAD = 1'b0;
        
        #500;
        
        #10 $finish;
    end

endmodule
