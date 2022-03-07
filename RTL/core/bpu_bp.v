

/*
--对于jal指令：
直接将pc加上立即数
--对于jalr指令，只处理rs1==0的情况,
如果rs1！=0,则交给执行段bju处理
pc = rs1 + 立即数
--对于bxx指令
如果立即数为负，则跳转,pc+立即数




*/

`include "config.v"
//分支预测模块
module BPU_BP (
    input wire i_clk,
    input wire i_rstn,

    //预译码信息
    input wire[`xlen_def] i_pc,//当前分支指令pc值
    input wire i_inst_jal,
    input wire i_inst_jalr,
    input wire i_inst_rs1ren,//jalr 需要读rs1
    input wire i_inst_bxx,
    input wire[`xlen_def] i_imm,//立即数
    input wire[`xlen_def] i_jalr_rs1rdata,//jalr rs1读取的值

    //允许进行跳转
    output wire o_prdt_taken,
    output wire[`xlen_def] o_prdt_pc //预分支地址
);



//如果是jal，则直接跳转,如果是bxx，立即数为负则跳转
//对于jalr,如果rs1=0,直接跳转跳转或者不存在jalr rs1读冲突
//如果rs1!=0,则交给bju处理
assign o_prdt_taken =  (i_inst_jalr & (~i_inst_rs1ren)) | i_inst_jal | (i_inst_bxx & i_imm[`xlen-1]);

//rs1+imm或者pc+imm
assign o_prdt_pc = i_inst_jalr ? 
                    i_imm :
                    i_pc + i_imm;

 //i_inst_rs1ren ?  i_imm : ((i_inst_jalr ? i_jalr_rs1rdata : i_pc) + i_imm);




endmodule