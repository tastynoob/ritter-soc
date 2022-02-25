


/*
总线端：
output wire[31:0] o_ribm_addr,
output wire o_ribm_wrcs,//读写选择
output wire[3:0] o_ribm_wmask, //写掩码
output wire[31:0] o_ribm_wdata, //写数据
input wire[31:0] i_ribm_rdata, //读数据

output wire o_ribm_req, //发出请求
input wire i_ribm_gnt, //总线授权
input wire i_ribm_rsp, //响应有效
output wire o_ribm_rdy, //主机正常 0代表主机无法接收数据
input wire i_ribm_rsp_err //响应错误



关于16位指令处理：
放在姨妈段进行合并，取指段只需要不断取出32位数据即可
 
*/

//只允许单事务传输

`include "config.v"

module IFU (
    input wire i_clk,
    input wire i_rstn,

    //允许取指
    input wire i_fetch_vld,

    //分支预测
    input wire i_bpu_taken,
    input wire[`xlen_def] i_bpu_jaddr,
    //取指跳转
    input wire i_exu_taken,
    input wire[`xlen_def] i_exu_jaddr,
    
    //传递给下一级
    output wire o_data_vld,//数据有效
    output wire[`xlen_def] o_iaddr,
    output wire[`ilen_def] o_data,


    //RIB总线主机
    output wire[31:0] o_ribm_addr,
    output wire o_ribm_wrcs,//读写选择
    output wire[3:0] o_ribm_mask, //写掩码
    output wire[31:0] o_ribm_wdata, //写数据
    input wire[31:0] i_ribm_rdata, //读数据
    output wire o_ribm_req, //主机发出请求
    input wire i_ribm_gnt, //总线授权
    input wire i_ribm_rsp, //从机响应有效
    output wire o_ribm_rdy //主机响应正常
);

    wire jump_flag;
    wire[`xlen_def] jump_addr;
    IFU_BJU u_IFU_BJU(
        .i_clk       ( i_clk       ),
        .i_rstn      ( i_rstn      ),

        .i_bpu_taken ( i_bpu_taken ),
        .i_bpu_jaddr ( i_bpu_jaddr ),

        .i_exu_taken ( i_exu_taken ),
        .i_exu_jaddr ( i_exu_jaddr ),

        .o_jump      ( jump_flag   ),
        .o_jump_addr ( jump_addr   )
    );

    wire pc_vld;
    wire access_vld;
    wire data_vld;
    wire[`xlen_def] fetch_addr;
    wire fifo_empty;

    IFU_PC u_IFU_PC(
        .i_clk        ( i_clk           ),
        .i_rstn       ( i_rstn          ),

        //当fifo不为空,代表已经握手成功
        //但发生了流水线暂停,代表当前握手无效,需要回溯
        .i_fetch_vld  ( i_fetch_vld     ),
        .i_fifo_empty ( fifo_empty        ),
        .i_pc_goback  ( o_iaddr         ),//暂停退回


        .i_pc_vld     ( pc_vld          ),
        .i_jump       ( jump_flag       ),
        .i_jump_addr  ( jump_addr       ),   
        .o_fetch_addr ( fetch_addr      )
    );


    IFU_FETCH u_IFU_FETCH(  
        .i_clk           ( i_clk            ),
        .i_rstn          ( i_rstn           ),

        .i_fetch_addr    ( fetch_addr       ),
        .i_fetch_vld     ( i_fetch_vld      ),
        .i_jump_flag     ( jump_flag        ),

        .o_pc_vld        ( pc_vld           ),
        .o_access_vld    ( access_vld       ),
        .o_data_vld      ( data_vld         ),
        .o_data          ( o_data           ),
        //rib总线
        .o_ribm_addr     ( o_ribm_addr      ),
        .o_ribm_wrcs     ( o_ribm_wrcs      ),
        .o_ribm_mask     ( o_ribm_mask      ),
        .o_ribm_wdata    ( o_ribm_wdata     ),
        .i_ribm_rdata    ( i_ribm_rdata     ),
        
        .o_ribm_req      ( o_ribm_req       ),
        .i_ribm_gnt      ( i_ribm_gnt       ),
        .i_ribm_rsp      ( i_ribm_rsp       ),
        .o_ribm_rdy      ( o_ribm_rdy       )
    );


    parameter fifo_dpth = 1;

    
    wire[$clog2(fifo_dpth):0] fifo_cnt;
    //记录握手请求的数量
    //成功握手一次压入，传输成功一次弹出
    //发生跳转时,应舍弃上次握手获取的指令
    IFU_FIFO#(
        .unitwid    ( 32 ),
        .unitdpth   ( fifo_dpth ) 
    )u_IFU_FIFO(
        .i_clk      ( i_clk         ),
        .i_rstn     ( i_rstn  ),
       
        .i_flush    (  0  ),

        //当发送一次握手信号，压入当前pc
        .i_wen      ( pc_vld        ),
        .i_unitdata ( fetch_addr    ),


        //当取指完成,弹出第一个pc作为当前指令的pc
        .i_ren      ( access_vld    ), 
        .o_unitdata ( o_iaddr    ),
        .o_empty    ( fifo_empty ),
        .o_fifo_cnt ( fifo_cnt   )
    );





    //当jump_data_vld为1时,即使下次data_vld为1，也不能接受数据
    //当jump_data_vld为0时
    assign o_data_vld = i_fetch_vld & data_vld & (~fifo_empty); //fifo不为空
    //& (jump_data_vld ? 0 : (~jump_flag));
    //assign o_data_vld = i_fetch_vld & data_vld & (~jump_flag);

endmodule