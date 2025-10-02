
module ecc_9_top

#

(

    parameter DATA_WIDTH = 4,

    parameter PARITY_WIDTH = 4

)

(

    input   [   9-1:0]   data_in,

    output  [   9-1:0]   data_out,

    input   [   5-1:0]   parity_in,

    output  [   5-1:0]   parity_out,

    input   bypass,

    output  sbit_err,

    output  dbit_err

);



wire  [   5-1:0]   syndrome;

reg   [   9-1:0]   mask;

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

    5'b00000 : begin mask = 9'b000000000; error = 2'b00; end

    5'b10011 : begin mask = 9'b000000001; error = 2'b01; end

    5'b10101 : begin mask = 9'b000000010; error = 2'b01; end

    5'b10110 : begin mask = 9'b000000100; error = 2'b01; end

    5'b00111 : begin mask = 9'b000001000; error = 2'b01; end

    5'b11001 : begin mask = 9'b000010000; error = 2'b01; end

    5'b11010 : begin mask = 9'b000100000; error = 2'b01; end

    5'b01011 : begin mask = 9'b001000000; error = 2'b01; end

    5'b11100 : begin mask = 9'b010000000; error = 2'b01; end

    5'b01101 : begin mask = 9'b100000000; error = 2'b01; end

    5'b10000 : begin mask = 9'b000000000; error = 2'b01; end

    5'b01000 : begin mask = 9'b000000000; error = 2'b01; end

    5'b00100 : begin mask = 9'b000000000; error = 2'b01; end

    5'b00010 : begin mask = 9'b000000000; error = 2'b01; end

    5'b00001 : begin mask = 9'b000000000; error = 2'b01; end

    default : begin mask = 9'b000000000; error = 2'b10; end

    endcase

end



function [  5-1:0] ecc_encode;

    input [  9-1:0] d;

    reg   [  5-1:0] p;

    begin

    p[ 0] = d[0] + d[1] + d[3] + d[4] + d[6] + d[8] ;

    p[ 1] = d[0] + d[2] + d[3] + d[5] + d[6] ;

    p[ 2] = d[1] + d[2] + d[3] + d[7] + d[8] ;

    p[ 3] = d[4] + d[5] + d[6] + d[7] + d[8] ;

    p[ 4] = d[0] + d[1] + d[2] + d[4] + d[5] + d[7] ;

    ecc_encode = p;

    end

endfunction



endmodule

