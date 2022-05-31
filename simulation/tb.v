
`include "../RTL/core/config.v"
`include "../RTL/core/defines.v"

`timescale 1ps/1ps
module TEST_TOP ();

reg i_clk=1;
reg i_rstn=1;

always  begin
    #1 i_clk = ~i_clk;
end
initial begin
    i_rstn = 1;
    #3 i_rstn = 0;
    #2 i_rstn = 1;
end

SOC_TOP u_SOC_TOP(
    .i_clk   ( i_clk   ),
    .i_rstn  ( i_rstn  ),

    .i_io_rx ( 1 ),
    .o_io_tx  (   ),
    .i_io_rx2 ( 1 ),
    .o_io_tx2  (   )
);




endmodule



