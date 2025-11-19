
module as6s_vp_buffer_1r1w_16x128_fwft_afifo_wrapper(/*AUTOARG*/
   // Outputs
   rd_data, rd_data_val, ecc_fault, single_err, double_err, ovf_int,
   udf_int, prog_full, empty, full, data_count,
   // Inputs
   wr_clk, wr_rst_n, rd_clk, rd_rst_n, ram_bypass, reg_dft_tpram_config,
   prog_full_assert_cfg, prog_full_negate_cfg, ecc_addr_protect_en, ecc_bypass,
   ecc_fault_detc_en, wr_data, wr_en, rd_en, wr_domain_clear, rd_domain_clear
   );


    // -----------------------------------------------------------------------------
    // parameter declaration
    // -----------------------------------------------------------------------------

    parameter   FLIPFLOP              = 0;
    parameter   ADDR_WIDTH            = 4;
    parameter   DATA_WIDTH            = 128;
    parameter   PROG_EMPTY_ASSERT     = 4;             //fifo data count threshold of prog empty assert
    parameter   PROG_EMPTY_NEGATE     = 4;             //fifo data count threshold of prog empty negate
    parameter   FIFO_DEEP             = 1<<ADDR_WIDTH; //fifo data depth
    parameter   RAM_PIPE_STAGE        = 2;             //RAM read dalay

    localparam  PRE_REG_NUM           = RAM_PIPE_STAGE + 2;


    // -----------------------------------------------------------------------------
    // port declaration
    // -----------------------------------------------------------------------------

    //output ports
    output [(DATA_WIDTH-1):0] rd_data;              //output data to fifo
    output                    rd_data_val;          //output data valid
    output                    ecc_fault;  //
    output                    single_err;           //
    output                    double_err;           //
    output  reg               ovf_int;              //write over flow interrupt  1=interrupt 0=no interrupt
    output  reg               udf_int;              //read  under flow interrupt  1=interrupt 0=no interrupt

    output                    prog_full;            //fifo prog_full  flag
    output                    empty;                //fifo empty flag
    output                    full;                 //fifo full flag
    output [ADDR_WIDTH:0]     data_count;

    //global ports
    input                     wr_clk;               //input wr_clk
    input                     wr_rst_n;             //globe aysn wr_rst_n
    input                     rd_clk;               //input rd_clk
    input                     rd_rst_n;             //globe aysn rd_rst_n
    input                     ram_bypass;           //

    //input ports
    input  [8:0]              reg_dft_tpram_config;

    input  [ADDR_WIDTH:0]     prog_full_assert_cfg; //almost full assert config
    input  [ADDR_WIDTH:0]     prog_full_negate_cfg; //almost full negate config
    input                     ecc_addr_protect_en;
    input                     ecc_fault_detc_en;
    input                     ecc_bypass;

    input  [(DATA_WIDTH-1):0] wr_data;              //input data to fifo
    input                     wr_en;                //write enable
    input                     rd_en;                //read enable
    input                     wr_domain_clear;      //write domain synchronous clear
    input                     rd_domain_clear;      //read domain synchronous clear


    // -----------------------------------------------------------------------------
    // signal declaration
    // -----------------------------------------------------------------------------

    genvar i;

    wire                      ren;                                 //
    wire                      wen;                                 //

    wire [(DATA_WIDTH-1):0]   s_rd_data;                           //
    wire                      s_rd_data_val;                       //
    wire                      s_prog_empty_nc;                     //
    wire                      s_prog_full;                         //
    wire                      s_empty;                             //
    wire                      s_full;                              //
    wire [ADDR_WIDTH:0]       s_prog_full_assert_cfg;              //
    wire [ADDR_WIDTH:0]       s_prog_full_negate_cfg;              //
    wire [(DATA_WIDTH-1):0]   s_wr_data;                           //
    wire                      s_wr_en;                             //
    wire                      s_rd_en;                             //
    wire                      ovf_int_nc;                          //
    wire                      udf_int_nc;                          //

    reg  [(DATA_WIDTH-1):0]   pre_rd_data[(PRE_REG_NUM-1):0];      //
    reg  [(PRE_REG_NUM-1):0]  pre_rd_data_val;                     //

    reg  [(PRE_REG_NUM-1):0]  in_active;                           //
    reg  [(PRE_REG_NUM-1):0]  out_active;                          //
    wire [(PRE_REG_NUM-1):0]  in_active_nr;                        //

    wire [(DATA_WIDTH-1):0]   pre_rd_data_mask[(PRE_REG_NUM-1):0]; //
    wire [(DATA_WIDTH-1):0]   pre_rd_data_out[(PRE_REG_NUM-1):0];  //

    wire [ADDR_WIDTH:0]       data_count_pre;
    wire                      data_count_nc;
    reg  [ADDR_WIDTH:0]       pre_read_num;

    // -----------------------------------------------------------------------------
    // implementation
    // -----------------------------------------------------------------------------

    assign ren = rd_en & rd_data_val;
    assign wen = wr_en & (~full);

    assign empty     = ~rd_data_val;
    assign prog_full = s_prog_full;

    always @(posedge wr_clk or negedge wr_rst_n)begin
        if(~wr_rst_n)begin
            ovf_int <= 1'b0;
        end
        else begin
            ovf_int <= wr_en && full;
        end
    end

    assign full = s_full;

    always@(posedge rd_clk or negedge rd_rst_n)begin
        if(~rd_rst_n)begin
            udf_int <= 1'b0;
        end
        else begin
            udf_int <= rd_en && empty;
        end
    end

    always @(posedge rd_clk or negedge rd_rst_n) begin
        if(~rd_rst_n)begin
            in_active <= {{(PRE_REG_NUM-1){1'b0}}, 1'b1};
        end
        else if(rd_domain_clear)begin               //synchronous clear has higher priority
            in_active <= {{(PRE_REG_NUM-1){1'b0}}, 1'b1};
        end
        else if(s_rd_en)begin
            in_active <= {in_active[(PRE_REG_NUM-2):0], in_active[PRE_REG_NUM-1]};
        end
    end

    always @(posedge rd_clk or negedge rd_rst_n)begin
        if(~rd_rst_n)begin
            out_active <= {{(PRE_REG_NUM-1){1'b0}}, 1'b1};
        end
        else if(rd_domain_clear)begin               //synchronous clear has higher priority
            out_active <= {{(PRE_REG_NUM-1){1'b0}}, 1'b1};
        end
        else if(ren)begin
            out_active <= {out_active[(PRE_REG_NUM-2):0], out_active[PRE_REG_NUM-1]};
        end
    end

    generate
        for(i=0;i<PRE_REG_NUM;i=i+1)begin: generate_pre_rd_data
            always @(posedge rd_clk or negedge rd_rst_n)begin
                if (~rd_rst_n)begin
                    pre_rd_data[i] <= 0;
                    pre_rd_data_val[i] <= 1'b0;
                end
                else if(rd_domain_clear)begin           //synchronous clear has higher priority
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
        for(i=0;i<PRE_REG_NUM;i=i+1)begin: generate_pre_rd_data_mask
            assign pre_rd_data_mask[i] = pre_rd_data[i] & {DATA_WIDTH{out_active[i]}};
        end
    endgenerate

    generate
        for(i=1;i<PRE_REG_NUM;i=i+1)begin: generate_pre_rd_data_out
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

    bus_delay_clr #(
        .DELAY_CYCLES ( RAM_PIPE_STAGE                  ),
        .BUS_WIDTH    ( PRE_REG_NUM                     ),
        .INIT_VAL     ( {{(PRE_REG_NUM-1){1'b0}}, 1'b1} )
    ) bus_delay_clr_u0 (
        .clk          ( rd_clk       ),
        .rst_n        ( rd_rst_n     ),
        .clear        ( rd_domain_clear ),
        .inbus        ( in_active    ),
        .outbus       ( in_active_nr )
    );

    as6s_vp_buffer_1r1w_16x128_afifo_wrapper #(
        .FLIPFLOP                  ( FLIPFLOP                  ),
        .ADDR_WIDTH                ( ADDR_WIDTH                ),
        .DATA_WIDTH                ( DATA_WIDTH                ),
        .PROG_EMPTY_ASSERT         ( PROG_EMPTY_ASSERT         ),
        .PROG_EMPTY_NEGATE         ( PROG_EMPTY_NEGATE         ),
        .FIFO_DEEP                 ( FIFO_DEEP                 ),
        .RAM_PIPE_STAGE            ( RAM_PIPE_STAGE            )
    ) u0_as6s_vp_buffer_1r1w_16x128_afifo_wrapper (
        .reg_dft_tpram_config      ( reg_dft_tpram_config      ),
        .rd_data                   ( s_rd_data                 ),
        .rd_data_val               ( s_rd_data_val             ),
        .ecc_fault                 ( ecc_fault                 ),
        .single_err                ( single_err                ),
        .double_err                ( double_err                ),
        .ram_bypass                ( ram_bypass                ),
        .prog_empty                ( s_prog_empty_nc           ),
        .prog_full                 ( s_prog_full               ),
        .ovf_int                   ( ovf_int_nc                ),
        .udf_int                   ( udf_int_nc                ),
        .empty                     ( s_empty                   ),
        .full                      ( s_full                    ),
        .wr_clk                    ( wr_clk                    ),
        .wr_rst_n                  ( wr_rst_n                  ),
        .rd_clk                    ( rd_clk                    ),
        .rd_rst_n                  ( rd_rst_n                  ),
        .prog_full_assert_cfg      ( s_prog_full_assert_cfg    ),
        .prog_full_negate_cfg      ( s_prog_full_negate_cfg    ),
        .ecc_addr_protect_en       ( ecc_addr_protect_en       ),
        .ecc_fault_detc_en         ( ecc_fault_detc_en         ),
        .ecc_bypass                ( ecc_bypass                ),
        .wr_data                   ( s_wr_data                 ),
        .wr_en                     ( s_wr_en                   ),
        .rd_en                     ( s_rd_en                   ),
        .data_count                ( data_count_pre            ),
        .wr_domain_clear           ( wr_domain_clear           ),
        .rd_domain_clear           ( rd_domain_clear           )
    );
    
    integer j;
    always@(*)begin
        pre_read_num = {PRE_REG_NUM{1'd0}};
        for (j=0;j<PRE_REG_NUM;j=j+1)begin
            if(pre_rd_data_val[j])
                pre_read_num = pre_read_num + 1'd1;
        end
    end
    assign {data_count_nc,data_count} = pre_read_num + data_count_pre;

endmodule
