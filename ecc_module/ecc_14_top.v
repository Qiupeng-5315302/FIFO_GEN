
module ecc_14_top

#

(

    parameter DATA_WIDTH = 4,

    parameter PARITY_WIDTH = 4

)

(

    input   [  14-1:0]   data_in,

    output  [  14-1:0]   data_out,

    input   [   6-1:0]   parity_in,

    output  [   6-1:0]   parity_out,

    input   bypass,

    output  sbit_err,

    output  dbit_err

);



wire  [   6-1:0]   syndrome;

reg   [  14-1:0]   mask;

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

    6'b000000 : begin mask = 14'b00000000000000; error = 2'b00; end

    6'b100011 : begin mask = 14'b00000000000001; error = 2'b01; end

    6'b100101 : begin mask = 14'b00000000000010; error = 2'b01; end

    6'b100110 : begin mask = 14'b00000000000100; error = 2'b01; end

    6'b000111 : begin mask = 14'b00000000001000; error = 2'b01; end

    6'b101001 : begin mask = 14'b00000000010000; error = 2'b01; end

    6'b101010 : begin mask = 14'b00000000100000; error = 2'b01; end

    6'b001011 : begin mask = 14'b00000001000000; error = 2'b01; end

    6'b101100 : begin mask = 14'b00000010000000; error = 2'b01; end

    6'b001101 : begin mask = 14'b00000100000000; error = 2'b01; end

    6'b001110 : begin mask = 14'b00001000000000; error = 2'b01; end

    6'b101111 : begin mask = 14'b00010000000000; error = 2'b01; end

    6'b110001 : begin mask = 14'b00100000000000; error = 2'b01; end

    6'b110010 : begin mask = 14'b01000000000000; error = 2'b01; end

    6'b010011 : begin mask = 14'b10000000000000; error = 2'b01; end

    6'b100000 : begin mask = 14'b00000000000000; error = 2'b01; end

    6'b010000 : begin mask = 14'b00000000000000; error = 2'b01; end

    6'b001000 : begin mask = 14'b00000000000000; error = 2'b01; end

    6'b000100 : begin mask = 14'b00000000000000; error = 2'b01; end

    6'b000010 : begin mask = 14'b00000000000000; error = 2'b01; end

    6'b000001 : begin mask = 14'b00000000000000; error = 2'b01; end

    default : begin mask = 14'b00000000000000; error = 2'b10; end

    endcase

end



function [  6-1:0] ecc_encode;

    input [ 14-1:0] d;

    reg   [  6-1:0] p;

    begin

    p[ 0] = d[0] + d[1] + d[3] + d[4] + d[6] + d[8] + d[10] + d[11] + d[13] ;

    p[ 1] = d[0] + d[2] + d[3] + d[5] + d[6] + d[9] + d[10] + d[12] + d[13] ;

    p[ 2] = d[1] + d[2] + d[3] + d[7] + d[8] + d[9] + d[10] ;

    p[ 3] = d[4] + d[5] + d[6] + d[7] + d[8] + d[9] + d[10] ;

    p[ 4] = d[11] + d[12] + d[13] ;

    p[ 5] = d[0] + d[1] + d[2] + d[4] + d[5] + d[7] + d[10] + d[11] + d[12] ;

    ecc_encode = p;

    end

endfunction



endmodule

