






module CORE_TOP (
    input wire i_clk,
    input wire i_rstn,

    //外部储存器接口
    output wire[31:0] o_ribx_addr,
    output wire o_ribx_wrcs,//读写选择
    output wire[3:0] o_ribx_mask, //写掩码
    output wire[31:0] o_ribx_wdata, //写数据
    input wire[31:0] i_ribx_rdata, //读数据
    output wire o_ribx_req, //主机发出请求
    input wire i_ribx_gnt, //总线授权
    input wire i_ribx_rsp, //从机响应有效
    output wire o_ribx_rdy, //主机响应正常


    //外设接口
    output wire[31:0] o_ribp_addr,
    output wire o_ribp_wrcs,//读写选择
    output wire[3:0] o_ribp_mask, //写掩码
    output wire[31:0] o_ribp_wdata, //写数据
    input wire[31:0] i_ribp_rdata, //读数据
    output wire o_ribp_req, //主机发出请求
    input wire i_ribp_gnt, //总线授权
    input wire i_ribp_rsp, //从机响应有效
    output wire o_ribp_rdy //主机响应正常
);

//ibus
wire[31:0] rib_addr0;
wire rib_wrcs0;
wire[3:0] rib_mask0;
wire[31:0] rib_wdata0;
wire[31:0] rib_rdata0;
wire rib_req0;
wire rib_gnt0;
wire rib_rsp0;
wire rib_rdy0;

//dbus
wire[31:0] rib_addr1;
wire rib_wrcs1;
wire[3:0] rib_mask1;
wire[31:0] rib_wdata1;
wire[31:0] rib_rdata1;
wire rib_req1;
wire rib_gnt1;
wire rib_rsp1;
wire rib_rdy1;


RITTER_TOP u_RITTER_TOP(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),
    //ibus
    .o_ribm_addr0  ( rib_addr0  ),
    .o_ribm_wrcs0  ( rib_wrcs0  ),
    .o_ribm_mask0  ( rib_mask0  ),
    .o_ribm_wdata0 ( rib_wdata0 ),
    .i_ribm_rdata0 ( rib_rdata0 ),
    .o_ribm_req0   ( rib_req0   ),
    .i_ribm_gnt0   ( rib_gnt0   ),
    .i_ribm_rsp0   ( rib_rsp0   ),
    .o_ribm_rdy0   ( rib_rdy0   ),
    //dbus
    .o_ribm_addr1  ( rib_addr1  ),
    .o_ribm_wrcs1  ( rib_wrcs1  ),
    .o_ribm_mask1  ( rib_mask1  ),
    .o_ribm_wdata1 ( rib_wdata1 ),
    .i_ribm_rdata1 ( rib_rdata1 ),
    .o_ribm_req1   ( rib_req1   ),
    .i_ribm_gnt1   ( rib_gnt1   ),
    .i_ribm_rsp1   ( rib_rsp1   ),
    .o_ribm_rdy1   ( rib_rdy1   )
);

/************************************************************/
//取指从机选择
/************************************************************/

//ITCM
wire[31:0] arb0_addr0;//ITCM
wire arb0_wrcs0;
wire[3:0] arb0_mask0;
wire[31:0] arb0_wdata0;
wire[31:0] arb0_rdata0;
wire arb0_req0;
wire arb0_gnt0;
wire arb0_rsp0;
wire arb0_rdy0;

wire[31:0] arb0_addr1;//SDRAM
wire arb0_wrcs1;
wire[3:0] arb0_mask1;
wire[31:0] arb0_wdata1;
wire[31:0] arb0_rdata1;
wire arb0_req1;
wire arb0_gnt1;
wire arb0_rsp1;
wire arb0_rdy1;

//取指从机选择
//地址:
//ITCM:0x00
//SDRAM:0x02
SLAVE_SEL#(
    .slaves       ( 2 )
)RIB_ARB0(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_slave_mask ( {8'h02,8'h00} ),

    .i_ribm_addr  ( rib_addr0  ),
    .i_ribm_wrcs  ( rib_wrcs0  ),
    .i_ribm_mask  ( rib_mask0  ),
    .i_ribm_wdata ( rib_wdata0 ),
    .o_ribm_rdata ( rib_rdata0 ),
    .i_ribm_req   ( rib_req0   ),
    .o_ribm_gnt   ( rib_gnt0   ),
    .o_ribm_rsp   ( rib_rsp0   ),
    .i_ribm_rdy   ( rib_rdy0   ),

    .o_ribs_addr  ( {arb0_addr1,arb0_addr0}  ),
    .o_ribs_wrcs  ( {arb0_wrcs1,arb0_wrcs0}  ),
    .o_ribs_mask  ( {arb0_mask1,arb0_mask0}  ),
    .o_ribs_wdata ( {arb0_wdata1,arb0_wdata0}  ),
    .i_ribs_rdata ( {arb0_rdata1,arb0_rdata0}  ),
    .o_ribs_req   ( {arb0_req1,arb0_req0}  ),
    .i_ribs_gnt   ( {arb0_gnt1,arb0_gnt0}  ),
    .i_ribs_rsp   ( {arb0_rsp1,arb0_rsp0}  ),
    .o_ribs_rdy   ( {arb0_rdy1,arb0_rdy0}  ),

    //无效mmm
    .o_ribd_addr  (  ),
    .o_ribd_wrcs  (  ),
    .o_ribd_mask  (  ), 
    .o_ribd_wdata (  ), 
    .i_ribd_rdata ( 0 ),
    .o_ribd_req   (   ), 
    .i_ribd_gnt   ( 0  ),  
    .i_ribd_rsp   ( 0  ),
    .o_ribd_rdy   (  )
);


/************************************************************/
//访存从机选择
/************************************************************/


wire[31:0] arb1_addr0;//ITCM
wire arb1_wrcs0;
wire[3:0] arb1_mask0;
wire[31:0] arb1_wdata0;
wire[31:0] arb1_rdata0;
wire arb1_req0;
wire arb1_gnt0;
wire arb1_rsp0;
wire arb1_rdy0;

wire[31:0] arb1_addr1;//DTCM
wire arb1_wrcs1;
wire[3:0] arb1_mask1;
wire[31:0] arb1_wdata1;
wire[31:0] arb1_rdata1;
wire arb1_req1;
wire arb1_gnt1;
wire arb1_rsp1;
wire arb1_rdy1;


wire[31:0] arb1_addr2;//SDRAM
wire arb1_wrcs2;
wire[3:0] arb1_mask2;
wire[31:0] arb1_wdata2;
wire[31:0] arb1_rdata2;
wire arb1_req2;
wire arb1_gnt2;
wire arb1_rsp2;
wire arb1_rdy2;


//访存从机选择
//地址:
//ITCM:0x00
//DTCM:0x01
//SDRAM:0x02
SLAVE_SEL#(
    .slaves       ( 3 )
)RIB_ARB1(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_slave_mask ( {8'h02,8'h01,8'h00} ),

    .i_ribm_addr  ( rib_addr1  ),
    .i_ribm_wrcs  ( rib_wrcs1  ),
    .i_ribm_mask  ( rib_mask1  ),
    .i_ribm_wdata ( rib_wdata1 ),
    .o_ribm_rdata ( rib_rdata1 ),
    .i_ribm_req   ( rib_req1   ),
    .o_ribm_gnt   ( rib_gnt1   ),
    .o_ribm_rsp   ( rib_rsp1   ),
    .i_ribm_rdy   ( rib_rdy1   ),

    .o_ribs_addr  ( {arb1_addr2 ,arb1_addr1 ,arb1_addr0}  ),
    .o_ribs_wrcs  ( {arb1_wrcs2 ,arb1_wrcs1 ,arb1_wrcs0}  ),
    .o_ribs_mask  ( {arb1_mask2 ,arb1_mask1 ,arb1_mask0}  ),
    .o_ribs_wdata ( {arb1_wdata2,arb1_wdata1,arb1_wdata0}  ),
    .i_ribs_rdata ( {arb1_rdata2,arb1_rdata1,arb1_rdata0}  ),
    .o_ribs_req   ( {arb1_req2  ,arb1_req1  ,arb1_req0}  ),
    .i_ribs_gnt   ( {arb1_gnt2  ,arb1_gnt1  ,arb1_gnt0}  ),
    .i_ribs_rsp   ( {arb1_rsp2  ,arb1_rsp1  ,arb1_rsp0}  ),
    .o_ribs_rdy   ( {arb1_rdy2  ,arb1_rdy1  ,arb1_rdy0}  ),

    //外设接口
    .o_ribd_addr  ( o_ribp_addr ),
    .o_ribd_wrcs  ( o_ribp_wrcs ),
    .o_ribd_mask  ( o_ribp_mask ), 
    .o_ribd_wdata ( o_ribp_wdata ), 
    .i_ribd_rdata ( i_ribp_rdata ),
    .o_ribd_req   ( o_ribp_req  ), 
    .i_ribd_gnt   ( i_ribp_gnt  ),  
    .i_ribd_rsp   ( i_ribp_rsp  ),
    .o_ribd_rdy   ( o_ribp_rdy )
);


/************************************************************/
//ITCM访问仲裁
/************************************************************/

wire[31:0] arb2_addr0;
wire arb2_wrcs0;
wire[3:0] arb2_mask0;
wire[31:0] arb2_wdata0;
wire[31:0] arb2_rdata0;
wire arb2_req0;
wire arb2_gnt0;
wire arb2_rsp0;
wire arb2_rdy0;


//0号主机优先级最低
//ITCM主机选择
MASTER_SEL#(
    .masters      ( 2 )
)RIB_ARB2(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribm_addr  ( {arb1_addr0 ,arb0_addr0}  ),
    .i_ribm_wrcs  ( {arb1_wrcs0 ,arb0_wrcs0}  ),
    .i_ribm_mask  ( {arb1_mask0 ,arb0_mask0}  ),
    .i_ribm_wdata ( {arb1_wdata0,arb0_wdata0}  ),
    .o_ribm_rdata ( {arb1_rdata0,arb0_rdata0}  ),
    .i_ribm_req   ( {arb1_req0  ,arb0_req0}  ),  
    .o_ribm_gnt   ( {arb1_gnt0  ,arb0_gnt0}  ),   
    .o_ribm_rsp   ( {arb1_rsp0  ,arb0_rsp0}  ),  
    .i_ribm_rdy   ( {arb1_rdy0  ,arb0_rdy0}  ),


    .o_ribs_addr  ( arb2_addr0  ),
    .o_ribs_wrcs  ( arb2_wrcs0  ),
    .o_ribs_mask  ( arb2_mask0  ),
    .o_ribs_wdata ( arb2_wdata0 ),
    .i_ribs_rdata ( arb2_rdata0 ),
    .o_ribs_req   ( arb2_req0   ),
    .i_ribs_gnt   ( arb2_gnt0   ),
    .i_ribs_rsp   ( arb2_rsp0   ),
    .o_ribs_rdy   ( arb2_rdy0   )
);

/************************************************************/
//SDRAM访问仲裁
/************************************************************/

//0号主机优先级最低
//SDRAM主机选择
MASTER_SEL#(
    .masters      ( 2 )
)RIB_ARB3(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribm_addr  ( {arb1_addr2,arb0_addr1}  ),
    .i_ribm_wrcs  ( {arb1_wrcs2,arb0_wrcs1}  ),
    .i_ribm_mask  ( {arb1_mask2,arb0_mask1}  ),
    .i_ribm_wdata ( {arb1_wdata2,arb0_wdata1}  ),
    .o_ribm_rdata ( {arb1_rdata2,arb0_rdata1}  ),
    .i_ribm_req   ( {arb1_req2,arb0_req1}  ),  
    .o_ribm_gnt   ( {arb1_gnt2,arb0_gnt1}  ),   
    .o_ribm_rsp   ( {arb1_rsp2,arb0_rsp1}  ),  
    .i_ribm_rdy   ( {arb1_rdy2,arb0_rdy1}  ),


    .o_ribs_addr  ( o_ribx_addr  ),
    .o_ribs_wrcs  ( o_ribx_wrcs  ),
    .o_ribs_mask  ( o_ribx_mask  ),
    .o_ribs_wdata ( o_ribx_wdata ),
    .i_ribs_rdata ( i_ribx_rdata ),
    .o_ribs_req   ( o_ribx_req   ),
    .i_ribs_gnt   ( i_ribx_gnt   ),
    .i_ribs_rsp   ( i_ribx_rsp   ),
    .o_ribs_rdy   ( o_ribx_rdy   )
);

/************************************************************/
//ITCM与DTCM
/************************************************************/

ITCM_CTRL u_ITCM_CTRL(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribs_addr  ( arb2_addr0  ),
    .i_ribs_wrcs  ( arb2_wrcs0  ),
    .i_ribs_mask  ( arb2_mask0  ),
    .i_ribs_wdata ( arb2_wdata0 ),
    .o_ribs_rdata ( arb2_rdata0 ),
    .i_ribs_req   ( arb2_req0   ),
    .o_ribs_gnt   ( arb2_gnt0   ),
    .o_ribs_rsp   ( arb2_rsp0   ),
    .i_ribs_rdy   ( arb2_rdy0   )
);




DTCM_CTRL u_DTCM_CTRL(
    .i_clk        ( i_clk        ),
    .i_rstn       ( i_rstn       ),

    .i_ribs_addr  ( arb1_addr1  ),
    .i_ribs_wrcs  ( arb1_wrcs1  ),
    .i_ribs_mask  ( arb1_mask1  ),
    .i_ribs_wdata ( arb1_wdata1 ),
    .o_ribs_rdata ( arb1_rdata1 ),
    .i_ribs_req   ( arb1_req1   ),
    .o_ribs_gnt   ( arb1_gnt1   ),
    .o_ribs_rsp   ( arb1_rsp1   ),
    .i_ribs_rdy   ( arb1_rdy1   )
);




endmodule