
/*
负责从rom取出指令
并且处理取指对齐问题
输出真实指令



如果取指地址不与16位对齐，则产生取指异常


只有当握手成功后
访问成功才会认为有效

*/


`include "config.v"


//取指模块
//主要功能:取指与16位对齐取指
module IFU_FETCH (
    input wire i_clk,
    input wire i_rstn,

    //待取指PC
    input wire[`xlen_def] i_fetch_addr,
    //允许取指
    input wire i_fetch_vld,
    //发生跳转
    input wire i_jump_flag,

    //握手完成，允许pc变化
    output wire o_pc_vld,
    //访问完成
    output wire o_access_vld,
    //握手完成,并且访问成功
    output wire o_data_vld,

    //rib读取的指令
    output wire[`ilen_def] o_data,


    //连接RIB总线
    output wire[31:0] o_ribm_addr,
    output wire o_ribm_wrcs,//读写选择
    output wire[3:0] o_ribm_mask, //读写掩码
    output wire[31:0] o_ribm_wdata, //写数据
    input  wire[31:0] i_ribm_rdata,

    output wire o_ribm_req, //发出请求
    input wire i_ribm_gnt, //总线授权
    input wire i_ribm_rsp, //从机响应有效
    output wire o_ribm_rdy //主机响应正常
);


    assign o_ribm_wrcs = 0;//读
    assign o_ribm_mask = 4'b1111;//读4个字节
    assign o_ribm_wdata = 0;//写0

    assign o_ribm_req = i_rstn & i_fetch_vld;
    assign o_ribm_rdy = i_ribm_rsp;

    //握手成功
    wire handshake_rdy = o_ribm_req & i_ribm_gnt;
    //访问成功
    wire access_rdy = i_ribm_rsp;
    reg handshake_rdy_last;//上次传输的握手状态
    //一个总线事务传输完成,上次握手成功&当前传输成功
    wire trans_finish = handshake_rdy_last & access_rdy;

    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            handshake_rdy_last <= 0;
        end
        else begin

            if(i_jump_flag & (~handshake_rdy))begin
                handshake_rdy_last<=0;
            end
            else 
            if(i_fetch_vld )begin//只有当访问成功或handshake_rdy_last为0时，才允许下一次的传输
                if(access_rdy | (~handshake_rdy_last))begin
                handshake_rdy_last <= handshake_rdy;
                end
            end
            else begin//当暂停取指时,取消上次握手,或者当发生跳转时,如果当前没有握手信号,则取消上次握手
                handshake_rdy_last <= 0;
            end
        end
    end


    assign o_pc_vld =  handshake_rdy;
    assign o_access_vld = access_rdy;
    assign o_data_vld =  trans_finish;
    //如果是16位对齐，则需要合并上次取指和当前取指的结果
    assign o_data = i_ribm_rdata;
    assign o_ribm_addr = {i_fetch_addr[31:2],2'd0};

endmodule