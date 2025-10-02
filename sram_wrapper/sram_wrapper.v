
///sram wrap generated

module sram_wrapper #(
    parameter FLIPFLOP	  =0,
    parameter MEM_DEPTH   =4096,
    parameter ADDR_WIDTH  =12,
    parameter DATA_WIDTH  =64
)(
    input                          ClkA,
    input                          ClkB,
    input       [ADDR_WIDTH-1:0]   AddrA,
    input       [ADDR_WIDTH-1:0]   AddrB,
    input       [DATA_WIDTH-1:0]   Din,
    input                          CEAB,
    input                          CEBB,
    input                          WEAB,
    input                          REBB,
    output      [DATA_WIDTH-1:0]   Q
);

//signals define
wire [DATA_WIDTH-1:0]   Mem_Q;

//memory instance define

generate if(FLIPFLOP==0)
	`ifdef AS6_RTL_SIM
	 tp_sram  #(
	  .MEM_DEPTH (MEM_DEPTH),
	  .ADDR_WIDTH (ADDR_WIDTH),
	  .DATA_WIDTH (DATA_WIDTH)
	 ) u0_tpsram (
	   .clka       (ClkA),
	   .clkb       (ClkB),
	   .addra      (AddrA),
	   .addrb      (AddrB),
	   .din        (Din),
	   .bwab        ({DATA_WIDTH{1'b0}}),
	   .ceab        (CEAB),
	   .cebb        (CEBB),
	   .weab        (WEAB),
	   .rebb        (REBB),
	   .dout      (Mem_Q)
	 );
	`else
	   `ifdef FPGA
			tp_sram  #(
			  .MEM_DEPTH (MEM_DEPTH),
			  .ADDR_WIDTH (ADDR_WIDTH),
			  .DATA_WIDTH (DATA_WIDTH)
			 ) u0_tpsram (
			   .clka       (ClkA),
			   .clkb       (ClkB),
			   .addra      (AddrA),
			   .addrb      (AddrB),
			   .din        (Din),
			   .bwab        ({DATA_WIDTH{1'b0}}),
			   .ceab        (CEAB),
			   .cebb        (CEBB),
			   .weab        (WEAB),
			   .rebb        (REBB),
			   .dout      (Mem_Q)
			 );
	   `else 
	         `ifdef TSMC_6NM_6T_LVT
	            TPSRAM4096X64LVTBW0M8B4R1P1   u0_tpsram (
	              .clka       (ClkA),
	              .clkb       (ClkB),
	              .addra      (AddrA),
	              .addrb      (AddrB),
	              .din       (Din),
	              .ceab        (CEAB),
	              .cebb        (CEBB),
	              .weab        (WEAB),
	              .rebb        (REBB),
	              .dout      (Mem_Q)
	            );
	         `else
	           tp_sram  #(
	            .MEM_DEPTH (MEM_DEPTH),
	            .ADDR_WIDTH (ADDR_WIDTH),
	            .DATA_WIDTH (DATA_WIDTH)
	           ) u0_tpsram (
	             .clka       (ClkA),
	             .clkb       (ClkB),
	             .addra      (AddrA),
	             .addrb      (AddrB),
	             .din       (Din),
	             .bwab        ({DATA_WIDTH{1'b0}}),
	             .ceab        (CEAB),
	             .cebb        (CEBB),
	             .weab        (WEAB),
	             .rebb        (REBB),
	             .dout      (Mem_Q)
	           );
	         `endif
	   `endif
	`endif
else 	 
	tp_sram  #(
	  .MEM_DEPTH (MEM_DEPTH),
	  .ADDR_WIDTH (ADDR_WIDTH),
	  .DATA_WIDTH (DATA_WIDTH)
	 ) u0_tpsram (
	   .clka       (ClkA),
	   .clkb       (ClkB),
	   .addra      (AddrA),
	   .addrb      (AddrB),
	   .din        (Din),
	   .bwab        ({DATA_WIDTH{1'b0}}),
	   .ceab        (CEAB),
	   .cebb        (CEBB),
	   .weab        (WEAB),
	   .rebb        (REBB),
	   .dout      (Mem_Q)
	 );
endgenerate

//output 0 pipeline
assign Q = Mem_Q;

endmodule
