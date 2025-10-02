
///sram wrap generated

module TPSRAM1024X75SVTBW0M8B4R1P0_I0O0 #(
    parameter MEM_DEPTH   =1024,
    parameter ADDR_WIDTH  =10,
    parameter DATA_WIDTH  =75
)(
    input                          ClkA,
    input                          ClkB,
    input       [ADDR_WIDTH-1:0]   AddrA,
    input       [ADDR_WIDTH-1:0]   AddrB,
    input       [DATA_WIDTH-1:0]   Din,
    input       [8:0]   TPRAM_CONFIG,
    input                          CEAB,
    input                          CEBB,
    input                          WEAB,
    input                          REBB,
    output      [DATA_WIDTH-1:0]   Q
);

//signals define
wire [DATA_WIDTH-1:0]   Mem_Q;

//memory instance define
`ifdef SIM
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

   `else 
         `ifdef TSMC_6NM_6T_LVT
            TPSRAM1024X75SVTBW0M8B4R1P0   u0_tpsram (
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
         `elsif UMC_28HPC_ARMMEM
            tprf_1024x75   u0_tpsram (
              .CLKA       (ClkB),
              .CLKB       (ClkA),
              .AA         (AddrB),
              .AB         (AddrA),
              .DB         (Din),
              .CENA        (CEBB || REBB),
              .CENB        (CEAB || WEAB),
              .EMAA        (TPRAM_CONFIG[2:0]),
              .EMAB        (TPRAM_CONFIG[5:3]),
              .EMASA       (TPRAM_CONFIG[6]),
              .RET1N       (TPRAM_CONFIG[7]),
              .COLLDISN    (TPRAM_CONFIG[8]),
              .TENA        (1'b1),
              .TCENA       (1'b1),
              .TAA         ({ADDR_WIDTH{1'b0}}),
              .TENB        (1'b1),
              .TCENB       (1'b1),
              .TDB         ({DATA_WIDTH{1'b0}}),
              .SIA         (2'b0),
              .SEA         (1'b0),
              .SIB         (2'b0),
              .SEB         (1'b0),
              .DFTRAMBYP   (1'b0),
              .CENYA    (),
              .AYA      (),
              .CENYB    (),
              .AYB      (),
              .SOA      (),
              .SOB      (),
              .QA      (Mem_Q)
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

//output 0 pipeline
assign Q = Mem_Q;

endmodule
