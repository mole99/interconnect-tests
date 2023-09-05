`timescale 1ns / 1ps

module top;

	reg clk = 1'b0;
	reg resetn;
    wire trap;

	wire mem_valid;
	wire mem_instr;
	reg  mem_ready;

	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [ 3:0] mem_wstrb;
	reg  [31:0] mem_rdata;
    
	wire        mem_la_read;
	wire        mem_la_write;
	wire [31:0] mem_la_addr;
	wire [31:0] mem_la_wdata;
	wire [ 3:0] mem_la_wstrb;
	
	wire        pcpi_valid;
	wire [31:0] pcpi_insn;
	wire     [31:0] pcpi_rs1;
	wire     [31:0] pcpi_rs2;
	reg             pcpi_wr  = '0;
	reg      [31:0] pcpi_rd = '0;
	reg             pcpi_wait = '0;
	reg             pcpi_ready = '0;
	
	reg      [31:0] irq = '0;
	wire [31:0] eoi;
	
	wire        trace_valid;
	wire [35:0] trace_data;
	
	//wire test;
	//assign test = trap ^ mem_valid ^ mem_ready ^ (^mem_addr) ^ (^mem_wdata) ^ (^mem_wstrb) ^ mem_la_read ^ mem_la_write ^ (^mem_la_addr) ^ (^mem_la_wdata) ^ (^mem_la_wstrb) ^ pcpi_valid ^ (^pcpi_insn) ^ (^pcpi_rs1) ^ (^pcpi_rs2) ^ (^eoi) ^ trace_valid ^ (^trace_data);
    
    picorv32 picorv32_inst (
    `ifdef USE_POWER_PINS
        .vccd1(1'b1),	// User area 1 1.8V supply
        .vssd1(1'b0),	// User area 1 digital ground
    `endif
    
        .clk    (clk),
        .resetn (resetn),
        .trap   (trap),

        .mem_valid (mem_valid),
        .mem_instr (mem_instr),
        .mem_ready (mem_ready),

        .mem_addr  (mem_addr),
        .mem_wdata (mem_wdata),
        .mem_wstrb (mem_wstrb),
        .mem_rdata (mem_rdata),

	    // Look-Ahead Interface
        .mem_la_read  (mem_la_read),
        .mem_la_write (mem_la_write),
        .mem_la_addr  (mem_la_addr),
        .mem_la_wdata (mem_la_wdata),
        .mem_la_wstrb (mem_la_wstrb),

	    // Pico Co-Processor Interface (PCPI)
        .pcpi_valid (pcpi_valid),
        .pcpi_insn  (pcpi_insn),
        .pcpi_rs1   (pcpi_rs1),
        .pcpi_rs2   (pcpi_rs2),
        .pcpi_wr    (pcpi_wr),
        .pcpi_rd    (pcpi_rd),
        .pcpi_wait  (pcpi_wait),
        .pcpi_ready (pcpi_ready),

	    // IRQ Interface
        .irq        (irq),
        .eoi        (eoi),

	    // Trace Interface
        .trace_valid    (trace_valid),
        .trace_data     (trace_data)
    );
    
    initial begin
        $dumpfile("examples/picorv32/picorv32.vcd");
        $dumpvars(0, top);
        
        $sdf_annotate("examples/picorv32/sdf/picorv32.sdf", picorv32_inst);
    end
    
    always #(1.25) clk = ! clk; // TODO hardened for #(1.5), fails at #(1.25)
    
    reg [31:0] ram [256];
    
    initial $readmemh("examples/picorv32/sw/program.hex", ram);
    
    // Print out the message at 0x100
    always @(posedge clk) begin
        if (mem_valid && !mem_ready) begin
            if (|mem_wstrb && mem_addr == 32'h100) begin
                $write("%c", mem_wdata[7 : 0]);
            end
        end
    end
    
    // RAM
    always @(posedge clk) begin
        mem_ready <= mem_valid;

        if (mem_valid) begin
            if (|mem_wstrb) begin
                if (mem_wstrb[0]) ram[mem_addr[9:2]][ 7: 0] <= mem_wdata[7 : 0];
                if (mem_wstrb[1]) ram[mem_addr[9:2]][15: 8] <= mem_wdata[15: 8];
                if (mem_wstrb[2]) ram[mem_addr[9:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) ram[mem_addr[9:2]][31:24] <= mem_wdata[31:24];
            end else begin
                mem_rdata <= ram[mem_addr[9:2]];
            end
        end
    end
    
    initial begin
        $display("Starting simulation...");
        resetn     <= 1'b0;
        #40;
        resetn      <= 1'b1;
        
        #10000;
        
        #10 
        $display("Ending simulation...");
        $finish;
    end

endmodule
