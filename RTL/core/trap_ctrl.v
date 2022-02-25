




`include "config.v"
`include "defines.v"



//自陷管理
/*
解决方案：
暂停流水线
检测执行段和译码段,判断哪里的指令是有效的
将有效的指令pc写入mepc
发生自陷时
中断处理程序pc = 中断向量表基地址 + (中断号<<2) 
并关闭全局中断使能


暂且不考虑发生自陷时的csr读写冲突

发生自陷时,ritter目前只支持中断处理，不支持异常处理


*/


module TRAP_CTRL (
    input wire i_clk,
    input wire i_rstn,

    //自陷请求
    input wire i_trap_vld,
    input wire[`trapveclen_def] i_trapvec_id,


    /*几个关于中断的重要csr寄存器*/
    //需要读的
    input wire[`xlen_def] i_csr_mstatus,    //状态寄存器
    input wire[`xlen_def] i_csr_mtvec,      //中断向量表基地址
    input wire[`xlen_def] i_csr_mie,        //中断使能寄存器
    input wire[`xlen_def] i_csr_mip,        //中断挂起寄存器

    //需要写的
    output reg o_trap_update,      //自陷更新所需寄存器
    output reg[`xlen_def] o_csr_mcause,     //异常原因
    output reg[`xlen_def] o_csr_mepc,      //异常pc
    output reg[`xlen_def] o_csr_mstatus,    //状态

    /****************************/
    //连接译码与执行段
    input wire i_bpu_inst_vld,
    input wire[`xlen_def] i_bpu_iaddr,
    input wire i_exu_inst_vld,
    input wire[`xlen_def] i_exu_iaddr,
    //发生自陷时,替换执行段指令为跳转
    output reg o_trap_repl,
    output reg[`xlen_def] o_trap_repl_mtvec

);



    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            o_trap_update <= 0;
            o_trap_repl <= 0;
        end
        else begin
            
        end
    end























    
endmodule