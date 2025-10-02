
module bus_delay_no_rst(/*AUTOARG*/
   // Outputs
   outbus,
   // Inputs
   clk, inbus
   );
    parameter DELAY_CYCLES = 3;
    parameter BUS_WIDTH    = 8;

    input                   clk;
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

always @(posedge clk)begin
    for(i = 1; i <= DELAY_CYCLES; i=i+1 ) begin
        delay_seq[i] <= delay_seq[i-1];
    end
end

endmodule
