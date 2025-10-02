
module {module_name}_1r1w_{ram_depth}x{data_width}_ram_wrapper(/*AUTOARG*/
   // Outputs
   QB_F, ECC_FAULT_B, SINGLE_ERR_B, DOUBLE_ERR_B,
   // Inputs
   w_clk, r_clk, w_nrst, r_nrst, AA_F, CSA_F, WEA_F, DA_F, CSB_F,reg_dft_tpram_config,
   ecc_addr_protect_en, ecc_fault_detc_en, REB_F, AB_F, BYPASS_WRITE_A, CHECK_IN_A, BYPASS_READ_B
   );

parameter ADDR_WIDTH        = {addr_width};
parameter DATA_WIDTH        = {data_width};
parameter ADDR_DATA_WIDTH   = ADDR_WIDTH + DATA_WIDTH;
parameter RAM_DEPTH         = 1<<ADDR_WIDTH;
parameter RAM_PIPE_STAGE    = 1;
parameter PARITY_WIDTH      = {parity_width};
parameter PHY_DATA_WIDTH    = PARITY_WIDTH + DATA_WIDTH;
parameter PHY_AL_DATA_WIDTH = PARITY_WIDTH + DATA_WIDTH;
parameter PHY_ADDR_WIDTH    = ADDR_WIDTH;

//----------------------------------------------------
input                                w_clk;
input                                r_clk;
input                                w_nrst;
input                                r_nrst;

input                                ecc_addr_protect_en;
input                                ecc_fault_detc_en;
input  [8:0]                         reg_dft_tpram_config;

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
output                               ECC_FAULT_B;
output                               SINGLE_ERR_B;
output                               DOUBLE_ERR_B;

wire   [(PHY_ADDR_WIDTH-1):0]                   AA_w;
wire                                            CSA_w0;
wire                                            WEA_w0;
wire   [(DATA_WIDTH-1):0]                       DA_w;
wire                                            CSB_w0;
wire                                            REB_w0;
wire   [(PHY_ADDR_WIDTH-1):0]                   AB_w;
wire                                            BYPASS_READ_B_w;
wire   [(DATA_WIDTH-1):0]                       QB_F;
wire   [(PHY_AL_DATA_WIDTH-1):0]                QB_p0;
wire   [(PHY_AL_DATA_WIDTH-1):0]                QB_p_tmp0;
wire   [(PHY_AL_DATA_WIDTH-1):0]                QB_t;
wire   [(ADDR_DATA_WIDTH-1):0]                  QB_y;
wire   [(ADDR_DATA_WIDTH-1) : 0 ]               QB_u;
wire                                            ECC_FAULT_B;
wire   [0:0]                                    ECC_FAULT_B_r0;
wire                                            ECC_FAULT_B_t;
wire                                            SINGLE_ERR_B;
wire   [0:0]                                    SINGLE_ERR_B_r0;
wire                                            SINGLE_ERR_B_t;
wire                                            DOUBLE_ERR_B;
wire   [0:0]                                    DOUBLE_ERR_B_r0;
wire                                            DOUBLE_ERR_B_t;
wire   [(PARITY_WIDTH-1):0]                     parity_out;
wire   [(PHY_AL_DATA_WIDTH-DATA_WIDTH-1):0]     QB_p_nc0;
wire                                            BYPASS_WRITE_A_nc;
wire   [0:0]                                    CHECK_IN_A_nc;
wire   [(ADDR_WIDTH-1):0]                       AB_F_d1;
wire                                            rd_val;
wire                                            rd_val_d1;
wire   [(ADDR_DATA_WIDTH-1):0]                  DA_p_tmp;
wire                                            BYPASS_READ_B_p;
wire   [(PHY_ADDR_WIDTH-1):0]                   AA_p00;
wire                                            CSA_p00;
wire                                            WEA_p00;
wire   [(PHY_AL_DATA_WIDTH-1):0]                DA_p00;
wire   [(PHY_ADDR_WIDTH-1):0]                   AB_p00;
wire                                            CSB_p00;
wire                                            REB_p00;
wire                                            CSA_p00_L;
wire                                            WEA_p00_L;
wire                                            CSB_p00_L;
wire                                            REB_p00_L;

assign BYPASS_WRITE_A_nc = BYPASS_WRITE_A;
assign CHECK_IN_A_nc     = CHECK_IN_A;

assign rd_val = CSB_F & REB_F & ((!(CSA_F & WEA_F)) || (CSA_F & WEA_F & (AA_F != AB_F)));

bus_delay_cg #(
    .DELAY_CYCLES ( 1          ),
    .BUS_WIDTH    ( ADDR_WIDTH )
) bus_delay_cg_u0 (
    .clk          ( r_clk      ),
    .rst_n        ( r_nrst     ),
    .en           ( 1'b1       ),
    .inbus        ( AB_F       ),
    .outbus       ( AB_F_d1    )
);

bus_delay_cg #(
    .DELAY_CYCLES ( 1         ),
    .BUS_WIDTH    ( 1         )
) bus_delay_cg_u1 (
    .clk          ( r_clk     ),
    .rst_n        ( r_nrst    ),
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
assign ECC_FAULT_B_t  = (ECC_FAULT_B_r0)  & rd_val_d1;
assign SINGLE_ERR_B_t = (SINGLE_ERR_B_r0) & rd_val_d1;
assign DOUBLE_ERR_B_t = (DOUBLE_ERR_B_r0) & rd_val_d1;

bus_delay_cg #(
    .DELAY_CYCLES ( 1              ),
    .BUS_WIDTH    ( 1              )
) bus_delay_cg_u2 (
    .clk          ( r_clk          ),
    .rst_n        ( r_nrst         ),
    .en           ( 1'b1           ),
    .inbus        ( SINGLE_ERR_B_t ),
    .outbus       ( SINGLE_ERR_B   )
);

bus_delay_cg #(
    .DELAY_CYCLES ( 1              ),
    .BUS_WIDTH    ( 1              )
) bus_delay_cg_u3 (
    .clk          ( r_clk          ),
    .rst_n        ( r_nrst         ),
    .en           ( 1'b1           ),
    .inbus        ( DOUBLE_ERR_B_t ),
    .outbus       ( DOUBLE_ERR_B   )
);

bus_delay_cg #(
    .DELAY_CYCLES ( 1              ),
    .BUS_WIDTH    ( 1              )
) bus_delay_cg_u4 (
    .clk          ( r_clk          ),
    .rst_n        ( r_nrst         ),
    .en           ( 1'b1           ),
    .inbus        ( ECC_FAULT_B_t  ),
    .outbus       ( ECC_FAULT_B    )
);

assign DA_p_tmp[(ADDR_DATA_WIDTH-1):0] = ecc_addr_protect_en ? {{AA_w,DA_w}} : {{{{ADDR_WIDTH{{1'd0}}}},DA_w}};
assign BYPASS_READ_B_p = BYPASS_READ_B_w;

assign DA_w[DATA_WIDTH-1 :0] =DA_F;

ecc_{data_addr_width}_cal #(
  .DATA_WIDTH   ( ADDR_DATA_WIDTH                ),
  .PARITY_WIDTH ( PARITY_WIDTH                   )
) ecc_{data_addr_width}_cal_encode (
    .data_in    ( DA_p_tmp[(ADDR_DATA_WIDTH-1):0]),
    .data_out   (                                ),
    .parity_in  ( {{(PARITY_WIDTH){{1'b0}}}}         ),
    .parity_out ( parity_out[(PARITY_WIDTH-1):0] ),
    .bypass     ( BYPASS_READ_B_p                ),
    .mask       (                                ),
    .sbit_err   (                                ),
    .dbit_err   (                                )
);

ecc_{data_addr_width}_fault_detc #(
  .DATA_WIDTH           ( ADDR_DATA_WIDTH                              ),
  .PARITY_WIDTH         ( PARITY_WIDTH                                 )
) u_ecc_{data_addr_width}_fault_detc (
    .ecc_fault_detc_en  ( ecc_fault_detc_en                            ),
    .data_in            ( QB_y[(ADDR_DATA_WIDTH-1):0]                  ),
    .data_out           ( QB_u[(ADDR_DATA_WIDTH-1):0]                  ),
    .parity_in          ( QB_t[(DATA_WIDTH+PARITY_WIDTH-1):DATA_WIDTH] ),
    .bypass             ( BYPASS_READ_B_p                              ),
    .ecc_fault          ( ECC_FAULT_B_r0                               ),
    .sbit_err           ( SINGLE_ERR_B_r0                              ),
    .dbit_err           ( DOUBLE_ERR_B_r0                              )
);

assign QB_y[(ADDR_DATA_WIDTH-1):0] = ecc_addr_protect_en? {{AB_F_d1,QB_t[(DATA_WIDTH-1):0]}} :
                                                          {{{{ADDR_WIDTH{{1'd0}}}},QB_t[(DATA_WIDTH-1):0]}};
bus_delay_cg #(
    .DELAY_CYCLES ( 1                      ),
    .BUS_WIDTH    ( DATA_WIDTH             )
) bus_delay_cg_u5 (
    .clk          ( r_clk                  ),
    .rst_n        ( r_nrst                 ),
    .en           ( 1'b1                   ),
    .inbus        ( QB_u[(DATA_WIDTH)-1:0] ),
    .outbus       ( QB_F[(DATA_WIDTH)-1:0] )
);


assign DA_p00 = {{parity_out,DA_p_tmp[(DATA_WIDTH-1):0]}};
assign {{AA_p00, CSA_p00,WEA_p00, AB_p00,CSB_p00, REB_p00}} = {{AA_w, CSA_w0,WEA_w0, AB_w,CSB_w0, REB_w0}};
assign QB_p_tmp0[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)] = QB_p0[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)];

assign CSA_p00_L = ~CSA_p00;
assign WEA_p00_L = ~WEA_p00;
assign CSB_p00_L = ~CSB_p00;
assign REB_p00_L = ~REB_p00;

{port_num}{memory_type}{ram_depth}X{data_parity_width}{perip_vt}BW{bit_write}M{multip}B{bank}R{redundancy}P{low_power}_I{input_type}O{output_pipe} #(
    .ADDR_WIDTH   ( ADDR_WIDTH                                      ),
    .DATA_WIDTH   ( PHY_DATA_WIDTH                                  ),
    .MEM_DEPTH    ( RAM_DEPTH                                       )
)u_{port_num}{memory_type}{ram_depth}X{data_parity_width}{perip_vt}BW{bit_write}M{multip}B{bank}R{redundancy}P{low_power}_I{input_type}O{output_pipe} (
    .TPRAM_CONFIG ( reg_dft_tpram_config                            ),
    .Q            ( QB_p0[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)]  ),
    .ClkA         ( w_clk                                           ),
    .ClkB         ( r_clk                                           ),
    .CEAB         ( CSA_p00_L                                       ),
    .WEAB         ( WEA_p00_L                                       ),
    .AddrA        ( AA_p00                                          ),
    .Din          ( DA_p00[(PHY_DATA_WIDTH*1-1):(PHY_DATA_WIDTH*0)] ),
    .CEBB         ( CSB_p00_L                                       ),
    .REBB         ( REB_p00_L                                       ),
    .AddrB        ( AB_p00                                          )
);

endmodule
