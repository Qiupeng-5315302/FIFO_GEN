
module as6d_pcs_rx_pldb_1r1w_128x72_fwft_fifo_wrapper(/*AUTOARG*/
   // Outputs
   rd_data, rd_data_val, single_err, double_err, ovf_int, udf_int,reg_dft_tpram_config,
   prog_full, empty, full,
   // Inputs
   clk, rst_n, ram_bypass, prog_full_assert_cfg, prog_full_negate_cfg,
   wr_data, wr_en, rd_en
   );
// -----------------------------------------------------------------------------

// parameter declaration

// -----------------------------------------------------------------------------            
parameter   FLIPFLOP			  = 0;
parameter   ADDR_WIDTH            = 7;
parameter   DATA_WIDTH            = 72;
parameter   PROG_EMPTY_ASSERT     = 4;             //fifo data count threshold of prog empty assert
parameter   PROG_EMPTY_NEGATE     = 4;             //fifo data count threshold of prog empty negate
parameter   FIFO_DEEP             = 1<<ADDR_WIDTH; //fifo data depth
parameter   RAM_PIPE_STAGE        = 2;             //RAM read dalay

localparam  PRE_REG_NUM           = RAM_PIPE_STAGE + 2;

// -----------------------------------------------------------------------------

// port declaration

// -----------------------------------------------------------------------------

//output ports
output [(DATA_WIDTH-1):0]   rd_data;              //output data to fifo
output                      rd_data_val;          //output data valid 
output                      single_err;           //
output                      double_err;           //
output                      ovf_int;              //write over flow interrupt  1=interrupt 0=no interrupt 
output	reg	                udf_int;              //read  under flow interrupt  1=interrupt 0=no interrupt

output                      prog_full;            //fifo prog_full  flag
output                      empty;                //fifo empty flag
output                      full;                 //fifo full flag

//global ports                  
input                       clk;                  //input clk 
input                       rst_n;                //globe aysn rst_n
input                       ram_bypass;           //

//input ports           
input  [8:0]				reg_dft_tpram_config;
input  [ADDR_WIDTH:0]       prog_full_assert_cfg; //almost full assert config
input  [ADDR_WIDTH:0]       prog_full_negate_cfg; //almost full negate config
input  [(DATA_WIDTH-1):0]   wr_data;              //input data to fifo
input                       wr_en;                //write enable 
input                       rd_en;                //read enable 

// -----------------------------------------------------------------------------

// signal declaration

// ----------------------------------------------------------------------------- 
genvar i;

wire                        ren;                                 //
wire                        wen;                                 //

wire [(DATA_WIDTH-1):0]     s_rd_data;                           //
wire                        s_rd_data_val;                       //              
wire                        s_prog_empty_nc;                     //               
wire                        s_prog_full;                         //                
wire                        s_empty;                             //                    
wire                        s_full;                              //  
wire [ADDR_WIDTH:0]         s_prog_full_assert_cfg;              //
wire [ADDR_WIDTH:0]         s_prog_full_negate_cfg;              //
wire [(DATA_WIDTH-1):0]     s_wr_data;                           //
wire                        s_wr_en;                             //                     
wire                        s_rd_en;                             //     
wire						udf_int_nc;							 //

reg  [(DATA_WIDTH-1):0]     pre_rd_data[(PRE_REG_NUM-1):0];      //
reg  [(PRE_REG_NUM-1):0]    pre_rd_data_val;                     //   

reg  [(PRE_REG_NUM-1):0]    in_active;                           //
reg  [(PRE_REG_NUM-1):0]    out_active;                          //
wire [(PRE_REG_NUM-1):0]    in_active_nr;                        //

wire [(DATA_WIDTH-1):0]     pre_rd_data_mask[(PRE_REG_NUM-1):0]; //  
wire [(DATA_WIDTH-1):0]     pre_rd_data_out[(PRE_REG_NUM-1):0];  // 

// -----------------------------------------------------------------------------

// implementation

// ----------------------------------------------------------------------------- 
assign ren = rd_en & rd_data_val;
assign wen = wr_en & (~full);

assign empty = ~rd_data_val;
assign prog_full = s_prog_full;
assign full = s_full;
	 
always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
			udf_int <= 1'b0;
        end
        else begin
            udf_int <= rd_en && empty;
        end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)begin 
        in_active <= {{(PRE_REG_NUM-1){1'b0}}, 1'b1};
    end
    else if(s_rd_en)begin
        in_active <= {in_active[(PRE_REG_NUM-2):0], in_active[PRE_REG_NUM-1]};
    end
end   

always @(posedge clk or negedge rst_n)begin 
    if(~rst_n)begin 
        out_active <= {{(PRE_REG_NUM-1){1'b0}}, 1'b1};
    end
    else if(ren)begin
        out_active <= {out_active[(PRE_REG_NUM-2):0], out_active[PRE_REG_NUM-1]};
    end
end   

generate    
    for (i=0;i<PRE_REG_NUM;i=i+1) begin: generate_pre_rd_data
        always @(posedge clk or negedge rst_n)begin
            if (~rst_n)begin 
                pre_rd_data[i] <= 0;
                pre_rd_data_val[i] <= 1'b0;
            end
            else if(s_rd_data_val&in_active_nr[i])begin
                pre_rd_data[i] <= s_rd_data;
                pre_rd_data_val[i] <= 1'b1;
            end
            else if(ren&out_active[i])begin
                pre_rd_data_val[i] <= 1'b0;
            end
        end
    end
endgenerate

generate    
    for (i=0;i<PRE_REG_NUM;i=i+1) begin: generate_pre_rd_data_mask
        assign pre_rd_data_mask[i] = pre_rd_data[i] & {DATA_WIDTH{out_active[i]}};
    end
endgenerate

generate    
    for (i=1;i<PRE_REG_NUM;i=i+1) begin : generate_pre_rd_data_out
        assign pre_rd_data_out[i] = pre_rd_data_mask[i] | pre_rd_data_out[i-1];
    end
endgenerate

assign pre_rd_data_out[0] = pre_rd_data_mask[0];

assign rd_data = pre_rd_data_out[PRE_REG_NUM-1];
assign rd_data_val = |(pre_rd_data_val & out_active);


assign s_prog_full_assert_cfg = prog_full_assert_cfg;
assign s_prog_full_negate_cfg = prog_full_negate_cfg;
assign s_wr_data = wr_data;
assign s_wr_en = wen;  
assign s_rd_en = (~s_empty) & ((in_active & pre_rd_data_val) == {PRE_REG_NUM{1'b0}});

bus_delay #(
    .DELAY_CYCLES ( RAM_PIPE_STAGE                  ),
    .BUS_WIDTH    ( PRE_REG_NUM                     ),
    .INIT_VAL     ( {{(PRE_REG_NUM-1){1'b0}}, 1'b1} )
)bus_delay_u0 (
    .clk          ( clk          ),
    .rst_n        ( rst_n        ),
    .inbus        ( in_active    ),
    .outbus       ( in_active_nr )
);

as6d_pcs_rx_pldb_1r1w_128x72_fifo_wrapper #(
    .FLIPFLOP		   ( FLIPFLOP		   ),
    .ADDR_WIDTH        ( ADDR_WIDTH        ),
    .DATA_WIDTH        ( DATA_WIDTH        ),
    .PROG_EMPTY_ASSERT ( PROG_EMPTY_ASSERT ),
    .PROG_EMPTY_NEGATE ( PROG_EMPTY_NEGATE ),
    .FIFO_DEEP         ( FIFO_DEEP         ),
    .RAM_PIPE_STAGE    ( RAM_PIPE_STAGE    )
)u0_as6d_pcs_rx_pldb_1r1w_128x72_fifo_wrapper (
	.reg_dft_tpram_config( reg_dft_tpram_config  ),
    .rd_data              ( s_rd_data              ),
    .rd_data_val          ( s_rd_data_val          ),
    .single_err           ( single_err             ),
    .double_err           ( double_err             ),
    .ram_bypass           ( ram_bypass             ),
    .prog_empty           ( s_prog_empty_nc        ),
    .prog_full            ( s_prog_full            ),
    .ovf_int              ( ovf_int                ),
    .udf_int              ( udf_int_nc             ),
    .empty                ( s_empty                ),
    .full                 ( s_full                 ),
    .clk                  ( clk                    ),
    .rst_n                ( rst_n                  ),
    .prog_full_assert_cfg ( s_prog_full_assert_cfg ),
    .prog_full_negate_cfg ( s_prog_full_negate_cfg ),
    .wr_data              ( s_wr_data              ),
    .wr_en                ( s_wr_en                ),
    .rd_en                ( s_rd_en                )
);

endmodule

