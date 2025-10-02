
module RAM32X140_WRAPPER(/*AUTOARG*/
   // Outputs
   QB_F, SINGLE_ERR_B, DOUBLE_ERR_B,
   // Inputs
   w_clk, r_clk, w_nrst, r_nrst, AA_F, CSA_F, WEA_F, DA_F, CSB_F,reg_dft_tpram_config,
   REB_F, AB_F, BYPASS_WRITE_A, CHECK_IN_A, BYPASS_READ_B
   );

parameter ADDR_WIDTH = 8;
parameter DATA_WIDTH = 64;
parameter RAM_DEPTH = 1<<ADDR_WIDTH;
parameter RAM_PIPE_STAGE = 1;
parameter PARITY_WIDTH = 8;
parameter PHY_DATA_WIDTH = PARITY_WIDTH + DATA_WIDTH;
parameter PHY_AL_DATA_WIDTH = PARITY_WIDTH + DATA_WIDTH;
parameter PHY_ADDR_WIDTH = ADDR_WIDTH;

//----------------------------------------------------
input                                w_clk;
input                                r_clk;
input                                w_nrst;
input                                r_nrst;
input  [8:0]						 reg_dft_tpram_config;

output [(DATA_WIDTH-1):0]            QB_F;

input  [(ADDR_WIDTH-1):0]            AA_F;
input                                CSA_F;
input                                WEA_F;
input  [(DATA_WIDTH-1):0]            DA_F;

input                                CSB_F;
input                                REB_F;
input  [(ADDR_WIDTH-1):0]            AB_F;

input                                BYPASS_WRITE_A;
input                                CHECK_IN_A;
input                                BYPASS_READ_B;
output                               SINGLE_ERR_B;
output                               DOUBLE_ERR_B;

wire   [(PHY_ADDR_WIDTH-1):0]        AA_w;
wire                                 CSA_w0;
wire                                 WEA_w0;
wire   [(DATA_WIDTH-1):0]            DA_w;

wire                                 CSB_w0;
wire                                 REB_w0;
wire   [(PHY_ADDR_WIDTH-1):0]        AB_w;
wire                                 BYPASS_READ_B_w;

wire   [(DATA_WIDTH-1):0]            QB_F;
wire   [(PHY_AL_DATA_WIDTH-1):0]     QB_p0;
wire   [(PHY_AL_DATA_WIDTH-1):0]     QB_p_tmp0;

wire   [(PHY_AL_DATA_WIDTH-1):0]     QB_t;
wire   [(PHY_AL_DATA_WIDTH-1):0]     QB_y;
wire   [(DATA_WIDTH-1) : 0 ]         QB_u;

wire                                 SINGLE_ERR_B;
wire   [0:0]                         SINGLE_ERR_B_r0;
wire                                 SINGLE_ERR_B_t;

wire                                 DOUBLE_ERR_B;
wire   [0:0]                         DOUBLE_ERR_B_r0;
wire                                 DOUBLE_ERR_B_t;
wire   [(PARITY_WIDTH-1):0]          parity_out ;

wire   [(PHY_AL_DATA_WIDTH-DATA_WIDTH-1):0] QB_p_nc0;

assign QB_p_nc0 = QB_p0[(PHY_AL_DATA_WIDTH-1):DATA_WIDTH];


wire                                 BYPASS_WRITE_A_nc;
wire   [0:0]                         CHECK_IN_A_nc;

assign BYPASS_WRITE_A_nc = BYPASS_WRITE_A;
assign CHECK_IN_A_nc     = CHECK_IN_A;


wire rd_val;
wire rd_val_d1;

assign rd_val= CSB_F&REB_F&((!(CSA_F&WEA_F))||(CSA_F&WEA_F&(AA_F!=AB_F)));

bus_delay_cg #(
    .DELAY_CYCLES ( 1         ),
    .BUS_WIDTH    ( 1         )
)bus_delay_cg_u999 (
    .clk          ( r_clk     ),
    .rst_n        ( w_nrst    ),
    .en           ( 1'b1      ),
    .inbus        ( rd_val    ),
    .outbus       ( rd_val_d1 )
);

assign BYPASS_READ_B_w = BYPASS_READ_B;
assign AA_w[(ADDR_WIDTH-1):0] = AA_F[(ADDR_WIDTH-1):0];
assign CSA_w0 = CSA_F;
assign WEA_w0 = WEA_F;
assign AB_w[(ADDR_WIDTH-1):0] = AB_F[(ADDR_WIDTH-1):0];
assign REB_w0 = REB_F;
assign CSB_w0 = CSB_F;
assign QB_t = QB_p_tmp0;
assign SINGLE_ERR_B_t = (SINGLE_ERR_B_r0) & rd_val_d1;
assign DOUBLE_ERR_B_t = (DOUBLE_ERR_B_r0) & rd_val_d1;

bus_delay_cg #(
    .DELAY_CYCLES ( 1              ),
    .BUS_WIDTH    ( 1              )
)bus_delay_cg_u4 (
    .clk          ( r_clk          ),
    .rst_n        ( r_nrst         ),
    .en           ( 1'b1           ),
    .inbus        ( SINGLE_ERR_B_t ),
    .outbus       ( SINGLE_ERR_B   )
);

bus_delay_cg #(
    .DELAY_CYCLES ( 1              ),
    .BUS_WIDTH    ( 1              )
)bus_delay_cg_u10 (
    .clk          ( r_clk          ),
    .rst_n        ( r_nrst         ),
    .en           ( 1'b1           ),
    .inbus        ( DOUBLE_ERR_B_t ),
    .outbus       ( DOUBLE_ERR_B   )
);


wire  [(PHY_AL_DATA_WIDTH-1):0]  DA_p_tmp;
wire                             BYPASS_READ_B_p;

assign DA_p_tmp[(DATA_WIDTH-1):0] = DA_w;
assign BYPASS_READ_B_p = BYPASS_READ_B_w;

assign DA_w[DATA_WIDTH-1 :0] =DA_F;
assign DA_p_tmp[(PHY_AL_DATA_WIDTH-1):DATA_WIDTH] = parity_out;

ecc_140_top #(
  .DATA_WIDTH   ( DATA_WIDTH                     ),
  .PARITY_WIDTH ( PARITY_WIDTH                   )
)ecc_top_encode_u (
    .data_in    ( DA_p_tmp[(DATA_WIDTH-1):0]     ),
    .data_out   (                                ),
    .parity_in  ( {(PARITY_WIDTH){1'b0}}         ),
    .parity_out ( parity_out[(PARITY_WIDTH-1):0] ),
    .bypass     ( BYPASS_READ_B_p                ),
    .sbit_err   (                                ),
    .dbit_err   (                                )
);

ecc_140_top #(
  .DATA_WIDTH   ( DATA_WIDTH                                   ),
  .PARITY_WIDTH ( PARITY_WIDTH                                 )
)ecc_top_decode_u (
    .data_in    ( QB_y[(DATA_WIDTH-1):0]                       ),
    .data_out   ( QB_u[(DATA_WIDTH-1):0]                       ),
    .parity_in  ( QB_y[(DATA_WIDTH+PARITY_WIDTH-1):DATA_WIDTH] ),
    .parity_out (                                              ),
    .bypass     ( BYPASS_READ_B_p                              ),
    .sbit_err   ( SINGLE_ERR_B_r0                              ),
    .dbit_err   ( DOUBLE_ERR_B_r0                              )
);

assign QB_y [(PHY_AL_DATA_WIDTH-1):0]= QB_t[(PHY_AL_DATA_WIDTH-1):0]; 

bus_delay_cg #(
    .DELAY_CYCLES ( 1                      ),
    .BUS_WIDTH    ( DATA_WIDTH             )
)bus_delay_cg_u3 (
    .clk          ( r_clk                  ),
    .rst_n        ( r_nrst                 ),
    .en           ( 1'b1                   ),
    .inbus        ( QB_u[(DATA_WIDTH)-1:0] ),
    .outbus       ( QB_F[(DATA_WIDTH)-1:0] )
);

wire   [(PHY_ADDR_WIDTH-1):0]        AA_p00;
wire                                 CSA_p00;
wire                                 WEA_p00;
wire   [(PHY_AL_DATA_WIDTH-1):0]     DA_p00;
wire   [(PHY_ADDR_WIDTH-1):0]        AB_p00;
wire                                 CSB_p00;
wire                                 REB_p00;

assign DA_p00 = DA_p_tmp;
assign {AA_p00, CSA_p00,WEA_p00, AB_p00,CSB_p00, REB_p00} = {AA_w, CSA_w0,WEA_w0, AB_w,CSB_w0, REB_w0};
assign QB_p_tmp0[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)] = QB_p0[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)];


 TPSRAM32X149LVTBW0M8B4R1P1_I0O0 #(
    .ADDR_WIDTH ( ADDR_WIDTH                                 ),
    .DATA_WIDTH ( PHY_DATA_WIDTH                             ),
    .MEM_DEPTH  ( RAM_DEPTH                                  )
)u_sram_wrapper (
    .TPRAM_CONFIG( reg_dft_tpram_config  ),
    .Q			( QB_p0[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)]  ),
    .ClkA		( w_clk                                           ),
    .ClkB  		( r_clk                                           ),
    .CEAB   	( CSA_p00                                         ),
    .WEAB   	( WEA_p00                                         ),
    .AddrA		( AA_p00                                          ),
    .Din  		( DA_p00[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)] ),
    .CEBB   	( CSB_p00                                         ),
    .REBB   	( REB_p00                                         ),
    .AddrB		( AB_p00                                          )
);

endmodule

