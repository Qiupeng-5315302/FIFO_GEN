
module ecc_4_top

#

(

    parameter DATA_WIDTH = 4,

    parameter PARITY_WIDTH = 4

)

(

    input   [   4-1:0]   data_in,

    output  [   4-1:0]   data_out,

    input   [   4-1:0]   parity_in,

    output  [   4-1:0]   parity_out,

    input   bypass,

    output  sbit_err,

    output  dbit_err

);



wire  [   4-1:0]   syndrome;

reg   [   4-1:0]   mask;

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

    4'b0000 : begin mask = 4'b0000; error = 2'b00; end

    4'b1011 : begin mask = 4'b0001; error = 2'b01; end

    4'b1101 : begin mask = 4'b0010; error = 2'b01; end

    4'b1110 : begin mask = 4'b0100; error = 2'b01; end

    4'b0111 : begin mask = 4'b1000; error = 2'b01; end

    4'b1000 : begin mask = 4'b0000; error = 2'b01; end

    4'b0100 : begin mask = 4'b0000; error = 2'b01; end

    4'b0010 : begin mask = 4'b0000; error = 2'b01; end

    4'b0001 : begin mask = 4'b0000; error = 2'b01; end

    default : begin mask = 4'b0000; error = 2'b10; end

    endcase

end



function [  4-1:0] ecc_encode;

    input [  4-1:0] d;

    reg   [  4-1:0] p;

    begin

    p[ 0] = d[0] + d[1] + d[3] ;

    p[ 1] = d[0] + d[2] + d[3] ;

    p[ 2] = d[1] + d[2] + d[3] ;

    p[ 3] = d[0] + d[1] + d[2] ;

    ecc_encode = p;

    end

endfunction



endmodule

