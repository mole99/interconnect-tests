`timescale 1ns / 1ps

module top;

    reg CLK = 1'b0;
    reg RESET = 1'b1;
    reg [1:0] CTRL;
    wire [7:0] C;
    
    counter_example_vector counter_example_vector_inst (
    `ifdef USE_POWER_PINS
        .vccd1(1'b1),	// User area 1 1.8V supply
        .vssd1(1'b0),	// User area 1 digital ground
    `endif
    
        .CLK    (CLK),
        .RESET  (RESET),
        
        .C (C)
    );
    
    initial begin
        $dumpfile("counter_example_vector.vcd");
        $dumpvars(0, top);
        
        $sdf_annotate("counter_example_vector/sdf/counter_example_vector.sdf", counter_example_vector_inst);
    end
    
    always #10 CLK = ! CLK;
    
    initial begin
        #40;
        
        RESET = 1'b0;
        
        #1000;
        
        #10 $finish;
    end

endmodule
