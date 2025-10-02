
//IDI DPSRAM
// No PIPELine Delay for readdata Q out.
module TPSRAM2048X149SVTBW0M8B4R1P0_I0O0_WRAPPER #(
    parameter MEM_DEPTH   =2048,
    parameter ADDR_WIDTH  =11,
    parameter DATA_WIDTH  =149
)(
    input							ClkA,
    input                          	ClkB,
    input       [ADDR_WIDTH-1:0]   	AddrA,
    input       [ADDR_WIDTH-1:0]   	AddrB,
    input       [DATA_WIDTH-1:0]   	Din,
    input       [8:0]				TPRAM_CONFIG,
    input							CEAB,
    input                          	CEBB,
    input                          	WEAB,
    input                          	REBB,
    output      [DATA_WIDTH-1:0]   	Q
);


wire           ren_sel_bank1;
wire           wen_sel_bank1;
wire           ren_sel_bank0;
wire           wen_sel_bank0;
wire  [148:0]  Q_pre0;
wire  [148:0]  Q_pre1;

reg            ren_sel_bank1_dly;
//=========================================================
// Extend both data width and address width.
// address decode logic 
//=========================================================
assign   ren_sel_bank1  = ~AddrB[10];
assign   wen_sel_bank1  = ~AddrA[10];
assign   ren_sel_bank0  = AddrB[10];
assign   wen_sel_bank0  = AddrA[10];

//no pipiline for the memory output,so it is safety to delay read enable signal
//for reading data mux, if exist the pipiline for the memory output,need to extend the pipeline for
//read enable signal.
always @(posedge ClkB ) begin //no need reset port, just pipeline the read enable signal
      ren_sel_bank1_dly <= ren_sel_bank0; 
end
assign idi_mem_rdata = ren_sel_bank1_dly ? Q_pre1 : Q_pre0;

/* TPSRAM1024X68SVTBW0M8B4R1P0_I0O0 AUTO_TEMPLATE "\(.$\)" (
    .ClkA(ClkA),
    .ClkB(ClkB),
    .AddrA(AddrA[9:0]),
    .AddrB(AddrB[9:0]),
    .Din(Din[67:0]),
    .CEAB(wen_sel_bank@),
    .CEBB(ren_sel_bank@),
    .WEAB(WEAB),
    .REBB(REBB),
    .TPRAM_CONFIG(TPRAM_CONFIG),
    .Q(Q_pre@[67:0]), 
 );
*/
/* TPSRAM1024X69SVTBW0M8B4R1P0_I0O0 AUTO_TEMPLATE "\(.$\)" (
    .ClkA(ClkA),
    .ClkB(ClkB),
    .AddrA(AddrA[9:0]),
    .AddrB(AddrB[9:0]),
    .Din(Din[136:68]),
    .CEAB(wen_sel_bank@),
    .CEBB(ren_sel_bank@),
    .WEAB(WEAB),
    .REBB(REBB),
    .TPRAM_CONFIG(TPRAM_CONFIG),
    .Q(Q_pre@[136:68]), 
 ),
*/
TPSRAM1024X74SVTBW0M8B4R1P0_I0O0 u_sram_00 (/*AUTOINST*/
					    // Outputs
					    .Q			(Q_pre0[73:0]),	 // Templated
					    // Inputs
					    .ClkA		(ClkA),		 // Templated
					    .ClkB		(ClkB),		 // Templated
					    .AddrA		(AddrA[9:0]),	 // Templated
					    .AddrB		(AddrB[9:0]),	 // Templated
					    .Din		(Din[73:0]),	 // Templated
					    .TPRAM_CONFIG	(TPRAM_CONFIG), // Templated
					    .CEAB		(wen_sel_bank0), // Templated
					    .CEBB		(ren_sel_bank0), // Templated
					    .WEAB		(WEAB),		 // Templated
					    .REBB		(REBB));		 // Templated
TPSRAM1024X75SVTBW0M8B4R1P0_I0O0 u_sram_10 (/*AUTOINST*/
					    // Outputs
					    .Q			(Q_pre0[148:74]), // Templated
					    // Inputs
					    .ClkA		(ClkA),		 // Templated
					    .ClkB		(ClkB),		 // Templated
					    .AddrA		(AddrA[9:0]),	 // Templated
					    .AddrB		(AddrB[9:0]),	 // Templated
					    .Din		(Din[148:74]),	 // Templated
					    .TPRAM_CONFIG	(TPRAM_CONFIG), // Templated
					    .CEAB		(wen_sel_bank0), // Templated
					    .CEBB		(ren_sel_bank0), // Templated
					    .WEAB		(WEAB),		 // Templated
					    .REBB		(REBB));		 // Templated

TPSRAM1024X74SVTBW0M8B4R1P0_I0O0 u_sram_01 (/*AUTOINST*/
					    // Outputs
					    .Q			(Q_pre1[73:0]),	 // Templated
					    // Inputs
					    .ClkA		(ClkA),		 // Templated
					    .ClkB		(ClkB),		 // Templated
					    .AddrA		(AddrA[9:0]),	 // Templated
					    .AddrB		(AddrB[9:0]),	 // Templated
					    .Din		(Din[73:0]),	 // Templated
					    .TPRAM_CONFIG	(TPRAM_CONFIG), // Templated
					    .CEAB		(wen_sel_bank1), // Templated
					    .CEBB		(ren_sel_bank1), // Templated
					    .WEAB		(WEAB),		 // Templated
					    .REBB		(REBB));		 // Templated
TPSRAM1024X75SVTBW0M8B4R1P0_I0O0 u_sram_11 (/*AUTOINST*/
					    // Outputs
					    .Q			(Q_pre1[148:74]), // Templated
					    // Inputs
					    .ClkA		(ClkA),		 // Templated
					    .ClkB		(ClkB),		 // Templated
					    .AddrA		(AddrA[9:0]),	 // Templated
					    .AddrB		(AddrB[9:0]),	 // Templated
					    .Din		(Din[148:74]),	 // Templated
					    .TPRAM_CONFIG	(TPRAM_CONFIG), // Templated
					    .CEAB		(wen_sel_bank1), // Templated
					    .CEBB		(ren_sel_bank1), // Templated
					    .WEAB		(WEAB),		 // Templated
					    .REBB		(REBB));		 // Templated

endmodule
    // Local Variables:
    // verilog-library-directories:("." "../../DPSRAM")
    // End:

