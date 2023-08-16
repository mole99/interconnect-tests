`timescale 1ns / 1ps

module top;

    reg [3:0] A, B;
    reg [1:0] CTRL;
    wire [3:0] C;
    wire OVF;
    
    alu_example_vector alu_example_vector_inst (
    `ifdef USE_POWER_PINS
        .vccd1(1'b1),	// User area 1 1.8V supply
        .vssd1(1'b0),	// User area 1 digital ground
    `endif
    
        .A (A),
        .B (B),
        
        .CTRL0  (CTRL[0]),
        .CTRL1  (CTRL[1]),
        
        .C (C),
        .OVF (OVF)
    );
    
    initial begin
        $dumpfile("alu_example_vector.vcd");
        $dumpvars(0, top);
        
        $sdf_annotate("alu_example_vector/sdf/alu_example_vector.sdf", alu_example_vector_inst);
    end
    
    initial begin
        A   <= 4'd0;
        B   <= 4'd0;
        
        CTRL <= 2'd0;
        
        #10;
        
        A   <= 4'd2;
        B   <= 4'd3;
        
        #10;
        
        CTRL <= 2'd1;
        
        #10;
        
        CTRL <= 2'd2;
        
        #10;
        
        CTRL <= 2'd3;
        
        #10;
        
        A   <= 4'd3;
        B   <= 4'd2;
        
        #10;
        
        A   <= 4'd7;
        B   <= 4'd7;
        
        #10;
        
        A   <= 4'd0;
        B   <= 4'd0;
        
        #10 $finish;
    end

endmodule
