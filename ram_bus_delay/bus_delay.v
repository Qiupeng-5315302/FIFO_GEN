
module bus_delay(/*AUTOARG*/
   // Outputs
   outbus,
   // Inputs
   clk, rst_n, inbus
   );
    parameter DELAY_CYCLES = 3;
    parameter BUS_WIDTH    = 8;
    parameter INIT_VAL     = {BUS_WIDTH{1'b0}};

    input                   clk;
    input                   rst_n;
    input  [BUS_WIDTH-1:0]  inbus;
    output [BUS_WIDTH-1:0]  outbus;

//===============================================================================
// internal regs and wires
//===============================================================================
reg  [(BUS_WIDTH-1):0]      delay_seq[(DELAY_CYCLES):0];//delay

//===============================================================================
// the main logic
//===============================================================================
assign outbus = delay_seq[DELAY_CYCLES];

always @(*)begin
    delay_seq[0] = inbus;
end

integer i;
integer j;

always @(posedge clk or negedge rst_n)begin
    if(~rst_n) begin
        for(i = 1; i <= DELAY_CYCLES; i=i+1 ) begin
            delay_seq[i] <= INIT_VAL;
        end
    end
    else begin
        for(j = 1; j <= DELAY_CYCLES; j=j+1 ) begin
            delay_seq[j] <= delay_seq[j-1];
        end
    end
end

endmodule

