
module ecc_{data_wdth}_top

#

(

    parameter DATA_WIDTH = {data_wdth},

    parameter PARITY_WIDTH = {parity_wdth}

)

(

    input   [  DATA_WIDTH-1:0]   data_in,

    output  [  DATA_WIDTH-1:0]   data_out,

    input   [   PARITY_WIDTH-1:0]   parity_in,

    output  [   PARITY_WIDTH-1:0]   parity_out,

    input   bypass,

    output  reg [  DATA_WIDTH-1:0]   mask,

    output  sbit_err,

    output  dbit_err

);



wire  [   PARITY_WIDTH-1:0]   syndrome;

reg   [   1:0]              error;



assign parity_out = ecc_encode(data_in);

assign syndrome = parity_in ^ parity_out;

assign data_out = bypass ? data_in : data_in ^ mask;

assign sbit_err = bypass ? 1'b0 : error[0];

assign dbit_err = bypass ? 1'b0 : error[1];





always @(*)

begin

    error = 2'b00;

    case(syndrome)

    endcase

end



function [  PARITY_WIDTH-1:0] ecc_encode;
    ecc_encode = p;

    end

endfunction



endmodule

