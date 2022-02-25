
`include "../core/config.v"
`include "../core/defines.v"

module SOC_TOP (
    input wire i_clk,
    input wire i_rstn,

    input wire i_io_rx,
    output wire o_io_tx
);



wire extlock;//lock信号为高代表输出时钟稳定
wire clk_84mhz;
pll u_pll(
    .refclk  ( i_clk  ),//i
    .reset   ( ~i_rstn    ),//i
    .extlock ( extlock ),//o
    .clk0_out( clk_84mhz )//o_clk 84mhz
); 








wire reset;
internal_reset u_internal_reset(
    .i_clk  ( i_clk  ),
    .i_rstn ( i_rstn & extlock ),
    .o_reset  ( reset  )
);



wire[31:0] periph_addr;
wire periph_wrcs;
wire[3:0] periph_mask;
wire[31:0] periph_wdata;
wire[31:0] periph_rdata;
wire periph_req;
wire periph_gnt;
wire periph_rsp;
wire periph_rdy;


CORE_TOP u_CORE_TOP(
    .i_clk        ( clk_84mhz        ),
    .i_rstn       ( reset       ),

    .o_ribx_addr  (   ),
    .o_ribx_wrcs  (   ),
    .o_ribx_mask  (   ),
    .o_ribx_wdata (  ),
    .i_ribx_rdata ( 0 ),
    .o_ribx_req   (    ),
    .i_ribx_gnt   ( 0   ),
    .i_ribx_rsp   ( 0   ),
    .o_ribx_rdy   (    ),

    .o_ribp_addr  ( periph_addr  ),
    .o_ribp_wrcs  ( periph_wrcs  ),
    .o_ribp_mask  ( periph_mask  ),
    .o_ribp_wdata ( periph_wdata ),
    .i_ribp_rdata ( periph_rdata ),
    .o_ribp_req   ( periph_req   ),
    .i_ribp_gnt   ( periph_gnt   ),
    .i_ribp_rsp   ( periph_rsp   ),
    .o_ribp_rdy   ( periph_rdy   )
);



PERIPH_TOP u_PERIPH_TOP(
    .i_clk        ( clk_84mhz        ),
    .i_rstn       ( reset       ),

    .i_ribm_addr  ( periph_addr  ),
    .i_ribm_wrcs  ( periph_wrcs  ),
    .i_ribm_mask  ( periph_mask  ),
    .i_ribm_wdata ( periph_wdata ),
    .o_ribm_rdata ( periph_rdata ),
    .i_ribm_req   ( periph_req   ),
    .o_ribm_gnt   ( periph_gnt   ),
    .o_ribm_rsp   ( periph_rsp   ),
    .i_ribm_rdy   ( periph_rdy   ),


    .i_io_rx      ( i_io_rx      ),
    .o_io_tx      ( o_io_tx      )
);




endmodule



