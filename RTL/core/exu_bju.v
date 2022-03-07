


/*

跳转分支模块
单周期

*/


`include "config.v"
`include "defines.v"


module EXU_BJU (
    input wire i_clk,
    input wire i_rstn,

    input wire[`rfidxlen_def] i_bju_rdidx,
    input wire[`decinfo_grplen_def] i_decinfo_grp,
    input wire[`decinfolen_def] i_bjuinfo,
    input wire[`xlen_def] i_rs1_rdata,


    //当前跳转指令的地址
    input wire[`xlen_def] i_iaddr,
    input wire[`xlen_def] i_imm,
    input wire[`xlen_def] i_bju_op1,//rs1
    input wire[`xlen_def] i_bju_op2,//rs2

    output wire o_bju_taken,//跳转
    output wire[`xlen_def] o_bju_jaddr,//跳转地址

    output wire o_bju_rdwen,
    output wire[`rfidxlen_def] o_bju_rdidx,
    output wire[`xlen_def] o_bju_rdwdata

);



    wire bxx_beq  = i_bjuinfo[`bjuinfo_beq]  & (i_bju_op1 == i_bju_op2);
    wire bxx_bne  = i_bjuinfo[`bjuinfo_bne]  & (i_bju_op1!=i_bju_op2);
    wire bxx_blt  = i_bjuinfo[`bjuinfo_blt]  & (($signed(i_bju_op1))<($signed(i_bju_op2)));
    wire bxx_bge  = i_bjuinfo[`bjuinfo_bge]  & (($signed(i_bju_op1))>=($signed(i_bju_op2)));
    wire bxx_bltu = i_bjuinfo[`bjuinfo_bltu] & (i_bju_op1<i_bju_op2);
    wire bxx_bgeu = i_bjuinfo[`bjuinfo_bgeu] & (i_bju_op1>=i_bju_op2);

    wire judgeflag = bxx_beq  |
                     bxx_bne  |
                     bxx_blt  |
                     bxx_bge  |
                     bxx_bltu |
                     bxx_bgeu ;

    //branch:pc+imm
    wire[`xlen_def] bxx_nxtpc = i_iaddr + i_imm;

    //对于jal/jalr指令，需要将pc+4地址写入rd寄存器
    assign o_bju_rdwen = i_decinfo_grp[`decinfo_grp_bju] & (i_bjuinfo[`bjuinfo_jal] | i_bjuinfo[`bjuinfo_jalr]);
    assign o_bju_rdidx = i_bju_rdidx;
    assign o_bju_rdwdata = i_iaddr + 4;

    //如果bflag==1 & judgeflag==1 不用跳转
    //如果bflag==1 & judgeflag==0 需要跳转，跳转地址为当前地址iaddr+4
    //如果bflag==0 & judgeflag==1 需要跳转，跳转地址为当前地址pc+imm
    //如果bflag==0 & judgeflag==0 不用跳转
    //如果是jalr指令,需要跳转
    assign o_bju_taken = i_decinfo_grp[`decinfo_grp_bju] & ((i_bjuinfo[`bjuinfo_bpu_bflag] ^ judgeflag) | i_bjuinfo[`bjuinfo_jalr]);
    assign o_bju_jaddr = i_bjuinfo[`bjuinfo_jalr] ? i_bju_op1+i_imm : (i_bjuinfo[`bjuinfo_bpu_bflag] ? i_iaddr + 4 : bxx_nxtpc);
    
    
endmodule