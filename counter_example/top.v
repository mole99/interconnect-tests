`timescale 1ns / 1ps

module top;

    reg CLK = 1'b0;
    reg RESET = 1'b1;
    reg [1:0] CTRL;
    wire [7:0] C;
    
    counter_example counter_example_inst (
    `ifdef USE_POWER_PINS
        .vccd1(1'b1),	// User area 1 1.8V supply
        .vssd1(1'b0),	// User area 1 digital ground
    `endif
    
        .CLK    (CLK),
        .RESET  (RESET),
        
        .C0 (C[0]),
        .C1 (C[1]),
        .C2 (C[2]),
        .C3 (C[3]),
        .C4 (C[4]),
        .C5 (C[5]),
        .C6 (C[6]),
        .C7 (C[7])
    );
    
    initial begin
        $dumpfile("counter_example.vcd");
        $dumpvars(0, top);
        
        $sdf_annotate("counter_example/sdf/counter_example.sdf", counter_example_inst);
    end
    
    always #10 CLK = ! CLK;
    
    initial begin
        #40;
        
        RESET = 1'b0;
        
        #1000;
        
        #10 $finish;
    end

endmodule
