
`include "../core/config.v"
`include "../core/defines.v"

module SOC_TOP (
    input wire i_clk,
    input wire i_rstn,

    input wire i_io_rx,
    output wire o_io_tx,
    input wire i_io_rx2,
    output wire o_io_tx2,
    inout wire[3:0] io_gpio,
    output wire o_pwm
);



wire extlock;//lock信号为高代表输出时钟稳定
wire sysclk;


`ifndef SIMULATION

// pll u_pll(
//     .refclk  ( i_clk  ),//i
//     .reset   ( ~i_rstn    ),//i
//     .extlock ( extlock ),//o
//     .clk0_out( sysclk )//o_clk 84mhz
// ); 

pll u_pll(
    .refclk   ( i_clk   ),
    .reset    ( ~i_rstn    ),
    .extlock  ( extlock  ),
    .clk0_out (  ),// 72mhz
    .clk1_out ( sysclk )//80mhz
);

`else

assign extlock = 1;
assign sysclk = i_clk;

`endif



wire reset;
internal_reset u_internal_reset(
    .i_clk  ( i_clk  ),
    .i_rstn ( i_rstn & extlock ),
    .o_reset  ( reset  )
);




wire[31:0] sdram_addr;
wire sdram_wrcs;
wire[3:0] sdram_mask;
wire[31:0] sdram_wdata;
wire[31:0] sdram_rdata;
wire sdram_req;
wire sdram_gnt;
wire sdram_rsp;
wire sdram_rdy;





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
    .i_clk        ( sysclk        ),
    .i_rstn       ( reset       ),

    .o_ribx_addr  ( sdram_addr  ),
    .o_ribx_wrcs  ( sdram_wrcs  ),
    .o_ribx_mask  ( sdram_mask  ),
    .o_ribx_wdata ( sdram_wdata ),
    .i_ribx_rdata ( sdram_rdata ),
    .o_ribx_req   ( sdram_req   ),
    .i_ribx_gnt   ( sdram_gnt   ),
    .i_ribx_rsp   ( sdram_rsp   ),
    .o_ribx_rdy   ( sdram_rdy   ),

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

`ifdef USE_SDRAM

SDRAM2RIB u_SDRAM2RIB(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribs_addr  ( sdram_addr   ),
    .i_ribs_wrcs  ( sdram_wrcs   ),
    .i_ribs_mask  ( sdram_mask   ),
    .i_ribs_wdata ( sdram_wdata  ),
    .o_ribs_rdata ( sdram_rdata  ),
    .i_ribs_req   ( sdram_req    ),
    .o_ribs_gnt   ( sdram_gnt    ),
    .o_ribs_rsp   ( sdram_rsp    ),
    .i_ribs_rdy   ( sdram_rdy    )
);

`else 
assign sdram_rdata=0;
assign sdram_gnt=0;
assign sdram_rsp=0;
`endif




wire[23:0] gpio_mode;
wire[23:0] gpio_out;
wire[23:0] gpio_in;


PERIPH_TOP u_PERIPH_TOP(
    .i_clk        ( sysclk        ),
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
    .o_io_tx      ( o_io_tx      ),
    .i_io_rx2      ( i_io_rx2      ),
    .o_io_tx2      ( o_io_tx2      ),
    .o_gpio_mode    (gpio_mode),
    .i_gpio_in      (gpio_in),
    .o_gpio_out     (gpio_out),
    .o_pwm         (o_pwm)
);



generate
    genvar i;
    for(i=0;i<4;i=i+1)begin
        //1为输出模式
        assign io_gpio[i] = gpio_mode[i] ? gpio_out[i] : 1'bz;
        assign gpio_in[i] = io_gpio[i];
    end
    for(i=4;i<24;i=i+1)begin
        assign gpio_in[i] = 0;
    end
endgenerate






endmodule



