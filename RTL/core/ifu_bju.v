




/*
ifu跳转模块
主要负责跳转控制
BPU预测错误跳转放在exu
*/


`include "config.v"


//合并bpu和exu的跳转信号
module IFU_BJU (
    input wire i_clk,
    input wire i_rstn,

    //bpu
    input wire i_bpu_taken,
    input wire[`xlen_def] i_bpu_jaddr,
    //exu
    input wire i_exu_taken,
    input wire[`xlen_def] i_exu_jaddr,
    //pc
    output wire o_jump,
    output wire[`xlen_def] o_jump_addr
);
    

assign o_jump = i_exu_taken | i_bpu_taken;
//跳转地址优先级：执行段>分支预测
assign o_jump_addr= i_exu_taken     ? i_exu_jaddr   :
                    i_bpu_jaddr;


endmodule