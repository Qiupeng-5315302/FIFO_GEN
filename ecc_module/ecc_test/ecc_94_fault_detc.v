
module ecc_94_fault_detc#(
    parameter DATA_WIDTH = 94,
    parameter PARITY_WIDTH = 8
)
(

    input                       ecc_fault_detc_en,
    input   [DATA_WIDTH-1:0]    data_in,
    input   [PARITY_WIDTH-1:0]  parity_in,
    input                       bypass,
    output  [DATA_WIDTH-1:0]    data_out,
    output                      ecc_fault,
    output                      sbit_err,
    output                      dbit_err

);

wire                        compare_succeed;
wire [DATA_WIDTH-1:0]       data_out0;
wire [DATA_WIDTH-1:0]       mask0;
wire                        sbit_err0;
wire                        dbit_err0;
wire [DATA_WIDTH-1:0]       mask1;
wire                        sbit_err1;
wire                        dbit_err1;

ecc_94_cal #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .PARITY_WIDTH ( PARITY_WIDTH )
)u0_ecc_94_top(
    .data_in    (data_in),
    .data_out   (data_out0),
    .parity_in  (parity_in),
    .parity_out (),
    .bypass     (bypass),
    .mask       (mask0),
    .sbit_err   (sbit_err0),
    .dbit_err   (dbit_err0)
);

ecc_94_cal #(
    .DATA_WIDTH ( DATA_WIDTH ),
    .PARITY_WIDTH ( PARITY_WIDTH )
)u1_ecc_94_cal(
    .data_in    (data_in),
    .data_out   (),
    .parity_in  (parity_in),
    .parity_out (),
    .bypass     (bypass),
    .mask       (mask1),
    .sbit_err   (sbit_err1),
    .dbit_err   (dbit_err1)
);

assign  compare_succeed = ~|({sbit_err0,dbit_err0,mask0}^{sbit_err1,dbit_err1,mask1});

assign  data_out = (compare_succeed|~ecc_fault_detc_en) ? data_out0 : data_in;

assign  ecc_fault = ~compare_succeed & ecc_fault_detc_en;

assign  sbit_err = sbit_err0;
                     
assign  dbit_err = dbit_err0;

endmodule

