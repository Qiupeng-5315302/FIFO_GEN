
module ecc_1_top

#

(

    parameter DATA_WIDTH = 4,

    parameter PARITY_WIDTH = 4

)

(

    input   [   1-1:0]   data_in,

    output  [   1-1:0]   data_out,

    input   [   3-1:0]   parity_in,

    output  [   3-1:0]   parity_out,

    input   bypass,

    output  sbit_err,

    output  dbit_err

);



wire  [   3-1:0]   syndrome;

reg   [   1-1:0]   mask;

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

    3'b000 : begin mask = 1'b0; error = 2'b00; end

    3'b111 : begin mask = 1'b1; error = 2'b01; end

    3'b100 : begin mask = 1'b0; error = 2'b01; end

    3'b010 : begin mask = 1'b0; error = 2'b01; end

    3'b001 : begin mask = 1'b0; error = 2'b01; end

    default : begin mask = 1'b0; error = 2'b10; end

    endcase

end



function [  3-1:0] ecc_encode;

    input [  1-1:0] d;

    reg   [  3-1:0] p;

    begin

    p[ 0] = d[0] ;

    p[ 1] = d[0] ;

    p[ 2] = d[0] ;

    ecc_encode = p;

    end

endfunction



endmodule

