





//外设接口
//外设地址起始:
//串口:0xf1
module PERIPH_TOP(
    input wire i_clk,
    input wire i_adc_clk,
    input wire i_rstn,
    //RIB接口
    input wire[31:0] i_ribm_addr,//主地址线
    input wire i_ribm_wrcs,//读写选择
    input wire[3:0] i_ribm_mask, //掩码
    input wire[31:0] i_ribm_wdata, //写数据
    output wire[31:0] o_ribm_rdata,

    input wire i_ribm_req, 
    output wire o_ribm_gnt, 
    output wire o_ribm_rsp, 
    input wire i_ribm_rdy,

    //io接口
    input wire i_io_rx,
    output wire o_io_tx,
    input wire i_io_rx2,
    output wire o_io_tx2,
    output wire[23:0] o_gpio_mode,
    input wire[23:0] i_gpio_in,
    output wire[23:0] o_gpio_out,
    output wire o_pwm

);


wire[31:0] usart_rib_addr;
wire usart_rib_wrcs;
wire[3:0] usart_rib_mask;
wire[31:0] usart_rib_wdata;
wire[31:0] usart_rib_rdata;
wire usart_rib_req;
wire usart_rib_gnt;
wire usart_rib_rsp;
wire usart_rib_rdy;


USART2RIB u_USART2RIB(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribs_addr  ( usart_rib_addr  ),
    .i_ribs_wrcs  ( usart_rib_wrcs  ),
    .i_ribs_mask  ( usart_rib_mask  ),
    .i_ribs_wdata ( usart_rib_wdata ),
    .o_ribs_rdata ( usart_rib_rdata ),
    .i_ribs_req   ( usart_rib_req   ),
    .o_ribs_gnt   ( usart_rib_gnt   ),
    .o_ribs_rsp   ( usart_rib_rsp   ),
    .i_ribs_rdy   ( usart_rib_rdy   ),

    .i_rx         ( i_io_rx         ),
    .o_tx         ( o_io_tx         ),
    .i_rx2        ( i_io_rx2         ),
    .o_tx2        ( o_io_tx2         )
);


wire[31:0] timer_ribs_addr;
wire timer_ribs_wrcs;
wire[3:0] timer_ribs_mask;
wire[31:0] timer_ribs_wdata;
wire[31:0] timer_ribs_rdata;
wire timer_ribs_req;
wire timer_ribs_gnt;
wire timer_ribs_rsp;
wire timer_ribs_rdy;


TIMER2RIB u_TIMER2RIB(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribs_addr  ( timer_ribs_addr  ),
    .i_ribs_wrcs  ( timer_ribs_wrcs  ),
    .i_ribs_mask  ( timer_ribs_mask  ),
    .i_ribs_wdata ( timer_ribs_wdata ),
    .o_ribs_rdata ( timer_ribs_rdata ),
    .i_ribs_req   ( timer_ribs_req   ),
    .o_ribs_gnt   ( timer_ribs_gnt   ),
    .o_ribs_rsp   ( timer_ribs_rsp   ),
    .i_ribs_rdy   ( timer_ribs_rdy   )
);



wire[31:0] gpio_ribs_addr;
wire gpio_ribs_wrcs;
wire[3:0] gpio_ribs_mask;
wire[31:0] gpio_ribs_wdata;
wire[31:0] gpio_ribs_rdata;
wire gpio_ribs_req;
wire gpio_ribs_gnt;
wire gpio_ribs_rsp;
wire gpio_ribs_rdy;


GPIO2RIB u_GPIO2RIB(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribs_addr  ( gpio_ribs_addr  ),
    .i_ribs_wrcs  ( gpio_ribs_wrcs  ),
    .i_ribs_mask  ( gpio_ribs_mask  ),
    .i_ribs_wdata ( gpio_ribs_wdata ),
    .o_ribs_rdata ( gpio_ribs_rdata ),
    .i_ribs_req   ( gpio_ribs_req   ),
    .o_ribs_gnt   ( gpio_ribs_gnt   ),
    .o_ribs_rsp   ( gpio_ribs_rsp   ),
    .i_ribs_rdy   ( gpio_ribs_rdy   ),

    .o_gpio_mode  ( o_gpio_mode         ),
    .i_gpio_in    ( i_gpio_in    ),
    .o_gpio_out   ( o_gpio_out   )
);


wire[31:0] pwm_ribs_addr;
wire pwm_ribs_wrcs;
wire[3:0] pwm_ribs_mask;
wire[31:0] pwm_ribs_wdata;
wire[31:0] pwm_ribs_rdata;
wire pwm_ribs_req;
wire pwm_ribs_gnt;
wire pwm_ribs_rsp;
wire pwm_ribs_rdy;

PWM2RIB u_PWM2RIB(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),
    .i_ribs_addr  ( pwm_ribs_addr  ),
    .i_ribs_wrcs  ( pwm_ribs_wrcs  ),
    .i_ribs_mask  ( pwm_ribs_mask  ),
    .i_ribs_wdata ( pwm_ribs_wdata ),
    .o_ribs_rdata ( pwm_ribs_rdata ),
    .i_ribs_req   ( pwm_ribs_req   ),
    .o_ribs_gnt   ( pwm_ribs_gnt   ),
    .o_ribs_rsp   ( pwm_ribs_rsp   ),
    .i_ribs_rdy   ( pwm_ribs_rdy   ),
    .o_pwm        ( o_pwm        )
);


wire[31:0] adc_ribs_addr;
wire adc_ribs_wrcs;
wire[3:0] adc_ribs_mask;
wire[31:0] adc_ribs_wdata;
wire[31:0] adc_ribs_rdata;
wire adc_ribs_req;
wire adc_ribs_gnt;
wire adc_ribs_rsp;
wire adc_ribs_rdy;

ADC2RIB u_ADC2RIB(
    .i_clk        ( i_clk        ),
    .i_adc_clk    ( i_adc_clk    ),
    .i_rstn       ( i_rstn       ),
    .i_ribs_addr  ( adc_ribs_addr  ),
    .i_ribs_wrcs  ( adc_ribs_wrcs  ),
    .i_ribs_mask  ( adc_ribs_mask  ),
    .i_ribs_wdata ( adc_ribs_wdata ),
    .o_ribs_rdata ( adc_ribs_rdata ),
    .i_ribs_req   ( adc_ribs_req   ),
    .o_ribs_gnt   ( adc_ribs_gnt   ),
    .o_ribs_rsp   ( adc_ribs_rsp   ),
    .i_ribs_rdy   ( adc_ribs_rdy   )
);



//外设选择
SLAVE_SEL#(
    .slaves       ( 5 )
)u_SLAVE_SEL(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),
    
    .i_slave_mask ( {8'hf4,8'hf3,8'hf2,8'hf1,8'hf0} ),

    .i_ribm_addr  ( i_ribm_addr  ),
    .i_ribm_wrcs  ( i_ribm_wrcs  ),
    .i_ribm_mask  ( i_ribm_mask  ),
    .i_ribm_wdata ( i_ribm_wdata ),
    .o_ribm_rdata ( o_ribm_rdata ),
    .i_ribm_req   ( i_ribm_req   ),
    .o_ribm_gnt   ( o_ribm_gnt   ),
    .o_ribm_rsp   ( o_ribm_rsp   ),
    .i_ribm_rdy   ( i_ribm_rdy   ),

    .o_ribs_addr  ( {adc_ribs_addr, pwm_ribs_addr, timer_ribs_addr ,usart_rib_addr, gpio_ribs_addr }  ),
    .o_ribs_wrcs  ( {adc_ribs_wrcs, pwm_ribs_wrcs, timer_ribs_wrcs ,usart_rib_wrcs, gpio_ribs_wrcs }  ),
    .o_ribs_mask  ( {adc_ribs_mask, pwm_ribs_mask, timer_ribs_mask ,usart_rib_mask, gpio_ribs_mask}  ),
    .o_ribs_wdata ( {adc_ribs_wdata, pwm_ribs_wdata, timer_ribs_wdata,usart_rib_wdata, gpio_ribs_wdata} ),
    .i_ribs_rdata ( {adc_ribs_rdata, pwm_ribs_rdata, timer_ribs_rdata,usart_rib_rdata, gpio_ribs_rdata} ),
    .o_ribs_req   ( {adc_ribs_req, pwm_ribs_req, timer_ribs_req  ,usart_rib_req, gpio_ribs_req}   ),
    .i_ribs_gnt   ( {adc_ribs_gnt, pwm_ribs_gnt, timer_ribs_gnt  ,usart_rib_gnt, gpio_ribs_gnt}   ),
    .i_ribs_rsp   ( {adc_ribs_rsp, pwm_ribs_rsp, timer_ribs_rsp  ,usart_rib_rsp, gpio_ribs_rsp}   ),
    .o_ribs_rdy   ( {adc_ribs_rdy, pwm_ribs_rdy, timer_ribs_rdy  ,usart_rib_rdy, gpio_ribs_rdy}   ),

    .o_ribd_addr  (   ),
    .o_ribd_wrcs  (   ),
    .o_ribd_mask  (   ),
    .o_ribd_wdata (  ),
    .i_ribd_rdata ( 32'b0 ),
    .o_ribd_req   (    ),
    .i_ribd_gnt   ( 1'b0   ),
    .i_ribd_rsp   ( 1'b0   ),
    .o_ribd_rdy   (    )
);












endmodule