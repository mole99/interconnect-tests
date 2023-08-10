`timescale 1ns / 1ps

module top;

    reg [3:0] A, B;
    reg [1:0] CTRL;
    wire [3:0] C;
    
    alu_example alu_example_inst (
    `ifdef USE_POWER_PINS
        .vccd1(1'b1),	// User area 1 1.8V supply
        .vssd1(1'b0),	// User area 1 digital ground
    `endif
    
        .A0 (A[0]),
        .A1 (A[1]),
        .A2 (A[2]),
        .A3 (A[3]),
        
        .B0 (B[0]),
        .B1 (B[1]),
        .B2 (B[2]),
        .B3 (B[3]),
        
        .CTRL0  (CTRL[0]),
        .CTRL1  (CTRL[1]),
        
        .C0 (C[0]),
        .C1 (C[1]),
        .C2 (C[2]),
        .C3 (C[3])
    );
    
    initial begin
        $dumpfile("alu_example.vcd");
        $dumpvars(0, top);
        
        $sdf_annotate("alu_example/sdf/alu_example.sdf", alu_example_inst);
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
