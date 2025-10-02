
module bus_delay_cg(/*AUTOARG*/
   // Outputs
   outbus,
   // Inputs
   clk, rst_n, en, inbus
   );
    parameter DELAY_CYCLES = 3;
    parameter BUS_WIDTH    = 8;
    parameter INIT_VAL     = {BUS_WIDTH{1'b0}};

    input                   clk;
    input                   rst_n;
    input                   en;
    input  [BUS_WIDTH-1:0]  inbus;
    output [BUS_WIDTH-1:0]  outbus;

//===============================================================================
// internal regs and wires
//===============================================================================
reg  [DELAY_CYCLES-1:0]     en_seq;//
reg  [(BUS_WIDTH-1):0]      delay_seq[(DELAY_CYCLES):0];//delay

//===============================================================================
// the main logic
//===============================================================================
assign outbus = delay_seq[DELAY_CYCLES];

always @(*)begin
    en_seq[0] = en;
    delay_seq[0] = inbus;
end

integer i;
integer j;

always @(posedge clk or negedge rst_n)begin
    if(~rst_n) begin
        for(i = 1; i < DELAY_CYCLES; i=i+1 ) begin
            en_seq[i] <= 1'b0;
        end
    end
    else begin
        for(j = 1; j < DELAY_CYCLES; j=j+1 ) begin
            en_seq[j] <= en_seq[j-1];
        end
    end
end

integer k;
integer l;

always @(posedge clk or negedge rst_n)begin
    if(~rst_n) begin
        for(k = 1; k <= DELAY_CYCLES; k=k+1 ) begin
            delay_seq[k] <= INIT_VAL;
        end
    end
    else begin
        for(l = 1; l <= DELAY_CYCLES; l=l+1 ) begin
            delay_seq[l] <= en_seq[l-1] ? delay_seq[l-1] : delay_seq[l];
        end
    end
end

endmodule

