





/*
oitf与dispatch作为与执行段的连接 


派遣指令
与OITF共同作用


能够派遣成功的情况：
idu：单周期指令，并且不发生数据冲突，允许派遣
idu：多周期指令，oitf不为空并且不发生数据冲突，允许派遣，否则暂停流水线

派遣的单元：
ALU
MDU
BJU
LSU
SCU


短周期指令共用一个写寄存器接口

长周期指令各种有独立的写寄存器接口


假如指令派遣到mdu
如果mdu占满，则需要暂停前序流水线

*/


`include "config.v"
`include "defines.v"



module DISPATCH (
    input wire i_clk,
    input wire i_rstn,

    input wire i_dis_vld,
    input wire i_flush,//流水线冲刷

    input wire i_bpu_taken,
    input wire[`xlen_def] i_bpu_jaddr,
    output reg o_bpu_taken,
    output reg[`xlen_def] o_bpu_jaddr,

    input wire i_inst_vld,
    //译码信息
    input wire[`xlen_def] i_exu_op1,
    input wire[`xlen_def] i_exu_op2,
    input wire[`xlen_def] i_rs2rdata,
    input wire[`xlen_def] i_imm,
    input wire i_rdwen,
    input wire[`rfidxlen_def] i_rdidx,

    input wire[`csridxlen_def] i_csridx,
    input wire[`xlen_def] i_csr_rdata,
    input wire[`xlen_def] i_csr_zimm,

    input wire[`decinfo_grplen_def] i_decinfo_grp,
    input wire[`decinfolen_def] i_decinfo,
    input wire[`xlen_def] i_iaddr,

    output reg[`xlen_def] o_exu_op1,
    output reg[`xlen_def] o_exu_op2,
    output reg[`xlen_def] o_rs2rdata,
    output reg[`xlen_def] o_imm,
    output reg o_rdwen,
    output reg[`rfidxlen_def] o_rdidx,

    output reg[`csridxlen_def] o_csridx,
    output reg[`xlen_def] o_csr_rdata,
    output reg[`xlen_def] o_csr_zimm,

    output reg[`decinfo_grplen_def] o_decinfo_grp,
    output reg[`decinfolen_def] o_decinfo,
    output reg[`xlen_def] o_iaddr
);


    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            o_rdwen<=0;
            o_decinfo_grp<=0;
        end
        else if(i_dis_vld | i_flush) begin
            o_exu_op1     <= i_exu_op1;
            o_exu_op2     <= i_exu_op2;
            o_rs2rdata    <= i_rs2rdata;
            o_imm         <= i_imm;
            o_rdwen       <= (i_flush|(~i_inst_vld))? 0 :i_rdwen;
            o_rdidx       <= i_rdidx;

            o_csridx      <= i_csridx;
            o_csr_rdata   <= i_csr_rdata;
            o_csr_zimm    <= i_csr_zimm;

            o_decinfo_grp <= (i_flush|(~i_inst_vld))? 0 : i_decinfo_grp;
            o_decinfo     <= i_decinfo;
            o_iaddr       <= i_iaddr;
        end
    end

    always @(posedge i_clk or negedge i_rstn) begin
        if(~i_rstn)begin
            o_bpu_taken<=0;
        end
        else if(i_dis_vld | i_flush) begin
            o_bpu_taken   <= (i_flush|(~i_inst_vld)) ? 0 : i_bpu_taken;
            o_bpu_jaddr   <= i_bpu_jaddr;
        end
    end




endmodule






