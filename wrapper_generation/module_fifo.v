
module {module_name}_1r1w_{ram_depth}x{data_width}_fifo_wrapper(/*AUTOARG*/
   // Outputs
   rd_data, rd_data_val, prog_empty, prog_full, ovf_int, udf_int,
   empty, full, ecc_fault, single_err, double_err,data_count_real,
   // Inputs
   clk, rst_n, ram_bypass, {tpuhd_port}, prog_full_assert_cfg,
   prog_full_negate_cfg, ecc_addr_protect_en, ecc_fault_detc_en, ecc_bypass,
   wr_data, wr_en, rd_en
   );

    // -----------------------------------------------------------------------------
    // parameter declaration
    // -----------------------------------------------------------------------------

    parameter   FLIPFLOP          = 0;
    parameter   ADDR_WIDTH        = {addr_width};
    parameter   DATA_WIDTH        = {data_width};
    parameter   PROG_EMPTY_ASSERT = 4;              //fifo data count threshold of prog empty assert
    parameter   PROG_EMPTY_NEGATE = 4;              //fifo data count threshold of prog empty negate
    parameter   FIFO_DEEP         = 1<<ADDR_WIDTH;  //fifo data depth
    parameter   RAM_PIPE_STAGE    = 2;              //RAM read dalay

    //output ports
    output [DATA_WIDTH-1:0]   rd_data;     //output data to fifo
    output                    rd_data_val; //output data valid
    output                    prog_empty;  //fifo prog_empty flag
    output                    prog_full;   //fifo prog_full  flag
    output                    ovf_int;     //write over flow interrupt  1=interrupt 0=no interrupt
    output                    udf_int;     //read  under flow interrupt  1=interrupt 0=no interrupt
    output                    empty;       //fifo empty flag
    output                    full;        //fifo full flag
    output                    ecc_fault;   //
    output                    single_err;  //
    output                    double_err;  //
    output [  ADDR_WIDTH:0]   data_count_real;     //output data to fifo

    //global ports
    input                     clk;         //input clk
    input                     rst_n;       //globe aysn rst_n
    input                     ram_bypass;

    //input ports
    {tpuhd_ram}
    input  [ADDR_WIDTH:0]     prog_full_assert_cfg; // almost full assert config
    input  [ADDR_WIDTH:0]     prog_full_negate_cfg; // almost full negate config
    input                     ecc_addr_protect_en;
    input                     ecc_fault_detc_en;
    input                     ecc_bypass;

    input  [DATA_WIDTH-1:0]   wr_data;     //input data to fifo
    input                     wr_en;       //write enable
    input                     rd_en;       //read enable


    // -----------------------------------------------------------------------------
    // wire declaration
    // -----------------------------------------------------------------------------

    wire   [ADDR_WIDTH-1:0]   wr_addr;       //binary write address
    wire   [ADDR_WIDTH-1:0]   rd_addr;       //binary read address


    // -----------------------------------------------------------------------------
    // register declaration
    // -----------------------------------------------------------------------------

    reg    [ADDR_WIDTH:0]     data_count;  //count the data in fifo
    reg    [  ADDR_WIDTH:0]   data_count_real;     //output data to fifo
    reg    [ADDR_WIDTH:0]     waddr;       //binary write address,the MSB is state bit
    reg    [ADDR_WIDTH:0]     raddr;       //binary read address,the MSB is state bit

    wire   [DATA_WIDTH-1:0]   rd_data ;    //output data to fifo
    wire                      rd_data_val; //output data valid
    reg                       prog_empty;  //fifo prog_empty flag
    reg                       prog_full;   //fifo prog_full flag
    reg                       ovf_int;     //write over flow interrupt  1=interrupt 0=no interrupt
    reg                       udf_int;     //read  under flow interrupt  1=interrupt 0=no interrupt
    reg                       empty;       //fifo empty flag
    reg                       full;        //fifo full flag

    wire                      ren;         //real read enable
    wire                      wen;         //real write enable


    bus_delay_cg #(
        .DELAY_CYCLES ( RAM_PIPE_STAGE ),
        .BUS_WIDTH    ( 1              ),
        .INIT_VAL     ( 0              )
    ) bus_delay_u0 (
        .clk          ( clk            ),
        .rst_n        ( rst_n          ),
        .inbus        ( ren            ),
        .en           ( 1'b1           ),
        .outbus       ( rd_data_val    )
    );


    // -----------------------------------------------------------------------------
    // sync_fifo write control logic
    // -----------------------------------------------------------------------------

    //ram write enable
    assign wen = wr_en && (!full); //forbid writing when fifo is full

    // interrupt of ovf_int and udf_int
    always @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            ovf_int <= 1'b0;
            udf_int <= 1'b0;
        end
        else begin
            ovf_int <= wr_en && full;
            udf_int <= rd_en && empty;
        end
    end

    //generate the ram write address
    always @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            waddr <= {{(ADDR_WIDTH + 1){{1'b0}}}};
        end
        else if(wen)begin
            waddr <= (waddr == (FIFO_DEEP - 1))? {{(ADDR_WIDTH + 1){{1'b0}}}}: (waddr + 1'b1);
        end
        else begin
            waddr <= waddr;
        end
    end

    assign wr_addr = waddr[ADDR_WIDTH-1:0]; //real write addr


    // -----------------------------------------------------------------------------
    // sync_fifo read control logic
    // -----------------------------------------------------------------------------

    //ram read enable
    assign ren = rd_en && (!empty); //forbid reading when fifo is empty

    //generate the ram read address
    always @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            raddr <= {{(ADDR_WIDTH + 1){{1'b0}}}};
        end
        else if(ren)begin
            raddr <= (raddr == (FIFO_DEEP - 1))? {{(ADDR_WIDTH + 1){{1'b0}}}}: (raddr + 1'b1);
        end
        else begin
            raddr <= raddr;
        end
    end

    assign rd_addr = raddr[ADDR_WIDTH-1:0]; //real read addr


    // -----------------------------------------------------------------------------
    // sync_fifo status signal gengerated
    // -----------------------------------------------------------------------------

    //data counter
    always @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            data_count <= {{(ADDR_WIDTH + 1){{1'b0}}}};
        end
        else if(wen && (!ren))begin
            data_count <= data_count + 1'b1;
        end
        else if((!wen) && ren)begin
            data_count <= data_count - 1'b1;
        end
    end

    //data counter
    always @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            data_count_real <= {{(ADDR_WIDTH + 1){{1'b0}}}};
        end
        else if(wen && (!rd_data_val))begin
            data_count_real <= data_count_real + 1'b1;
        end
        else if((!wen) && rd_data_val)begin
            data_count_real <= data_count_real - 1'b1;
        end
    end

    //generated almost full signal
    always @(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            prog_full <= 1'b0;
        end
        else begin
            if(((!prog_full) && (data_count >= prog_full_assert_cfg)) || ((data_count == (prog_full_assert_cfg -1)) && (wen && (!ren))))begin
                prog_full <= 1'b1;
            end
            else if((prog_full && (data_count < prog_full_negate_cfg)) || ((data_count == prog_full_negate_cfg) && ((!wen) && ren)))begin
                prog_full <= 1'b0;
            end
            else begin
                prog_full <= prog_full;
            end
        end
    end

    //generated full signal
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            full <= 1'b0;
        end
        else if(full && ren)begin
            full <= 1'b0;
        end
        else begin
            full <= (data_count == FIFO_DEEP) || ((data_count == (FIFO_DEEP - 1)) && (wen && !ren));
        end
    end

    //generated almost empty signal
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            prog_empty <= 1'b1;
        end
        else begin
            if(((~prog_empty) && (data_count <= PROG_EMPTY_ASSERT)) || ((data_count == (PROG_EMPTY_ASSERT + 1)) && ((!wen) && ren)))begin
                prog_empty <= 1'b1;
            end
            else if((prog_empty && (data_count > PROG_EMPTY_NEGATE)) || ((data_count == (PROG_EMPTY_NEGATE)) && (wen && (!ren))))begin
                prog_empty <= 1'b0;
            end
            else begin
                prog_empty <= prog_empty;
            end
        end
    end

    //generated empty signal
    always@(posedge clk or negedge rst_n)begin
        if(~rst_n)begin
            empty <= 1'b1;
        end
        else if(empty && wen)begin
            empty <= 1'b0;
        end
        else begin
            empty <= (data_count == 0) || ((data_count == 1) && ((!wen) && ren));
        end
    end


    // -----------------------------------------------------------------------------
    //ram instance
    // -----------------------------------------------------------------------------

    wire wen_l;
    wire ren_l;

    assign wen_l = ~wen;
    assign ren_l = ~ren;

    generate if(FLIPFLOP == 0)begin: MEM_INST_BK
    {ram_inst}
    end
    else begin: FLIPFLOP_BK

    assign single_err = 1'd0;
    assign double_err = 1'd0;
    assign ecc_fault  = 1'd0;

    sram_wrapper #(
        .FLIPFLOP                  ( FLIPFLOP                  ),
        .MEM_DEPTH                 ( FIFO_DEEP                 ),
        .ADDR_WIDTH                ( ADDR_WIDTH                ),
        .DATA_WIDTH                ( DATA_WIDTH                )
    ) u0_sram_wrapper (
        .ClkA                      ( clk                       ), //input
        .ClkB                      ( clk                       ), //input
        .AddrA                     ( wr_addr                   ), //input  [ADDR_WIDTH-1:0]
        .AddrB                     ( rd_addr                   ), //input  [ADDR_WIDTH-1:0]
        .Din                       ( wr_data                   ), //input  [DATA_WIDTH-1:0]
        .CEAB                      ( wen_l                     ), //input
        .CEBB                      ( ren_l                     ), //input
        .WEAB                      ( wen_l                     ), //input
        .REBB                      ( ren_l                     ), //input
        .Q                         ( rd_data                   )  //output [DATA_WIDTH-1:0]
    );
    end
    endgenerate

endmodule
