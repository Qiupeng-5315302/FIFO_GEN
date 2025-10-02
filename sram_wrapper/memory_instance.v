
/////////////////////////////////////
/////    memory sp/tp sub-module ////
/////////////////////////////////////
//V0.1 initial version, create in 2022/6/30, by yanhaitao

//sp_sram
module sp_sram #(
    parameter MEM_DEPTH   =12,
    parameter ADDR_WIDTH  =4,
    parameter DATA_WIDTH  =10
)(
    input                          clk,
    input       [ADDR_WIDTH-1:0]   addr,
    input       [DATA_WIDTH-1:0]   din,
    input       [DATA_WIDTH-1:0]   bwb,
    input                          ceb,
    input                          web,
    output reg  [DATA_WIDTH-1:0]   dout
);

`ifdef FPGA
(* ram_style="block" *)
`endif
reg [DATA_WIDTH-1:0] mem[MEM_DEPTH-1:0]; 

////init
//integer i;
//initial begin
//   for (i=0; i<MEM_DEPTH;i=i+1) begin
//     mem[i] = 'h0;
//   end
`ifdef FPGA
always @(posedge clk) begin 
    if ((!ceb) & (!web)) begin 
       mem[addr] <= din;
    end
end
`else
always @(posedge clk) begin 
    if ((!ceb) & (!web)) begin 
       mem[addr] <= (din & (~bwb)) | (mem[addr] & (bwb));
    end
end
`endif

always @(posedge clk) begin 
    if((!ceb) && (web)) begin
       dout <= mem[addr];
    end
end

endmodule

//tp_sram
module tp_sram #(
    parameter MEM_DEPTH   =12,
    parameter ADDR_WIDTH  =4,
    parameter DATA_WIDTH  =10
)(
    input                          clka,
    input                          clkb,
    input       [ADDR_WIDTH-1:0]   addra,
    input       [ADDR_WIDTH-1:0]   addrb,
    input       [DATA_WIDTH-1:0]   din,
    input       [DATA_WIDTH-1:0]   bwab,
    input                          ceab,
    input                          cebb,
    input                          weab,
    input                          rebb,
    output reg  [DATA_WIDTH-1:0]   dout
);

`ifdef FPGA
(* ram_style="block" *)
`endif
reg [DATA_WIDTH-1:0] mem[MEM_DEPTH-1:0]; 

////init
//integer i;
//initial begin
//   for (i=0; i<MEM_DEPTH;i=i+1) begin
//     mem[i] = 'h0;
//   end

`ifdef FPGA
always @(posedge clka) begin 
    if ((!ceab) & (!weab)) begin 
       mem[addra] <= din;
    end
end
`else
always @(posedge clka) begin 
    if ((!ceab) & (!weab)) begin 
       mem[addra] <= (din & (~bwab)) | (mem[addra] & (bwab));
    end
end
`endif

always @(posedge clkb) begin 
    if((!cebb) && (!rebb)) begin
       dout <= mem[addrb];
    end
end

endmodule



